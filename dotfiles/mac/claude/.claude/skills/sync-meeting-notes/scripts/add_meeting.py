#!/usr/bin/env python3
"""Add a meeting summary to Eric's daily journal note, only ever adding text.

Usage:
  add_meeting.py SPEC.json [--dry-run] [--vault PATH]
  add_meeting.py - < SPEC.json

SPEC.json:
  {
    "date": "2026-11-08",                 # journal date (local)
    "title": "Weekly Sync",               # becomes "### Weekly Sync"
    "source_id": 12,                      # OpenWhispr note id (prevents double syncs)
    "when": "2026-11-08 14:00:00",        # optional
    "who": ["Sarah", "Dan"],              # optional; "Eric" is added first
    "topics": [
      {"heading": "Budget", "bullets": ["Point", {"text": "Point", "children": ["detail"]}]}
    ],
    "next_steps": ["Step", {"text": "Step", "details": ["context"]}]
  }

Rules:
  * Creates the daily note from the journal template if it doesn't exist.
  * Ensures "## Meetings" under "# Notes", and "### <title>" under it.
  * If "### <title>" already exists anywhere in the note (e.g. notes Eric took
    himself), adds to that section in place: new "#### topic" sections, and new
    bullets appended to "#### Next Steps".
  * Never changes or removes existing lines (except empty "* " template
    placeholders in a section it adds to). This is verified before writing.

Exit codes: 0 written (or dry run), 1 bad input, 3 meeting already synced.
"""

from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import sys
import tempfile
from dataclasses import dataclass
from datetime import date
from pathlib import Path

VAULT = Path.home() / "Library" / "Mobile Documents" / "iCloud~md~obsidian" / "Documents" / "notes"
TEMPLATE_PATH = Path("obsidian") / "templates" / "Notes" / "journal.md"
NOTES_HEADING = (1, "Notes")
MEETINGS_HEADING = (2, "Meetings")
MEETING_LEVEL = 3
TOPIC_LEVEL = 4
NEXT_STEPS = "Next Steps"
MEETING_TAG = "#meeting"
OWNER = "Eric"
MARKER = "%% openwhispr-note: {id} %%"
PLACEHOLDERS = frozenset({"*", "-"})
MONTHS = ("January", "February", "March", "April", "May", "June", "July",
          "August", "September", "October", "November", "December")
WEEKDAYS = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*?)\s*$")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
EXIT_BAD_INPUT = 1
EXIT_ALREADY_SYNCED = 3


class SpecError(ValueError):
    """The meeting spec is invalid."""


class SafetyError(RuntimeError):
    """An edit would have changed or removed existing text."""


@dataclass(frozen=True)
class Bullet:
    text: str
    children: tuple[str, ...] = ()


@dataclass(frozen=True)
class Topic:
    heading: str
    bullets: tuple[Bullet, ...]


@dataclass(frozen=True)
class Meeting:
    day: date
    title: str
    source_id: int | None
    when: str | None
    who: tuple[str, ...]
    topics: tuple[Topic, ...]
    next_steps: tuple[Bullet, ...]


@dataclass(frozen=True)
class Heading:
    index: int
    level: int
    text: str


# ----------------------------------------------------------------- spec parsing


