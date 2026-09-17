#!/usr/bin/env bash
# validate.sh — ensure compressed file preserves critical content from original
# Inspired by JuliusBrussee/caveman validate.py
# (https://github.com/JuliusBrussee/caveman/blob/main/skills/caveman-compress/scripts/validate.py)
#
# Severity split:
#   ERROR (blocks run_loop.sh)  — structural breakage: missing heading, fence
#                                  count drift, lost URL, lost inline code.
#   WARNING (advisory only)     — content drift inside a preserved structure:
#                                  cavemanize.sh uses sed, which is line-agnostic
#                                  about ``` fences, so content inside may drift.
#                                  Cosmetic heading/whitespace drift also WARN.
#
# Limits vs validate.py:
#   * Indented fences (CommonMark 0-3 leading spaces) supported — matches at
#     column 0-3 only; deeper indentation skipped.
#   * Bash 4+ regex used; macOS default bash 3.2 will not run this. Loops
#     already requires bash; forge users are Linux/CI.
#   * Path regex is a pragmatic heuristic adapted from validate.py:7 — not
#     CommonMark-precise. WARN-level only, so imprecision does not block.
#
# Usage: validate.sh <original> <compressed>
# Exit:  0 valid (no errors; warnings allowed) | 1 invalid | 2 usage error
#
# Stdout: one finding per line. ERROR: / WARNING: prefix. Final line:
#         "Valid: yes" or "Valid: no".

set -euo pipefail

