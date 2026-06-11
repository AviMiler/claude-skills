#!/bin/bash
set -euo pipefail

# Install personal skills from AviMiler/claude-skills into ~/.claude/skills/
# Each subfolder with a SKILL.md is symlinked using the canonical `name:` from
# its frontmatter so it becomes available to Claude Code in this session.

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SKILLS_REPO="https://github.com/AviMiler/claude-skills.git"
SKILLS_SOURCE="$HOME/.claude-skills-source"
SKILLS_DEST="$HOME/.claude/skills"

# Reuse the current checkout if this session IS the claude-skills repo;
# otherwise clone/update a cached copy in $HOME.
if [ -f "${CLAUDE_PROJECT_DIR:-}/MY-agentic-code/SKILL.md" ]; then
  SKILLS_SOURCE="$CLAUDE_PROJECT_DIR"
elif [ -d "$SKILLS_SOURCE/.git" ]; then
  git -C "$SKILLS_SOURCE" pull --quiet --ff-only || true
else
  git clone --quiet --depth 1 "$SKILLS_REPO" "$SKILLS_SOURCE"
fi

mkdir -p "$SKILLS_DEST"

for skill_dir in "$SKILLS_SOURCE"/*/; do
  skill_md="${skill_dir}SKILL.md"
  [ -f "$skill_md" ] || continue

  name=$(awk '
    /^---[[:space:]]*$/ { fm = !fm; next }
    fm && /^name:[[:space:]]*/ {
      sub(/^name:[[:space:]]*/, "")
      gsub(/[[:space:]]/, "")
      print
      exit
    }
  ' "$skill_md")

  if [ -z "$name" ]; then
    echo "[skills] skipped ${skill_dir} (no name in frontmatter)" >&2
    continue
  fi

  ln -sfn "${skill_dir%/}" "$SKILLS_DEST/$name"
  echo "[skills] linked $name -> ${skill_dir%/}"
done
