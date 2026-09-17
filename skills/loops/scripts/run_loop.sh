#!/usr/bin/env bash
# run_loop.sh — drive a kimi -p loop until DONE: or BLOCKED:
# Usage: run_loop.sh <prompt.md> [max_iter=10] [workdir]
set -euo pipefail

PROMPT_FILE="${1:?run_loop.sh requires a prompt template path}"
MAX_ITER="${2:-10}"
WORKDIR="${3:-$(pwd)}"

# Compute SCRIPT_DIR before any cd, so the relative BASH_SOURCE still resolves.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -f "$PROMPT_FILE" ] || { echo "BLOCKED: prompt file not found: $PROMPT_FILE" >&2; exit 2; }

cd "$WORKDIR"

LOGS=".loops/$(basename "$PROMPT_FILE" .md)"
mkdir -p "$LOGS"
RENDERED="$LOGS/prompt.rendered.md"
# Render the template (cavemanize on initial render)
bash "$SCRIPT_DIR/cavemanize.sh" < "$PROMPT_FILE" > "$RENDERED"

# Pre-kimi gate: ensure cavemanize preserved structural invariants
# (headings, code blocks, URLs, inline codes). Errors block; warnings log.
if ! bash "$SCRIPT_DIR/validate.sh" "$PROMPT_FILE" "$RENDERED" > "$LOGS/validate.out" 2>&1; then
  echo "BLOCKED: pre-kimi validate failed (see $LOGS/validate.out)" >&2
  head -1 "$LOGS/validate.out" >&2 || true
  exit 2
fi

for i in $(seq 1 "$MAX_ITER"); do
  echo "[run_loop] iter $i / $MAX_ITER — calling kimi -p"

  # Run kimi -p in non-interactive mode, capture output
  REPLY=$(kimi -p "$(cat "$RENDERED")" 2>&1) || {
    echo "BLOCKED: kimi -p failed on iter $i" >&2
    echo "$REPLY" > "$LOGS/iter-$i.err"
    exit 2
  }

  # Append reply to running prompt for next iteration
  echo "$REPLY" >> "$RENDERED"

  # Check contract. kimi often wraps its reply with bullets/prose/footers, so accept
  # DONE: / BLOCKED: at line start OR after a single leading bullet marker.
  if echo "$REPLY" | grep -qE "(^|^\s*[-*•]\s)DONE:"; then
    echo "$REPLY" > "$LOGS/done.out"
    echo "[run_loop] DONE on iter $i — artifact: $LOGS/done.out"
    exit 0
  fi

  if echo "$REPLY" | grep -qE "(^|^\s*[-*•]\s)BLOCKED:"; then
    echo "$REPLY" > "$LOGS/blocked.out"
    echo "[run_loop] BLOCKED on iter $i — reason: $LOGS/blocked.out"
    exit 2
  fi

  # Cavemanize the running prompt for the next iteration
  bash "$SCRIPT_DIR/cavemanize.sh" < "$RENDERED" > "$RENDERED.tmp"
  mv "$RENDERED.tmp" "$RENDERED"
done

echo "BLOCKED: max_iter ($MAX_ITER) reached without DONE" >&2
exit 1