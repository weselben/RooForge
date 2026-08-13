#!/usr/bin/env bash
# review-loop.sh — run a reviewer subagent in swarm mode, in one of two modes:
#
#   PR mode    target = owner/repo#n  → diff via gh pr diff; parent posts the
#                                      findings as ONE review on the remote PR
#   local mode target = branch/slug   → diff vs base branch; parent consumes
#                                      the findings for its own fix loop
#                                      (forge/issue Phase-5-style reviews)
#
# MANDATORY: invoke from within a Kimi CLI swarm-mode session. The
# kimi -p shell inside this loop is the reviewer's work primitive.
# Do not run in the main chat.
#
# Usage: review-loop.sh <owner/repo#n|branch-or-slug> <worktree-path> [max_iter=5]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOOPS_DIR="$SCRIPT_DIR/../../loops/scripts"

TARGET="${1:?usage: review-loop.sh <owner/repo#n|branch-or-slug> <worktree-path> [max_iter]}"
WORKTREE="${2:?usage: review-loop.sh <owner/repo#n|branch-or-slug> <worktree-path> [max_iter]}"
MAX_ITER="${3:-5}"

if [[ "$TARGET" == *"#"* ]]; then
    MODE="pr"
    PR_NUM="${TARGET##*#}"
    SLUG="$PR_NUM"
else
    MODE="local"
    PR_NUM=""
    SLUG="$(basename "$TARGET" | tr '/ ' '--')"
fi
# Scratch file name aligns with pr-review SKILL.md and forge-cleanup patterns.
SCRATCH="${TMPDIR:-/tmp}/pr-review-${SLUG}.md"

TEMPLATE="$SCRIPT_DIR/templates/review-loop.md"
RENDERED="$(mktemp -t review-loop.rendered.XXXXXX.md)"
trap 'rm -f "$RENDERED"' EXIT

# Substitute {{...}} placeholders, then cavemanize, then feed to run_loop.sh.
sed -E \
    -e "s|\{\{TARGET\}\}|$TARGET|g" \
    -e "s|\{\{MODE\}\}|$MODE|g" \
    -e "s|\{\{PR_NUM\}\}|$PR_NUM|g" \
    -e "s|\{\{WORKTREE\}\}|$WORKTREE|g" \
    -e "s|\{\{SCRATCH\}\}|$SCRATCH|g" \
    "$TEMPLATE" \
    | bash "$LOOPS_DIR/cavemanize.sh" \
    > "$RENDERED"

"$LOOPS_DIR/run_loop.sh" "$RENDERED" "$MAX_ITER" "$WORKTREE"
