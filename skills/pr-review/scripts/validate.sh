#!/usr/bin/env bash
# validate.sh — deterministic hard-rule pass over a PR diff.
# Language-agnostic: secret patterns + diff sanity on ADDED lines only.
# Findings are data (printed as FAIL lines), not gate failures — exit 0 always.
#
# Usage: validate.sh <diff-file>
set -uo pipefail

DIFF="${1:?usage: validate.sh <diff-file>}"
[[ -f "$DIFF" ]] || { echo "FAIL: diff file not found: $DIFF"; exit 0; }

# added lines only, strip the leading '+', skip the +++ headers
added=$(grep -E '^\+' "$DIFF" | grep -vE '^\+\+\+' || true)

if [[ -z "$added" ]]; then
    echo "PASS: no added lines (empty diff or deletion-only)"
    exit 0
fi

found=0
check() { # $1=label $2=ere-pattern
    local hits
    hits=$(grep -nEi "$2" <<<"$added" || true)
    if [[ -n "$hits" ]]; then
        found=1
        while IFS= read -r h; do
            echo "FAIL: $1 — added line: ${h:0:120}"
        done <<<"$hits"
    fi
}

check "private key material"        'BEGIN [A-Z ]*PRIVATE KEY'
check "hardcoded api key"           '(api[_-]?key|apikey|access[_-]?token|secret[_-]?key)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{12,}'
check "bearer/vendor token literal" '(sk|pk|xox[baprs]|ghp|gho|github_pat)_[A-Za-z0-9_]{16,}'
check "password assignment"         '(password|passwd|pwd)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{6,}'
check "private ipv4 literal"        '\b(10\.[0-9]{1,3}|192\.168\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3})\.[0-9]{1,3}\b'

[[ "$found" -eq 0 ]] && echo "PASS: hard rules clean ($(wc -l <<<"$added") added lines scanned)"
exit 0
