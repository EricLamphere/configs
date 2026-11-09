# Obsidian Notes

## Note-Taker Agent (Primary Handler)

For ANY task involving the user's Obsidian notes — searching, reading, creating, or updating — use the **note-taker** agent. This is the designated specialist for all note operations.

Only handle notes directly (without the note-taker agent) if the task is a trivial inline lookup that would be disproportionate to delegate.

## Accessing Obsidian Notes

The vault is plain Markdown files on disk:

`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes`

Read, search, create and edit notes directly with normal file tools (Read, Grep, Glob, Edit, Write, or short scripts). Do NOT use the `obsidian` CLI.

- Read a note before changing it, and add to it rather than rewriting existing content unless asked.
- Never run git commands in the vault; a cron job handles syncing.
- Don't touch `.obsidian/`.
