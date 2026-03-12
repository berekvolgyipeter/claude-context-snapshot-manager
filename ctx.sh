# claude-context-snapshot-manager
# Source this file in your .zshrc or .bashrc:
#   source /path/to/ctx.sh

# Show available commands
ctx-help() {
  echo "ctx <name>      Switch to snapshot <name>"
  echo "ctx-add <name>  Create a new empty snapshot"
  echo "ctx-ls          List available snapshots"
  echo "ctx-read        Print current snapshot contents"
  echo "ctx-which       Show which snapshot is active"
  echo "ctx-restore     Restore original file from .bak backup"
  echo "ctx-pull        Copy snapshots to repo .context/"
  echo "ctx-help        Show this help"
}

CTX_DIR="$HOME/.context"
CTX_SNAPSHOT="$CTX_DIR/mcp-codebase-snapshot.json"
CTX_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

# Switch snapshot: ctx <name>
# Symlinks mcp-codebase-snapshot.json -> mcp-codebase-snapshot-<name>.json
ctx() {
  [ -z "$1" ] && echo "Usage: ctx <name>" && return 1
  local f="$CTX_DIR/mcp-codebase-snapshot-$1.json"
  [ ! -f "$f" ] && echo "Not found: $f" && return 1
  if [ -e "$CTX_SNAPSHOT" ] && [ ! -L "$CTX_SNAPSHOT" ]; then
    echo "Warning: $CTX_SNAPSHOT is a regular file, not a symlink."
    echo "Backing up to $CTX_SNAPSHOT.bak"
    mv "$CTX_SNAPSHOT" "$CTX_SNAPSHOT.bak"
  fi
  ln -sf "$f" "$CTX_SNAPSHOT"
  echo "Switched to $1"
}

# Create a new snapshot: ctx-add <name>
ctx-add() {
  [ -z "$1" ] && echo "Usage: ctx-add <name>" && return 1
  local f="$CTX_DIR/mcp-codebase-snapshot-$1.json"
  [ -f "$f" ] && echo "Already exists: $f" && return 1
  mkdir -p "$CTX_DIR"
  echo '{}' > "$f"
  echo "Created $f"
}

# Restore original file from backup
ctx-restore() {
  [ ! -f "$CTX_SNAPSHOT.bak" ] && echo "No backup found: $CTX_SNAPSHOT.bak" && return 1
  [ -L "$CTX_SNAPSHOT" ] && rm "$CTX_SNAPSHOT"
  mv "$CTX_SNAPSHOT.bak" "$CTX_SNAPSHOT"
  echo "Restored $CTX_SNAPSHOT from backup"
}

# List available snapshots
ctx-ls() {
  for f in "$CTX_DIR"/mcp-codebase-snapshot-*.json; do
    [ ! -f "$f" ] && echo "No snapshots found" && return
    local name="${f##*mcp-codebase-snapshot-}"
    name="${name%.json}"
    if [ -L "$CTX_SNAPSHOT" ] && [ "$(realpath "$CTX_SNAPSHOT")" = "$(realpath "$f")" ]; then
      echo "* $name"
    else
      echo "  $name"
    fi
  done
}

# Copy all snapshot files to the repo
ctx-pull() {
  local dest="$CTX_REPO_DIR/.context"
  mkdir -p "$dest"
  local count=0
  for f in "$CTX_DIR"/mcp-codebase-snapshot-*.json; do
    [ ! -f "$f" ] && echo "No snapshots found" && return 1
    cp "$f" "$dest/"
    count=$((count + 1))
  done
  echo "Copied $count snapshot(s) to $dest"
}

# Print current snapshot contents
ctx-read() {
  cat "$CTX_SNAPSHOT" | jq .
}

# Show which snapshot file is active
ctx-which() {
  if [ -L "$CTX_SNAPSHOT" ]; then
    readlink "$CTX_SNAPSHOT"
  elif [ -e "$CTX_SNAPSHOT" ]; then
    echo "$CTX_SNAPSHOT (regular file, not a symlink)"
  else
    echo "No snapshot found at $CTX_SNAPSHOT"
  fi
}
