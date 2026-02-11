#!/usr/bin/env bash
set -euo pipefail

REPO="{{GITHUB_OWNER}}/{{REPO_NAME}}"
MARKETPLACE="{{MARKETPLACE_NAME}}"

echo "=== Marketplace: Install All Plugins ==="

# Check prerequisites
if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found. Install Claude Code first."
  exit 1
fi

# Add the repository as a private marketplace
echo "Adding marketplace: $REPO ..."
claude plugin marketplace add "$REPO"

# Auto-discover and install all plugins
FOUND=0
for plugin_dir in plugins/*/; do
  [[ -d "$plugin_dir" ]] || continue
  [[ -f "${plugin_dir}.claude-plugin/plugin.json" ]] || continue

  PLUGIN_NAME=$(python3 -c "import json; print(json.load(open('${plugin_dir}.claude-plugin/plugin.json'))['name'])")
  PLUGIN="${PLUGIN_NAME}@${MARKETPLACE}"
  FOUND=1

  echo ""
  echo "Installing plugin: $PLUGIN ..."
  claude plugin install "$PLUGIN"
done

if [[ $FOUND -eq 0 ]]; then
  echo ""
  echo "No plugins found. Create one first:"
  echo "  ./create-plugin.sh <name> \"<description>\""
  exit 0
fi

# Verify installation
echo ""
echo "Verifying installation ..."
claude plugin list 2>/dev/null || true
echo ""
echo "Done. Run '/plugin' in Claude Code to confirm."
