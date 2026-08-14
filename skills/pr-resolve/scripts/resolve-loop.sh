#!/usr/bin/env bash
# resolve-loop.sh — run one finding-group resolver subagent in swarm mode.
#
# MANDATORY: invoke from within a Kimi CLI swarm-mode session. The
# kimi -p shell inside this loop is the resolver's work primitive.
# Do not run in the main chat.
#
# Usage: resolve-loop.sh <findings-file> <worktree-path> [max_iter=5]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOOPS_DIR="$SCRIPT_DIR/../../loops/scripts"

FINDINGS="${1:?usage: resolve-loop.sh <findings-file> <worktree-path> [max_iter]}"
WORKTREE="${2:?usage: resolve-loop.sh <findings-file> <worktree-path> [max_iter]}"
MAX_ITER="${3:-5}"

TEMPLATE="$SCRIPT_DIR/templates/resolve-loop.md"
RENDERED="$(mktemp -t resolve-loop.rendered.XXXXXX.md)"
trap 'rm -f "$RENDERED"' EXIT

# Substitute {{...}} placeholders, then cavemanize, then feed to run_loop.sh.
sed -E \
    -e "s|\{\{FINDINGS\}\}|$FINDINGS|g" \
    -e "s|\{\{WORKTREE\}\}|$WORKTREE|g" \
    "$TEMPLATE" \
    | bash "$LOOPS_DIR/cavemanize.sh" \
    > "$RENDERED"

"$LOOPS_DIR/run_loop.sh" "$RENDERED" "$MAX_ITER" "$WORKTREE"
