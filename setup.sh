#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# setup.sh — Interactive setup for Claude Code plugin template
# ─────────────────────────────────────────────────────────────
# Prompts for all 12 placeholder values, replaces them across
# the repo, renames directories/files, and optionally removes
# itself when done.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Detect sed in-place syntax (macOS vs Linux)
if sed --version 2>/dev/null | grep -q GNU; then
  SED_INPLACE=(sed -i)
else
  SED_INPLACE=(sed -i '')
fi

# ── Helpers ──────────────────────────────────────────────────

prompt_value() {
  local var_name="$1"
  local description="$2"
  local example="$3"
  local default="${4:-}"
  local value=""

  while [[ -z "$value" ]]; do
    if [[ -n "$default" ]]; then
      printf "\n%s\n  %s (e.g., %s)\n  [default: %s]: " "$var_name" "$description" "$example" "$default"
    else
      printf "\n%s\n  %s (e.g., %s)\n  : " "$var_name" "$description" "$example"
    fi
    read -r value
    if [[ -z "$value" && -n "$default" ]]; then
      value="$default"
    fi
    if [[ -z "$value" ]]; then
      echo "  Value cannot be empty. Please try again."
    fi
  done

  echo "$value"
}

replace_placeholder() {
  local placeholder="$1"
  local value="$2"
  shift 2
  local files=("$@")

  # Use | as delimiter to avoid issues with / in values
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      "${SED_INPLACE[@]}" "s|{{${placeholder}}}|${value}|g" "$file"
    fi
  done
}

# ── Banner ───────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Claude Code Plugin — Interactive Setup             ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Answer the prompts below to configure your plugin.  ║"
echo "║  Press Enter to accept [default] values.             ║"
echo "╚══════════════════════════════════════════════════════╝"

# ── Collect values ───────────────────────────────────────────

GITHUB_OWNER=$(prompt_value "GITHUB_OWNER" "GitHub username or org" "janedoe")
REPO_NAME=$(prompt_value "REPO_NAME" "Repository name" "ai-agent-backend")
PLUGIN_NAME=$(prompt_value "PLUGIN_NAME" "Plugin identifier (kebab-case)" "backend")
PLUGIN_DESCRIPTION=$(prompt_value "PLUGIN_DESCRIPTION" "One-line plugin description" "AI agents for backend development")
AUTHOR_NAME=$(prompt_value "AUTHOR_NAME" "Author display name" "Jane Doe")
PLUGIN_VERSION=$(prompt_value "PLUGIN_VERSION" "Initial semver version" "0.1.0" "0.1.0")
PLUGIN_CATEGORY=$(prompt_value "PLUGIN_CATEGORY" "Marketplace category" "development" "development")
AGENT_NAME=$(prompt_value "AGENT_NAME" "Agent identifier (kebab-case)" "backend-developer")
AGENT_DISPLAY_NAME=$(prompt_value "AGENT_DISPLAY_NAME" "Human-readable agent name" "Backend Developer")
AGENT_DESCRIPTION_SHORT=$(prompt_value "AGENT_DESCRIPTION_SHORT" "One-sentence agent summary" "A backend developer agent")
AGENT_ROLE=$(prompt_value "AGENT_ROLE" "Role line (follows 'You are')" "a senior backend developer with deep expertise in server-side architecture")
AGENT_COLOR=$(prompt_value "AGENT_COLOR" "Agent color in Claude Code" "green, blue, red, yellow, cyan, magenta" "blue")

# ── Confirm ──────────────────────────────────────────────────

echo ""
echo "─────────────────────────────────────────────────────"
echo "  Review your values:"
echo "─────────────────────────────────────────────────────"
echo "  GITHUB_OWNER:          $GITHUB_OWNER"
echo "  REPO_NAME:             $REPO_NAME"
echo "  PLUGIN_NAME:           $PLUGIN_NAME"
echo "  PLUGIN_DESCRIPTION:    $PLUGIN_DESCRIPTION"
echo "  AUTHOR_NAME:           $AUTHOR_NAME"
echo "  PLUGIN_VERSION:        $PLUGIN_VERSION"
echo "  PLUGIN_CATEGORY:       $PLUGIN_CATEGORY"
echo "  AGENT_NAME:            $AGENT_NAME"
echo "  AGENT_DISPLAY_NAME:    $AGENT_DISPLAY_NAME"
echo "  AGENT_DESCRIPTION_SHORT: $AGENT_DESCRIPTION_SHORT"
echo "  AGENT_ROLE:            $AGENT_ROLE"
echo "  AGENT_COLOR:           $AGENT_COLOR"
echo "─────────────────────────────────────────────────────"
echo ""
printf "Proceed with these values? [Y/n]: "
read -r confirm
if [[ "$confirm" =~ ^[Nn] ]]; then
  echo "Aborted. Run setup.sh again to start over."
  exit 0
