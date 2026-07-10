#!/usr/bin/env bash
# Generates the deployable IVeS patch (theme + install.sh) from the diff
# between the master merge-base and the current working tree, scoped to
# themes/ and tools/install.sh.
#
# It is a plain text-only unified diff (the theme PNG is excluded) so git-less
# AlmaLinux 9 targets can apply it with `patch -p1 < omb-ives.patch`.
#
# Output: dist/omb-ives.patch (fixed asset name)
#   The master commit this branch diverged from is reported below and used as
#   the release title (omb-ives-<master-commit>); the asset name is fixed.
#
# Env:
#   OMB_MASTER_REF   Ref used as the master baseline (auto-detected between
#                    'master' and 'origin/master' when unset).
#
# Usage:
#   bash tools/generate_patch.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if ! command -v git &>/dev/null; then
  echo "Error: git is required to generate the patch." >&2
  exit 1
fi

cd "$REPO_ROOT"

if ! git rev-parse --git-dir &>/dev/null; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi

# Resolve the master baseline (local checkout uses 'master'; CI checkouts
# usually only have the remote-tracking 'origin/master').
MASTER_REF="${OMB_MASTER_REF:-}"
if [[ -z "$MASTER_REF" ]]; then
  if git rev-parse --verify --quiet master >/dev/null; then
    MASTER_REF="master"
  elif git rev-parse --verify --quiet refs/remotes/origin/master >/dev/null; then
    MASTER_REF="origin/master"
  else
    echo "Error: cannot resolve a 'master' ref (set OMB_MASTER_REF)." >&2
    exit 1
  fi
fi

# Base commit = the master commit this branch diverged from. It identifies the
# release (omb-ives-<master-commit>).
BASE_COMMIT="$(git merge-base "$MASTER_REF" HEAD)"
MASTER_COMMIT="$(git rev-parse --short "$BASE_COMMIT")"

DIST_DIR="$REPO_ROOT/dist"
PATCH_NAME="omb-ives.patch"
PATCH_FILE="$DIST_DIR/$PATCH_NAME"

mkdir -p "$DIST_DIR"

# Text-only diff (no --binary): the target applies it with patch(1), which
# cannot handle binary hunks, so the theme PNG is excluded from the patch (it
# stays in the repo, it just is not shipped).
git diff "$BASE_COMMIT" -- \
  themes/ \
  ':(exclude)themes/clear_and_strict/clear_and_strict.png' \
  tools/install.sh \
  > "$PATCH_FILE"

echo "Patch generated: $PATCH_FILE"
echo "  master ref:    $MASTER_REF"
echo "  master commit: $MASTER_COMMIT ($BASE_COMMIT)"
echo "  size:          $(wc -c < "$PATCH_FILE") bytes, $(wc -l < "$PATCH_FILE") lines"
echo "Files included:"
grep "^diff --git" "$PATCH_FILE" | awk '{print "  -", substr($3, 3)}'

cat <<EOF

Next step - publish the release with the patch as its only asset:

  gh release create "omb-ives-$MASTER_COMMIT" \\
    --title "omb-ives-$MASTER_COMMIT" \\
    --generate-notes \\
    "$PATCH_FILE"
EOF
