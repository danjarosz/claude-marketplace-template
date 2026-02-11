#!/usr/bin/env bash
set -euo pipefail

REPO="{{GITHUB_OWNER}}/{{REPO_NAME}}"
MARKETPLACE="{{MARKETPLACE_NAME}}"

echo "=== Marketplace: Update All Plugins ==="

# Check prerequisites
if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found."
  exit 1
fi

# Update the marketplace (pulls latest from git)
echo "Updating marketplace: $REPO ..."
claude plugin marketplace update "$REPO"

# Auto-discover and update all plugins
FOUND=0
for plugin_dir in plugins/*/; do
  [[ -d "$plugin_dir" ]] || continue
  [[ -f "${plugin_dir}.claude-plugin/plugin.json" ]] || continue

  PLUGIN_NAME=$(python3 -c "import json; print(json.load(open('${plugin_dir}.claude-plugin/plugin.json'))['name'])")
  PLUGIN="${PLUGIN_NAME}@${MARKETPLACE}"
  FOUND=1

  echo ""
  echo "Updating plugin: $PLUGIN ..."
  claude plugin update "$PLUGIN"
done

if [[ $FOUND -eq 0 ]]; then
  echo ""
  echo "No plugins found. Nothing to update."
  exit 0
fi

# Verify update
echo ""
echo "Verifying update ..."
claude plugin list 2>/dev/null || true
echo ""
echo "Done. Run '/plugin' in Claude Code to confirm."