def _text(value: object, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise SpecError(f"{field} must be a non-empty string")
    return " ".join(value.split())


def _bullet(item: object, field: str) -> Bullet:
    if isinstance(item, str):
        return Bullet(_text(item, field))
    if isinstance(item, dict):
        extra = item.get("children", item.get("details", []))
        if not isinstance(extra, list):
            raise SpecError(f"{field} children/details must be a list")
        return Bullet(_text(item.get("text"), field), tuple(_text(c, field) for c in extra))
    raise SpecError(f"{field} items must be strings or {{text, children}} objects")


def _topic(item: object) -> Topic:
    if not isinstance(item, dict) or not isinstance(item.get("bullets"), list):
        raise SpecError("each topic needs a heading and a bullets list")
    heading = _text(item.get("heading"), "topic heading")
    if heading.casefold() == NEXT_STEPS.casefold():
        raise SpecError("put next steps in next_steps, not topics")
    bullets = tuple(_bullet(b, f"topic '{heading}'") for b in item["bullets"])
    if not bullets:
        raise SpecError(f"topic '{heading}' has no bullets")
    return Topic(heading, bullets)


def parse_spec(data: object) -> Meeting:
    if not isinstance(data, dict):
        raise SpecError("spec must be a JSON object")
    try:
        day = date.fromisoformat(_text(data.get("date"), "date"))
    except ValueError as err:
        raise SpecError(f"date must be YYYY-MM-DD: {err}") from err
    source_id = data.get("source_id")
    if source_id is not None and not isinstance(source_id, int):
        raise SpecError("source_id must be an integer")
    topics = tuple(_topic(t) for t in data.get("topics") or [])
    steps = tuple(_bullet(s, "next step") for s in data.get("next_steps") or [])
    if not topics and not steps:
        raise SpecError("nothing to add: give at least one topic or next step")
    who = tuple(_text(w, "who") for w in data.get("who") or [])
    when = _text(data["when"], "when") if data.get("when") else None
    return Meeting(day, _text(data.get("title"), "title"), source_id, when, who, topics, steps)


# ----------------------------------------------------------------- markdown helpers


def daily_note_path(vault: Path, day: date) -> Path:
    month = f"{day.month:02d} - {MONTHS[day.month - 1]}"
    name = f"{day.isoformat()} {WEEKDAYS[day.weekday()]}.md"
    return vault / "journal" / str(day.year) / month / name


def find_headings(lines: list[str]) -> list[Heading]:
    found, in_fence = [], False
    for i, line in enumerate(lines):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        match = None if in_fence else HEADING_RE.match(line)
        if match:
            found.append(Heading(i, len(match.group(1)), match.group(2)))
    return found


def _same(a: str, b: str) -> bool:
    return " ".join(a.split()).casefold() == " ".join(b.split()).casefold()


def find_heading(lines: list[str], level: int, text: str, start: int = 0, end: int | None = None) -> Heading | None:
    stop = len(lines) if end is None else end
    for h in find_headings(lines):
        if start <= h.index < stop and h.level == level and _same(h.text, text):
            return h
    return None


def section_end(lines: list[str], heading: Heading) -> int:
    """Index of the next heading at the same or a higher level (or end of note)."""
    for h in find_headings(lines):
        if h.index > heading.index and h.level <= heading.level:
            return h.index
    return len(lines)


def content_end(lines: list[str], start: int, end: int) -> int:
    """Index just after the last non-blank line in lines[start:end]."""
    last = start
    for i in range(start, end):
        if lines[i].strip():
            last = i + 1
    return last


def insert(lines: list[str], index: int, block: list[str], gap_before: bool = False) -> list[str]:
    """Insert block at index; with gap_before, keep a blank line on each side of it."""
    next_is_heading = index < len(lines) and HEADING_RE.match(lines[index])
    lead = [""] if gap_before and index > 0 and lines[index - 1].strip() else []
    tail = [""] if gap_before and next_is_heading and block[-1] else []
    return lines[:index] + lead + block + tail + lines[index:]


def render_bullets(bullets: tuple[Bullet, ...]) -> list[str]:
    out = []
    for b in bullets:
        out.append(f"* {b.text}")
        out.extend(f"\t* {c}" for c in b.children)
    return out


def render_topic(topic: Topic) -> list[str]:
    return [f"{'#' * TOPIC_LEVEL} {topic.heading}", *render_bullets(topic.bullets)]


def render_next_steps(steps: tuple[Bullet, ...]) -> list[str]:
    return [f"{'#' * TOPIC_LEVEL} {NEXT_STEPS}", *render_bullets(steps)] if steps else []


def marker_lines(meeting: Meeting) -> list[str]:
    return [MARKER.format(id=meeting.source_id)] if meeting.source_id is not None else []


def render_meeting(meeting: Meeting) -> list[str]:
    people = [OWNER, *[w for w in meeting.who if not _same(w, OWNER)]]
    header = [f"{'#' * MEETING_LEVEL} {meeting.title}", MEETING_TAG]
    header += [f"* When: {meeting.when}"] if meeting.when else []
    header += [f"* Who: {', '.join(people)}", *marker_lines(meeting), ""]
    body = [line for t in meeting.topics for line in render_topic(t)]
    return header + body + render_next_steps(meeting.next_steps)


# ----------------------------------------------------------------- note edits


def ensure_heading(lines: list[str], level: int, text: str, parent: Heading | None) -> tuple[list[str], Heading]:
    start, end = (parent.index, section_end(lines, parent)) if parent else (0, len(lines))
    existing = find_heading(lines, level, text, start, end)
    if existing:
        return lines, existing
    at = content_end(lines, start, end) if parent else len(lines)
    updated = insert(lines, at, [f"{'#' * level} {text}"], gap_before=True)
    return updated, find_heading(updated, level, text, start)


def add_new_meeting(lines: list[str], meeting: Meeting) -> list[str]:
    lines, notes = ensure_heading(lines, *NOTES_HEADING, parent=None)
    lines, meetings = ensure_heading(lines, *MEETINGS_HEADING, parent=notes)
    at = content_end(lines, meetings.index, section_end(lines, meetings))
    return insert(lines, at, render_meeting(meeting), gap_before=True)


def _drop_placeholders(lines: list[str], start: int, end: int) -> list[str]:
    return lines[:start] + [l for l in lines[start:end] if l.strip() not in PLACEHOLDERS] + lines[end:]


def append_to_subsection(lines: list[str], sub: Heading, bullets: tuple[Bullet, ...]) -> list[str]:
    end = section_end(lines, sub)
    present = {" ".join(l.split()).casefold() for l in lines[sub.index:end]}
    new = tuple(b for b in bullets if f"* {b.text}".casefold() not in present)
    if not new:
        return lines
    cleaned = _drop_placeholders(lines, sub.index + 1, end)
    end = section_end(cleaned, sub)
    return insert(cleaned, content_end(cleaned, sub.index, end), render_bullets(new))


def merge_meeting(lines: list[str], section: Heading, meeting: Meeting) -> list[str]:
    for topic in meeting.topics:
        end = section_end(lines, section)
        same = find_heading(lines, TOPIC_LEVEL, topic.heading, section.index, end)
        if same:
            lines = append_to_subsection(lines, same, topic.bullets)
            continue
        steps = find_heading(lines, TOPIC_LEVEL, NEXT_STEPS, section.index, end)
        at = steps.index if steps else content_end(lines, section.index, end)
        lines = insert(lines, at, render_topic(topic))
    end = section_end(lines, section)
    steps = find_heading(lines, TOPIC_LEVEL, NEXT_STEPS, section.index, end)
    if steps:
        lines = append_to_subsection(lines, steps, meeting.next_steps)
    elif meeting.next_steps:
        lines = insert(lines, content_end(lines, section.index, end), render_next_steps(meeting.next_steps))
    end = section_end(lines, section)
    return insert(lines, content_end(lines, section.index, end), marker_lines(meeting)) if marker_lines(meeting) else lines


def apply_meeting(lines: list[str], meeting: Meeting) -> tuple[list[str], bool]:
    """Return the updated lines and whether an existing meeting section was merged into."""
    section = find_heading(lines, MEETING_LEVEL, meeting.title)
    if section:
        return merge_meeting(lines, section, meeting), True
    return add_new_meeting(lines, meeting), False


def assert_only_added(old: list[str], new: list[str]) -> None:
    matcher = difflib.SequenceMatcher(a=old, b=new, autojunk=False)
    for op, a1, a2, _, _ in matcher.get_opcodes():
        if op in ("delete", "replace") and any(l.strip() not in PLACEHOLDERS for l in old[a1:a2]):
            raise SafetyError(f"refusing to write: existing lines would change: {old[a1:a2]!r}")


def already_synced(text: str, meeting: Meeting) -> bool:
    return meeting.source_id is not None and MARKER.format(id=meeting.source_id) in text


# ----------------------------------------------------------------- io


def split_lines(text: str) -> list[str]:
    return text[:-1].split("\n") if text.endswith("\n") else text.split("\n")


def write_atomic(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=".sync-meeting-", suffix=".md")
    try:
        with os.fdopen(fd, "w") as handle:
            handle.write(text)
        os.replace(tmp, path)
    except BaseException:
        Path(tmp).unlink(missing_ok=True)
        raise


def load_spec(source: str) -> Meeting:
    raw = sys.stdin.read() if source == "-" else Path(source).read_text()
    return parse_spec(json.loads(raw))


def run(meeting: Meeting, vault: Path, dry_run: bool) -> dict:
    path = daily_note_path(vault, meeting.day)
    created = not path.exists()
    original = (vault / TEMPLATE_PATH).read_text() if created else path.read_text()
    if already_synced(original, meeting):
        return {"status": "already_synced", "note": str(path.relative_to(vault))}
    old = split_lines(original)
    new, merged = apply_meeting(old, meeting)
    assert_only_added(old, new)
    text = "\n".join(new) + "\n"
    if dry_run:
        sys.stderr.writelines(difflib.unified_diff(
            [l + "\n" for l in old], [l + "\n" for l in new], "before", "after"))
    else:
        write_atomic(path, text)
    return {"status": "dry_run" if dry_run else "written", "note": str(path.relative_to(vault)),
            "created_note": created, "merged_into_existing_section": merged}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("spec", help="path to the meeting spec JSON, or - for stdin")
    parser.add_argument("--dry-run", action="store_true", help="print a diff to stderr, write nothing")
    parser.add_argument("--vault", type=Path, default=VAULT, help="vault root (default: Eric's vault)")
    args = parser.parse_args()
    try:
        result = run(load_spec(args.spec), args.vault, args.dry_run)
    except (SpecError, json.JSONDecodeError, OSError) as err:
        print(f"error: {err}", file=sys.stderr)
        return EXIT_BAD_INPUT
    print(json.dumps(result, indent=2))
    return EXIT_ALREADY_SYNCED if result["status"] == "already_synced" else 0


if __name__ == "__main__":
    sys.exit(main())
