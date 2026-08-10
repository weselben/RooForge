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
# shellcheck source=loop.sh
source "$SCRIPT_DIR/../../loops/scripts/loop.sh"

TARGET="${1:?usage: review-loop.sh <owner/repo#n|branch-or-slug> <worktree-path> [max_iter]}"
WORKTREE="${2:?usage: review-loop.sh <owner/repo#n|branch-or-slug> <worktree-path> [max_iter]}"
MAX_ITER="${3:-5}"

if [[ "$TARGET" == *"#"* ]]; then
    MODE="pr"
    PR_NUM="${TARGET##*#}"
    SLUG="pr-${PR_NUM}"
else
    MODE="local"
    PR_NUM=""
    SLUG="$(basename "$TARGET" | tr '/ ' '--')"
fi
SCRATCH="${TMPDIR:-/tmp}/review-${SLUG}.md"

PROMPT=$("$SCRIPT_DIR/../../loops/scripts/cavemanize.sh" "$SCRIPT_DIR/templates/review-loop.md" \
    TARGET="$TARGET" MODE="$MODE" PR_NUM="$PR_NUM" WORKTREE="$WORKTREE" SCRATCH="$SCRATCH")

run_loop "review-${SLUG}" "$PROMPT" "$MAX_ITER"
