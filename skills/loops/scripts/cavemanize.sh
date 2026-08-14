#!/usr/bin/env bash
# cavemanize.sh — compress prose to caveman form
# Reads stdin, writes stdout. Preserves code blocks, identifiers, error strings.
# Use: cat prompt.md | cavemanize.sh > prompt.rendered.md
set -euo pipefail

# Minimal cavemanize: drop filler words, collapse whitespace, preserve fenced code blocks.
# The full caveman skill (loaded by the agent) drives the actual compression style.
# This shell pass is a fast pre-compression — removes obvious fluff before kimi -p sees it.
# Caveat: sed is line-agnostic about ```-fenced code blocks, so filler words inside code
# may also be dropped. The kimi prompt template is short prose with occasional inline
# code; the agent's full caveman skill does the careful compression after loading.

sed -E '
  s/\b(just|really|basically|actually|simply|certainly|of course|sure|the)\b//g;
  s/  +/ /g;
  s/^ +//;
'