# Bookmarks for micro

This fork turns the bookmark plugin into a lightweight navigation history for
micro. It automatically records the last 20 cursor locations you visit across
all buffers (similar to VS Code's Go Back/Forward) and lets you walk that
history with the original bookmark keybindings.

## Installation

```
# option 1: bash
$ micro -plugin install bookmark

# option 2: micro
> plugin install bookmark
```

## Usage

```
# force-save the current cursor location (Ctrl-F2)
> toggleBookmark

# clear the rolling history (CtrlShift-F2)
> clearBookmarks

# jump forward to the next recorded spot (Alt-.)
> nextBookmark

# jump backward to the previous spot (Alt-,)
> prevBookmark
```

Notes:

- Positions are tracked globally across buffers; when you revisit a file its pane
  is focused automatically (entries for closed panes are discarded on use).
- The history keeps the most recent 20 unique positions. Moving again within the
  same location does not duplicate the entry.

## Troubleshooting

If the default keyboard shortcuts do not work, it is most likely because it is already in use by another program.

Keyboard shortcuts can be changed in `~/.config/micro/bindings.json`.

```json
{
    "Ctrl-F2": "command:toggleBookmark",
    "CtrlShift-F2": "command:clearBookmarks",
    "Alt-.": "command:nextBookmark",
    "Alt-,": "command:prevBookmark"
}
```
