#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# setup.sh — Interactive setup for Claude Code plugin marketplace
# ─────────────────────────────────────────────────────────────
# Prompts for 5 marketplace-level placeholder values, replaces
# them across the repo, and optionally removes itself when done.
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
echo "║   Claude Code Marketplace — Interactive Setup        ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Answer the prompts below to configure your          ║"
echo "║  marketplace. Press Enter to accept [default] values.║"
echo "╚══════════════════════════════════════════════════════╝"

# ── Collect values ───────────────────────────────────────────

GITHUB_OWNER=$(prompt_value "GITHUB_OWNER" "GitHub username or org" "janedoe")
REPO_NAME=$(prompt_value "REPO_NAME" "Repository name" "my-claude-marketplace")
MARKETPLACE_NAME=$(prompt_value "MARKETPLACE_NAME" "Short marketplace identifier (used in plugin@marketplace)" "my-marketplace")
MARKETPLACE_DESCRIPTION=$(prompt_value "MARKETPLACE_DESCRIPTION" "One-line marketplace description" "A collection of Claude Code plugins")
AUTHOR_NAME=$(prompt_value "AUTHOR_NAME" "Default author name for plugins" "Jane Doe")

# ── Confirm ──────────────────────────────────────────────────

echo ""
echo "─────────────────────────────────────────────────────"
echo "  Review your values:"
echo "─────────────────────────────────────────────────────"
echo "  GITHUB_OWNER:            $GITHUB_OWNER"
echo "  REPO_NAME:               $REPO_NAME"
echo "  MARKETPLACE_NAME:        $MARKETPLACE_NAME"
echo "  MARKETPLACE_DESCRIPTION: $MARKETPLACE_DESCRIPTION"
echo "  AUTHOR_NAME:             $AUTHOR_NAME"
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

# Files that contain marketplace-level placeholders
TARGET_FILES=(
  .claude-plugin/marketplace.json
  create-plugin.sh
  install.sh
  update.sh
  uninstall.sh
  README.md
  CLAUDE.md
)

replace_placeholder "GITHUB_OWNER" "$GITHUB_OWNER" "${TARGET_FILES[@]}"
replace_placeholder "REPO_NAME" "$REPO_NAME" "${TARGET_FILES[@]}"
replace_placeholder "MARKETPLACE_NAME" "$MARKETPLACE_NAME" "${TARGET_FILES[@]}"
replace_placeholder "MARKETPLACE_DESCRIPTION" "$MARKETPLACE_DESCRIPTION" "${TARGET_FILES[@]}"
replace_placeholder "AUTHOR_NAME" "$AUTHOR_NAME" "${TARGET_FILES[@]}"

echo "  Done."

# ── Make scripts executable ──────────────────────────────────

chmod +x install.sh update.sh uninstall.sh create-plugin.sh
echo ""
echo "Made all scripts executable."

# ── Summary ──────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Setup complete!                                    ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Create your first plugin:"
echo "     ./create-plugin.sh my-plugin \"My first plugin\""
echo "  2. Add agents, skills, and commands to the plugin"
echo "  3. Commit and push:"
echo "     git add -A && git commit -m 'Initial marketplace setup'"
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
