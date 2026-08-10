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
# shellcheck source=loop.sh
source "$SCRIPT_DIR/../../loops/scripts/loop.sh"

FINDINGS="${1:?usage: resolve-loop.sh <findings-file> <worktree-path> [max_iter]}"
WORKTREE="${2:?usage: resolve-loop.sh <findings-file> <worktree-path> [max_iter]}"
MAX_ITER="${3:-5}"

PROMPT=$("$SCRIPT_DIR/../../loops/scripts/cavemanize.sh" "$SCRIPT_DIR/templates/resolve-loop.md" FINDINGS="$FINDINGS" WORKTREE="$WORKTREE")

run_loop "pr-resolve-$(basename "$WORKTREE")" "$PROMPT" "$MAX_ITER"