[[ $# -eq 2 ]] || { echo "usage: validate.sh <original> <compressed>" >&2; exit 2; }
orig="$1"
comp="$2"
[[ -f "$orig" ]] || { echo "FAIL: original not found: $orig" >&2; exit 2; }
[[ -f "$comp" ]] || { echo "FAIL: compressed not found: $comp" >&2; exit 2; }

errors=0
warnings=0
err()  { echo "ERROR: $*";   errors=$((errors+1)); }
warn() { echo "WARNING: $*"; warnings=$((warnings+1)); }

# Fence state machine. Mutates globals in_fence, fence_char, fence_len.
in_fence=0; fence_char=""; fence_len=0

_fence_open_at() {
  # $1 = line. Sets globals and returns 0 if line opens a fence.
  if [[ "$1" =~ ^([[:space:]]{0,3})([\`~]{3,})(.*)$ ]]; then
    local chars="${BASH_REMATCH[2]}"
    fence_char="${chars:0:1}"
    fence_len="${#chars}"
    in_fence=1
    return 0
  fi
  return 1
}

_fence_close_at() {
  # $1 = line. Closes if same char and length >= opening length, no info string.
  if [[ "$1" =~ ^([[:space:]]{0,3})([\`~]+)([[:space:]]*)$ ]]; then
    local chars="${BASH_REMATCH[2]}"
    local rest="${BASH_REMATCH[3]}"
    local c="${chars:0:1}" l="${#chars}"
    if [[ "$c" == "$fence_char" && $l -ge $fence_len ]]; then
      in_fence=0; fence_char=""; fence_len=0
      return 0
    fi
  fi
  return 1
}

# Extract fenced code blocks. One block per stdout line; internal newlines
# encoded as \x1e (record separator) so block boundaries survive command
# substitution. Unclosed fences silently skipped (matches validate.py:65-69).
extract_fences() {
  in_fence=0; fence_char=""; fence_len=0
  local line block=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    if (( in_fence )); then
      if _fence_close_at "$line"; then
        block+=$'\n'"$line"
        printf '%s\n' "${block//$'\n'/$'\x1e'}"
        block=""
      else
        block+=$'\n'"$line"
      fi
    elif _fence_open_at "$line"; then
      block="$line"
    fi
  done < "$1"
}

# Headings: prints "<level>\t<text>" per heading, one per line.
extract_headings() {
  local line
  while IFS= read -r line; do
    if [[ "$line" =~ ^(#{1,6})[[:space:]]+(.+)$ ]]; then
      printf '%s\t%s\n' "${#BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    fi
  done < "$1"
}

extract_urls() {
  grep -oE 'https?://[^[:space:])]+' "$1" | sort -u || true
}

extract_paths() {
  # Pragmatic port of validate.py:7 — POSIX ERE. WARN-level only.
  grep -oE '(\./|\.\./|/|[A-Za-z]:\\)[[:alnum:]_./\\-]+|[[:alnum:]_.\-]+[/\\][[:alnum:]_./\\-]+' "$1" \
    | sort -u || true
}

count_bullets() {
  local n
  n=$(grep -cE '^[[:space:]]*[-*+][[:space:]]+' "$1" || true)
  echo "${n:-0}"
}

# Inline codes: fence-aware walker. Outputs "count\tcode" per unique code,
# sorted by code (so comm can compare multisets).
extract_inline_codes_counter() {
  in_fence=0; fence_char=""; fence_len=0
  declare -A count=()
  local line
  while IFS= read -r line; do
    if (( in_fence )); then
      _fence_close_at "$line" || true
      continue
    fi
    if _fence_open_at "$line"; then continue; fi
    # extract backtick-delimited spans; iterate via BASH_REMATCH consumption
    while [[ "$line" =~ \`([^\`]+)\` ]]; do
      local code="${BASH_REMATCH[1]}"
      count[$code]=$(( ${count[$code]:-0} + 1 ))
      line="${line#*"${BASH_REMATCH[0]}"}"
    done
  done < "$1"
  for k in "${!count[@]}"; do
    printf '%d\t%s\n' "${count[$k]}" "$k"
  done | sort -k2
}

# --- validators ---

validate_headings() {
  local o c co cc
  o="$(extract_headings "$orig")"
  c="$(extract_headings "$comp")"
  co=$(printf '%s\n' "$o" | grep -c . || true)
  cc=$(printf '%s\n' "$c" | grep -c . || true)
  co=${co:-0}; cc=${cc:-0}
  if [[ "$co" != "$cc" ]]; then
    err "heading count mismatch: $co vs $cc"
  fi
  if [[ -n "$o" && "$o" != "$c" ]]; then
    warn "heading text/order changed"
  fi
}

validate_code_blocks() {
  local o c nb_o nb_c
  o="$(extract_fences "$orig")"
  c="$(extract_fences "$comp")"
  nb_o=$(printf '%s\n' "$o" | grep -c . || true)
  nb_c=$(printf '%s\n' "$c" | grep -c . || true)
  nb_o=${nb_o:-0}; nb_c=${nb_c:-0}
  if [[ "$nb_o" == "0" && "$nb_c" == "0" ]]; then return; fi
  if [[ "$nb_o" != "$nb_c" ]]; then
    err "code block count mismatch: $nb_o vs $nb_c"
  elif [[ "$o" != "$c" ]]; then
    warn "code block content drifted (cavemanize is line-agnostic about fences)"
  fi
}

validate_urls() {
  local o c lost added
  o="$(extract_urls "$orig")"
  c="$(extract_urls "$comp")"
  lost=$(comm -23 <(printf '%s\n' "$o") <(printf '%s\n' "$c") || true)
  added=$(comm -13 <(printf '%s\n' "$o") <(printf '%s\n' "$c") || true)
  if [[ -n "$lost" ]]; then
    err "URL lost: $(echo "$lost" | tr '\n' ' ' | sed 's/ $//')"
  fi
  if [[ -n "$added" ]]; then
    warn "URL added: $(echo "$added" | tr '\n' ' ' | sed 's/ $//')"
  fi
}

validate_paths() {
  local o c lost added
  o="$(extract_paths "$orig")"
  c="$(extract_paths "$comp")"
  lost=$(comm -23 <(printf '%s\n' "$o") <(printf '%s\n' "$c") || true)
  added=$(comm -13 <(printf '%s\n' "$o") <(printf '%s\n' "$c") || true)
  if [[ -n "${lost}${added}" ]]; then
    warn "path set drift: lost=[$(echo "$lost" | tr '\n' ',' | sed 's/,$//')], added=[$(echo "$added" | tr '\n' ',' | sed 's/,$//')]"
  fi
}

validate_bullets() {
  local b1 b2 diff
  b1=$(count_bullets "$orig")
  b2=$(count_bullets "$comp")
  if [[ "$b1" == "0" ]]; then return; fi
  diff=$(awk -v a="$b1" -v b="$b2" 'BEGIN { d = a - b; if (d < 0) d = -d; printf "%.0f", (d / a) * 100 }')
  if [[ "$diff" -gt 15 ]]; then
    warn "bullet count drift: $b1 -> $b2 (${diff}%)"
  fi
}

validate_inline_codes() {
  local o c lost added
  o="$(extract_inline_codes_counter "$orig")"
  c="$(extract_inline_codes_counter "$comp")"
  lost=$(comm -23 <(printf '%s\n' "$o") <(printf '%s\n' "$c") || true)
  added=$(comm -13 <(printf '%s\n' "$o") <(printf '%s\n' "$c") || true)
  if [[ -n "$lost" ]]; then
    err "inline code lost or reduced: $(echo "$lost" | tr '\n' ';' | sed 's/;$//')"
  fi
  if [[ -n "$added" ]]; then
    warn "inline code added: $(echo "$added" | tr '\n' ';' | sed 's/;$//')"
  fi
}

validate_headings
validate_code_blocks
validate_urls
validate_paths
validate_bullets
validate_inline_codes

if [[ "$errors" -gt 0 ]]; then
  echo "Valid: no"
  exit 1
fi
echo "Valid: yes"
exit 0