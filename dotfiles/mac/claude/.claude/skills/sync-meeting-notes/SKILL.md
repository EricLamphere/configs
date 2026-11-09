---
name: sync-meeting-notes
description: Sync meeting notes from OpenWhispr (local meeting transcription) into Eric's Obsidian daily journal. Use when Eric asks to sync, import, pull in, or add his meeting notes, meeting summaries, or a specific meeting to his journal or daily note. Summarizes each meeting into topic sections and Next Steps under "## Meetings", only ever adding to existing notes.
---

# Sync meeting notes to the daily journal

Pull meetings from OpenWhispr (fully local) and add a summary of each to Eric's daily journal note. Work directly on the Markdown files; never use the `obsidian` CLI.

Scripts live next to this file in `scripts/`:
- `fetch_meetings.py` reads meetings from OpenWhispr's local bridge, or its database read-only if the app is closed.
- `add_meeting.py` writes one meeting into the daily note. It only adds lines and verifies that before writing.

## The format

Each meeting goes under a level-2 `## Meetings` heading inside `# Notes`:

```markdown
## Meetings

### <Meeting title>
#meeting
* When: 2026-11-08 14:00:00
* Who: Eric, Sarah, Dan
%% openwhispr-note: 12 %%

#### <Topic discussed>
* Terse point
	* Supporting detail
#### <Another topic>
* Point
#### Next Steps
* Main description of the next step
	* More context, if needed
```

- One `####` section per topic discussed, named for the topic (not "Summary" or "Notes").
- `#### Next Steps` only when next steps were actually defined: a parent bullet per step, with a sub-bullet only when extra context helps. Include the owner in the step when it's someone other than Eric (e.g. "Dan to send the contract").
- Bullets use `*`; sub-bullets are tab-indented. Keep them short and scannable, like Eric's own notes.
- The `%% openwhispr-note: <id> %%` line is an Obsidian comment (hidden in reading view) that stops the same meeting being synced twice. The script adds it.

## Steps

1. **Find the meetings.** Default to today's (Eric's local date, America/New_York):
   ```bash
   python3 ~/.claude/skills/sync-meeting-notes/scripts/fetch_meetings.py              # today
   python3 ~/.claude/skills/sync-meeting-notes/scripts/fetch_meetings.py --date 2026-11-07
   python3 ~/.claude/skills/sync-meeting-notes/scripts/fetch_meetings.py --recent 10  # to find one by name
   python3 ~/.claude/skills/sync-meeting-notes/scripts/fetch_meetings.py --id 12
   ```
   Each meeting has `id`, `title`, `local_date`, `when`, `participants`, `user_notes` (anything Eric typed in OpenWhispr), `ai_summary` (OpenWhispr's AI notes, may be empty) and `transcript`. If there are none, say so and stop.

2. **Read the daily note** for that date, if it exists: `journal/YYYY/MM - MMMM/YYYY-MM-DD ddd.md` in the vault (`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes`). Look at its `###` headings. If Eric already started a section for this meeting under a slightly different name (e.g. `### Standup` for OpenWhispr's "Daily Standup"), use **his heading text** as the title so the summary is added to his section. If it's ambiguous, ask.

3. **Summarize.** Start from `ai_summary` when it has content, restructured into the format above; otherwise summarize `transcript` yourself. Fold in `user_notes`. Don't repeat points Eric already wrote in his own section of the daily note. Use participant names from `participants` or the transcript's speaker labels.

4. **Write a spec** to a temp file in your scratchpad:
   ```json
   {
     "date": "<local_date>",
     "title": "<title>",
     "source_id": <id>,
     "when": "<when>",
     "who": ["Sarah", "Dan"],
     "topics": [{"heading": "Budget", "bullets": ["Point", {"text": "Point", "children": ["detail"]}]}],
     "next_steps": [{"text": "Send the deck to Sarah", "details": ["by Friday"]}]
   }
   ```
   `who` excludes Eric (the script adds him first). Omit `next_steps` (or leave it empty) when none were defined.

5. **Preview, then write:**
   ```bash
   python3 ~/.claude/skills/sync-meeting-notes/scripts/add_meeting.py spec.json --dry-run   # diff on stderr
   python3 ~/.claude/skills/sync-meeting-notes/scripts/add_meeting.py spec.json
   ```
   The script creates the daily note from the journal template if it's missing, adds `## Meetings` and `### <title>` if missing, or merges into an existing `### <title>` section: new topics go before its `#### Next Steps`, new steps are appended to it, and nothing existing is changed.

6. **Report** in one line per meeting, e.g. "Added Weekly Sync to today's daily note (merged into your notes)".

## Rules

- **Never overwrite or remove Eric's notes.** Always go through `add_meeting.py`; don't hand-edit the daily note for this, because the script checks that every existing line survives. If it refuses with a "refusing to write" error, stop and tell Eric rather than working around it.
- Exit code `3` means the meeting was already synced. Tell Eric and skip it unless he asks to add it again; if he does, drop `source_id` from the spec.
- Exit code `1` means a bad spec or file problem; fix the spec, don't edit the note manually.
- Never run git in the vault, and don't touch `.obsidian/`.
- Everything stays local: don't send transcripts to any external service.
