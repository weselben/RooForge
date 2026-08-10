#!/usr/bin/env bash
# setup-repo-gh-cli.sh — initialise repo labels and milestones used by wayfinder
# Requires: gh (GitHub CLI) installed and authenticated
# Run once per repo. Idempotent — safe to re-run.

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

echo "Setting up labels for $REPO ..."

# Labels used by wayfinder
LABELS=(
  "wayfinder:map"
  "wayfinder:research"
  "wayfinder:prototype"
  "wayfinder:grilling"
  "wayfinder:task"
)

# Colors (GitHub label color hex)
LABEL_COLOR="0075ca"

for label in "${LABELS[@]}"; do
  if gh label list --repo "$REPO" --json name -q ".[] | select(.name==\"$label\") | .name" 2>/dev/null | grep -q .; then
    echo "  exists: $label"
  else
    gh label create "$label" --repo "$REPO" --color "$LABEL_COLOR" --description "Wayfinder ticket"
    echo "  created: $label"
  fi
done

echo "Done. Labels ready for $REPO."