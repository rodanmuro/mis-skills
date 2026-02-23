#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  $0 <project_name> [--base-dir DIR] [--visibility private|public] [--skills-repo OWNER/REPO]
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

PROJECT_NAME="$1"
shift

BASE_DIR="$(pwd)"
VISIBILITY="private"
SKILLS_REPO="rodanmuro/mis-skills"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-dir)
      BASE_DIR="$2"
      shift 2
      ;;
    --visibility)
      VISIBILITY="$2"
      shift 2
      ;;
    --skills-repo)
      SKILLS_REPO="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$VISIBILITY" != "private" && "$VISIBILITY" != "public" ]]; then
  echo "--visibility must be private or public" >&2
  exit 1
fi

command -v git >/dev/null 2>&1 || { echo "git not found" >&2; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "gh not found" >&2; exit 1; }

gh auth status >/dev/null

TARGET_DIR="$BASE_DIR/$PROJECT_NAME"
if [[ -e "$TARGET_DIR" ]]; then
  echo "Target directory already exists: $TARGET_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

pushd "$TARGET_DIR" >/dev/null

git init
printf "# %s\n" "$PROJECT_NAME" > README.md

git add README.md
git commit -m "chore: initial commit"

gh repo create "$PROJECT_NAME" "--$VISIBILITY" --source=. --remote=origin --push

mkdir -p .claude/skills .codex/skills

TMP_DIR="$(mktemp -d /tmp/mis-skills-XXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

gh repo clone "$SKILLS_REPO" "$TMP_DIR/mis-skills" -- --depth 1

while IFS= read -r -d '' d; do
  name="$(basename "$d")"
  cp -a "$d" ".claude/skills/$name"
  cp -a "$d" ".codex/skills/$name"
done < <(find "$TMP_DIR/mis-skills" -mindepth 1 -maxdepth 1 -type d -print0)

rm -rf .claude/skills/.git .codex/skills/.git

if [[ -f "$TMP_DIR/mis-skills/README.md" ]]; then
  cp -a "$TMP_DIR/mis-skills/README.md" .claude/skills/README.md
  cp -a "$TMP_DIR/mis-skills/README.md" .codex/skills/README.md
fi

git add .claude .codex
git commit -m "chore: install base skills for claude and codex"
git push

popd >/dev/null

echo "Project created and published: $TARGET_DIR"
