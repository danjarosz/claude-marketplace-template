#!/usr/bin/env bash
set -euo pipefail

REPO="{{GITHUB_OWNER}}/{{REPO_NAME}}"
MARKETPLACE="{{MARKETPLACE_NAME}}"

echo "=== Marketplace: Uninstall All Plugins ==="

# Check prerequisites
if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found."
  exit 1
fi

# Auto-discover and uninstall all plugins
for plugin_dir in plugins/*/; do
  [[ -d "$plugin_dir" ]] || continue
  [[ -f "${plugin_dir}.claude-plugin/plugin.json" ]] || continue

  PLUGIN_NAME=$(python3 -c "import json; print(json.load(open('${plugin_dir}.claude-plugin/plugin.json'))['name'])")
  PLUGIN="${PLUGIN_NAME}@${MARKETPLACE}"

  echo "Uninstalling plugin: $PLUGIN ..."
  claude plugin uninstall "$PLUGIN"
done

# Remove the marketplace registration
echo ""
echo "Removing marketplace: $REPO ..."
claude plugin marketplace remove "$REPO"

# Verify removal
echo ""
echo "Verifying removal ..."
if claude plugin list 2>/dev/null | grep -q "@${MARKETPLACE}"; then
  echo "Warning: Some plugins may still be listed. Run '/plugin' in Claude Code to check."
else
  echo "Success: All plugins have been removed."
fi
