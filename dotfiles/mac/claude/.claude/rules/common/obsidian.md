# Obsidian Notes

## Note-Taker Agent (Primary Handler)

For ANY task involving the user's Obsidian notes — searching, reading, creating, or updating — use the **note-taker** agent. This is the designated specialist for all note operations.

Only handle notes directly (without the note-taker agent) if the task is a trivial inline lookup that would be disproportionate to delegate.

## Accessing Obsidian Notes

ALWAYS use the Obsidian CLI (`obsidian`) to access the user's Obsidian notes. Never browse the vault directory directly with file tools when the Obsidian CLI can accomplish the task.

Use the CLI for:
- Reading notes
- Searching notes
- Creating or updating notes
- Navigating the vault

If the `obsidian` CLI cannot accomplish a task, ask the user for permission before using direct file tools.
