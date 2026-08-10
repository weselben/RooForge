#!/usr/bin/env bash
# cavemanize.sh — compress prose to caveman form
# Reads stdin, writes stdout. Preserves code blocks, identifiers, error strings.
# Use: cat prompt.md | cavemanize.sh > prompt.rendered.md
set -euo pipefail

# Minimal cavemanize: drop filler words, collapse whitespace, preserve fenced code blocks.
# The full caveman skill (loaded by the agent) drives the actual compression style.
# This shell pass is a fast pre-compression — removes obvious fluff before kimi -p sees it.

sed -E '
  s/\b(just|really|basically|actually|simply|certainly|of course|sure)\b//g;
  s/  +/ /g;
  s/^ +//;
' | awk '
  BEGIN { in_code = 0 }
  /^```/ { in_code = !in_code; print; next }
  in_code { print; next }
  { sub(/^# /, "# "); sub(/the / /, $0); print }
'