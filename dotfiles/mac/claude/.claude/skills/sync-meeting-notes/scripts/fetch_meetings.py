#!/usr/bin/env python3
"""Fetch OpenWhispr meeting notes as JSON.

Reads from the desktop app's local bridge (127.0.0.1, token in
~/.openwhispr/cli-bridge.json). If the app isn't running, falls back to
reading its SQLite database read-only. Nothing leaves the machine.

Usage:
  fetch_meetings.py                 # today's meetings (America/New_York)
  fetch_meetings.py --date 2026-11-08
  fetch_meetings.py --id 12
  fetch_meetings.py --recent 10     # latest meetings, any date
"""

import argparse
import json
import sqlite3
import sys
import urllib.error
import urllib.request
from datetime import date, datetime, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

LOCAL_TZ = ZoneInfo("America/New_York")
BRIDGE_FILE = Path.home() / ".openwhispr" / "cli-bridge.json"
DB_FILE = Path.home() / "Library" / "Application Support" / "open-whispr" / "transcriptions.db"
MEETING_TYPE = "meeting"
LIST_LIMIT = 500
HTTP_TIMEOUT_SECONDS = 5


def to_local(utc_text):
    """Convert OpenWhispr's UTC 'YYYY-MM-DD HH:MM:SS' (or ISO) timestamp to local time."""
    if not utc_text:
        return None
    parsed = datetime.fromisoformat(utc_text.replace("Z", "+00:00").replace(" ", "T"))
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(LOCAL_TZ)


def parse_participants(raw):
    if not raw:
        return []
    try:
        value = json.loads(raw) if isinstance(raw, str) else raw
    except json.JSONDecodeError:
        return [p.strip() for p in str(raw).split(",") if p.strip()]
    if isinstance(value, list):
        return [p.get("name", str(p)) if isinstance(p, dict) else str(p) for p in value]
    return [str(value)]


def shape(note):
    start = to_local(note.get("created_at"))
    return {
        "id": note.get("id"),
        "title": (note.get("title") or "Untitled Meeting").strip(),
        "local_date": start.date().isoformat() if start else None,
        "when": start.strftime("%Y-%m-%d %H:%M:%S") if start else None,
        "duration_minutes": round((note.get("audio_duration_seconds") or 0) / 60) or None,
        "participants": parse_participants(note.get("participants")),
        "user_notes": note.get("content") or "",
        "ai_summary": note.get("enhanced_content") or "",
        "transcript": note.get("transcript") or "",
    }


class Bridge:
    def __init__(self, port, token):
        self.base = f"http://127.0.0.1:{port}/v1"
        self.headers = {"Authorization": f"Bearer {token}"}

    @classmethod
    def connect(cls):
        try:
            info = json.loads(BRIDGE_FILE.read_text())
            bridge = cls(info["port"], info["token"])
            bridge.get("/health")
            return bridge
        except (OSError, KeyError, ValueError, urllib.error.URLError):
            return None

    def get(self, path):
        request = urllib.request.Request(self.base + path, headers=self.headers)
        with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT_SECONDS) as response:
            return json.load(response)["data"]

    def meetings(self):
        listed = self.get(f"/notes/list?note_type={MEETING_TYPE}&limit={LIST_LIMIT}")
        return [self.get(f"/notes/{n['id']}") for n in listed if not n.get("deleted_at")]


def db_meetings():
    if not DB_FILE.exists():
        sys.exit(f"error: OpenWhispr isn't running and its database wasn't found at {DB_FILE}")
    uri = f"file:{DB_FILE}?mode=ro"
    with sqlite3.connect(uri, uri=True) as conn:
        conn.row_factory = sqlite3.Row
        rows = conn.execute(
            "SELECT * FROM notes WHERE note_type = ? AND deleted_at IS NULL ORDER BY created_at",
            (MEETING_TYPE,),
        ).fetchall()
    return [dict(r) for r in rows]


def select(meetings, args):
    if args.id is not None:
        return [m for m in meetings if m["id"] == args.id]
    if args.recent:
        return sorted(meetings, key=lambda m: m["when"] or "", reverse=True)[: args.recent]
    target = args.date or date.today().isoformat()
    return [m for m in meetings if m["local_date"] == target]


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--date", help="local date, YYYY-MM-DD (default: today)")
    group.add_argument("--id", type=int, help="a single meeting note id")
    group.add_argument("--recent", type=int, help="the N most recent meetings")
    args = parser.parse_args()

    bridge = Bridge.connect()
    raw = bridge.meetings() if bridge else db_meetings()
    meetings = select([shape(n) for n in raw], args)
    print(json.dumps({"source": "bridge" if bridge else "database", "meetings": meetings}, indent=2))


if __name__ == "__main__":
    main()