fi

# ── Replace placeholders ────────────────────────────────────

echo ""
echo "Replacing placeholders..."

replace_placeholder "GITHUB_OWNER" "$GITHUB_OWNER" \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  install.sh update.sh uninstall.sh \
  README.md CLAUDE.md

replace_placeholder "REPO_NAME" "$REPO_NAME" \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  install.sh update.sh uninstall.sh \
  README.md CLAUDE.md

replace_placeholder "PLUGIN_NAME" "$PLUGIN_NAME" \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  plugins/my-plugin/README.md \
  plugins/my-plugin/commands/commands.md \
  install.sh update.sh uninstall.sh \
  README.md CLAUDE.md docs/FEATURES.md

replace_placeholder "PLUGIN_DESCRIPTION" "$PLUGIN_DESCRIPTION" \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  plugins/my-plugin/README.md \
  README.md

replace_placeholder "AUTHOR_NAME" "$AUTHOR_NAME" \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json

replace_placeholder "PLUGIN_VERSION" "$PLUGIN_VERSION" \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  CLAUDE.md

replace_placeholder "PLUGIN_CATEGORY" "$PLUGIN_CATEGORY" \
  .claude-plugin/marketplace.json

replace_placeholder "AGENT_NAME" "$AGENT_NAME" \
  plugins/my-plugin/agents/my-agent.md \
  README.md CLAUDE.md docs/FEATURES.md

replace_placeholder "AGENT_DISPLAY_NAME" "$AGENT_DISPLAY_NAME" \
  README.md

replace_placeholder "AGENT_DESCRIPTION_SHORT" "$AGENT_DESCRIPTION_SHORT" \
  README.md docs/FEATURES.md

replace_placeholder "AGENT_ROLE" "$AGENT_ROLE" \
  plugins/my-plugin/agents/my-agent.md

replace_placeholder "AGENT_COLOR" "$AGENT_COLOR" \
  plugins/my-plugin/agents/my-agent.md

echo "  Done."

# ── Rename directories and files ─────────────────────────────

echo ""
echo "Renaming directories and files..."

# Update source path in marketplace.json before renaming
"${SED_INPLACE[@]}" "s|./plugins/my-plugin|./plugins/${PLUGIN_NAME}|g" .claude-plugin/marketplace.json

# Rename agent file
mv "plugins/my-plugin/agents/my-agent.md" "plugins/my-plugin/agents/${AGENT_NAME}.md"

# Rename plugin directory
mv "plugins/my-plugin" "plugins/${PLUGIN_NAME}"

echo "  plugins/my-plugin/ → plugins/${PLUGIN_NAME}/"
echo "  my-agent.md → ${AGENT_NAME}.md"

# ── Make scripts executable ──────────────────────────────────

chmod +x install.sh update.sh uninstall.sh
echo ""
echo "Made lifecycle scripts executable."

# ── Summary ──────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Setup complete!                                    ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Customize the agent:  plugins/${PLUGIN_NAME}/agents/${AGENT_NAME}.md"
echo "     - Update the examples in the frontmatter"
echo "     - Replace Core Competencies (marked <!-- CUSTOMIZE -->)"
echo "  2. Review the commands:  plugins/${PLUGIN_NAME}/commands/"
echo "  3. Commit and push:"
echo "     git add -A && git commit -m 'Initial plugin setup'"
echo "     git remote add origin git@github.com:${GITHUB_OWNER}/${REPO_NAME}.git"
echo "     git push -u origin main"
echo "  4. Install: ./install.sh"
echo ""

# ── Self-cleanup ─────────────────────────────────────────────

printf "Remove setup files (setup.sh and SETUP.md)? [Y/n]: "
read -r cleanup
if [[ ! "$cleanup" =~ ^[Nn] ]]; then
  rm -f setup.sh SETUP.md
  echo "Removed setup.sh and SETUP.md."
else
  echo "Kept setup.sh and SETUP.md. Delete them manually when ready."
fi

echo ""
echo "Done. Happy building!"
