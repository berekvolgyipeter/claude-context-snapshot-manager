# claude-context-snapshot-manager

Switch between multiple [claude-context](https://github.com/zilliztech/claude-context) snapshot files when using different Milvus instances.

## Problem

The claude-context MCP server uses a single shared snapshot file (`~/.context/mcp-codebase-snapshot.json`) to track which codebases are indexed. If you run multiple Milvus instances (e.g. different ports or databases), they clobber each other's state.

## Solution

Keep a separate snapshot file per Milvus instance and symlink the active one.

## Setup

1. Source `ctx.sh` in your `.zshrc` or `.bashrc`:

```sh
source /path/to/ctx.sh
```

2. Create snapshot files:

```sh
ctx-add general
ctx-add myproject
```

If you already have an existing `mcp-codebase-snapshot.json`, it will be automatically backed up to `.bak` on first switch. You can restore it with `ctx-restore`.

## Commands

```
ctx <name>      Switch to snapshot <name>
ctx-add <name>  Create a new empty snapshot
ctx-ls          List available snapshots (* marks active)
ctx-read        Print current snapshot contents (requires jq)
ctx-which       Show which snapshot is active
ctx-restore     Restore original file from .bak backup
ctx-save        Save snapshots from ~/.context/ to repo .context/ (gitignored)
ctx-load [name] Load snapshot(s) from repo .context/ to ~/.context/
ctx-backup      Copy .context/ to .context-backup/
ctx-help        Show available commands
```
