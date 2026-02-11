#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# create-plugin.sh — Scaffold a new plugin in this marketplace
# ─────────────────────────────────────────────────────────────
# Usage: ./create-plugin.sh <plugin-name> "<description>"
#
# Creates a fully-structured plugin directory under plugins/
# and registers it in .claude-plugin/marketplace.json.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Configuration (replaced by setup.sh) ─────────────────────

MARKETPLACE="{{MARKETPLACE_NAME}}"
REPO="{{GITHUB_OWNER}}/{{REPO_NAME}}"
AUTHOR="{{AUTHOR_NAME}}"

# ── Validate arguments ───────────────────────────────────────

if [[ $# -lt 2 ]]; then
  echo "Usage: ./create-plugin.sh <plugin-name> \"<description>\""
  echo ""
  echo "  plugin-name   Kebab-case identifier (e.g., backend-tools)"
  echo "  description   One-line plugin description"
  echo ""
  echo "Example:"
  echo "  ./create-plugin.sh backend-tools \"AI agents for backend development\""
  exit 1
fi

PLUGIN_NAME="$1"
PLUGIN_DESCRIPTION="$2"

# Validate plugin name format
if [[ ! "$PLUGIN_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Error: Plugin name must start with a lowercase letter and contain only"
  echo "       lowercase letters, numbers, and hyphens (e.g., 'my-plugin')."
  exit 1
fi

PLUGIN_DIR="plugins/${PLUGIN_NAME}"

# Check for duplicates
if [[ -d "$PLUGIN_DIR" ]]; then
  echo "Error: Plugin directory already exists: ${PLUGIN_DIR}"
  exit 1
fi

# ── Create plugin directory structure ────────────────────────

echo "Creating plugin: ${PLUGIN_NAME}"
echo ""

mkdir -p "${PLUGIN_DIR}/.claude-plugin"
mkdir -p "${PLUGIN_DIR}/agents"
mkdir -p "${PLUGIN_DIR}/commands"
mkdir -p "${PLUGIN_DIR}/docs"
mkdir -p "${PLUGIN_DIR}/skills"

# ── .claude-plugin/plugin.json ───────────────────────────────

cat > "${PLUGIN_DIR}/.claude-plugin/plugin.json" << EOF
{
  "name": "${PLUGIN_NAME}",
  "description": "${PLUGIN_DESCRIPTION}",
  "version": "0.1.0",
  "author": {
    "name": "${AUTHOR}"
  },
  "repository": "https://github.com/${REPO}"
}
EOF

echo "  Created ${PLUGIN_DIR}/.claude-plugin/plugin.json"

# ── agents/.gitkeep ──────────────────────────────────────────

touch "${PLUGIN_DIR}/agents/.gitkeep"
echo "  Created ${PLUGIN_DIR}/agents/.gitkeep"

# ── skills/.gitkeep ──────────────────────────────────────────

touch "${PLUGIN_DIR}/skills/.gitkeep"
echo "  Created ${PLUGIN_DIR}/skills/.gitkeep"

# ── commands/commands.md ─────────────────────────────────────

cat > "${PLUGIN_DIR}/commands/commands.md" << 'CMDEOF'
---
description: "Display the quick-reference table of all commands"
model: "haiku"
---

# /commands

Show all available commands for this plugin.

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/commands` | — | Display this quick-reference table |
CMDEOF

echo "  Created ${PLUGIN_DIR}/commands/commands.md"

# ── docs/FEATURES.md ─────────────────────────────────────────

cat > "${PLUGIN_DIR}/docs/FEATURES.md" << EOF
# ${PLUGIN_NAME} — Feature Reference

## Agents

| Agent | Description |
|-------|-------------|
| *(none yet)* | Add agents to \`agents/\` |

## Skills

| Skill | Description |
|-------|-------------|
| *(none yet)* | Add skills to \`skills/\` |

## Commands

| Command | Arguments | Description |
|---------|-----------|-------------|
| \`/commands\` | — | Display the quick-reference table of all commands |
EOF

echo "  Created ${PLUGIN_DIR}/docs/FEATURES.md"

# ── install.sh (per-plugin) ─────────────────────────────────

cat > "${PLUGIN_DIR}/install.sh" << EOF
#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO}"
PLUGIN="${PLUGIN_NAME}@${MARKETPLACE}"

echo "=== ${PLUGIN_NAME}: Install ==="

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found. Install Claude Code first."
  exit 1
fi

# Ensure marketplace is registered
echo "Ensuring marketplace is registered ..."
claude plugin marketplace add "\$REPO" 2>/dev/null || true

echo "Installing plugin: \$PLUGIN ..."
claude plugin install "\$PLUGIN"

echo ""
echo "Verifying installation ..."
if claude plugin list 2>/dev/null | grep -q "${PLUGIN_NAME}"; then
  echo "Success: ${PLUGIN_NAME} is installed."
else
  echo "Warning: Could not verify installation. Run '/plugin' in Claude Code to check."
fi
EOF

chmod +x "${PLUGIN_DIR}/install.sh"
echo "  Created ${PLUGIN_DIR}/install.sh"

# ── update.sh (per-plugin) ──────────────────────────────────

cat > "${PLUGIN_DIR}/update.sh" << EOF
#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO}"
PLUGIN="${PLUGIN_NAME}@${MARKETPLACE}"

echo "=== ${PLUGIN_NAME}: Update ==="

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found."
  exit 1
fi

echo "Updating marketplace: \$REPO ..."
claude plugin marketplace update "\$REPO"

echo "Updating plugin: \$PLUGIN ..."
claude plugin update "\$PLUGIN"

echo ""
echo "Verifying update ..."
if claude plugin list 2>/dev/null | grep -q "${PLUGIN_NAME}"; then
  echo "Success: ${PLUGIN_NAME} is up to date."
else
  echo "Warning: Could not verify update. Run '/plugin' in Claude Code to check."
fi
EOF

chmod +x "${PLUGIN_DIR}/update.sh"
echo "  Created ${PLUGIN_DIR}/update.sh"

# ── uninstall.sh (per-plugin) ───────────────────────────────

cat > "${PLUGIN_DIR}/uninstall.sh" << EOF
#!/usr/bin/env bash
set -euo pipefail

PLUGIN="${PLUGIN_NAME}@${MARKETPLACE}"

echo "=== ${PLUGIN_NAME}: Uninstall ==="

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found."
  exit 1
fi

echo "Uninstalling plugin: \$PLUGIN ..."
claude plugin uninstall "\$PLUGIN"

echo ""
echo "Verifying removal ..."
if claude plugin list 2>/dev/null | grep -q "${PLUGIN_NAME}"; then
  echo "Warning: Plugin may still be listed. Run '/plugin' in Claude Code to check."
else
  echo "Success: ${PLUGIN_NAME} has been removed."
fi
EOF

chmod +x "${PLUGIN_DIR}/uninstall.sh"
echo "  Created ${PLUGIN_DIR}/uninstall.sh"

# ── README.md (per-plugin) ──────────────────────────────────

cat > "${PLUGIN_DIR}/README.md" << EOF
# ${PLUGIN_NAME}

${PLUGIN_DESCRIPTION}

## Installation

\`\`\`bash
# From the plugin directory:
./install.sh

# Or from the marketplace root:
./install.sh
\`\`\`

## Update

\`\`\`bash
./update.sh
\`\`\`

## Uninstall

\`\`\`bash
./uninstall.sh
\`\`\`

## Directory Structure

\`\`\`
${PLUGIN_NAME}/
├── .claude-plugin/
│   └── plugin.json    # Plugin manifest
├── agents/            # Agent definitions
├── commands/          # Command definitions
├── docs/
│   └── FEATURES.md    # Feature catalog for this plugin
├── skills/            # Skill definitions
├── install.sh         # Install this plugin
├── update.sh          # Update this plugin
├── uninstall.sh       # Uninstall this plugin
└── README.md
\`\`\`

## Adding Features

1. **Agent** — Add a definition file to \`agents/\`
2. **Skill** — Add a definition file to \`skills/\`
3. **Command** — Add a definition file to \`commands/\`
4. Bump the \`version\` in \`.claude-plugin/plugin.json\` and the root \`.claude-plugin/marketplace.json\`
5. **Update documentation** — Update this \`README.md\` and \`docs/FEATURES.md\`
EOF

echo "  Created ${PLUGIN_DIR}/README.md"

# ── Register in marketplace.json ─────────────────────────────

echo ""
echo "Registering plugin in .claude-plugin/marketplace.json ..."

python3 -c "
import json, sys

with open('.claude-plugin/marketplace.json', 'r') as f:
    data = json.load(f)

new_plugin = {
    'name': '${PLUGIN_NAME}',
    'description': '${PLUGIN_DESCRIPTION}',
    'version': '0.1.0',
    'author': {
        'name': '${AUTHOR}'
    },
    'source': './plugins/${PLUGIN_NAME}',
    'category': 'development'
}

data['plugins'].append(new_plugin)

with open('.claude-plugin/marketplace.json', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"

echo "  Registered ${PLUGIN_NAME} in marketplace.json"

# ── Summary ──────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Plugin created successfully!                       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Add an agent:  ${PLUGIN_DIR}/agents/"
echo "  2. Add skills:    ${PLUGIN_DIR}/skills/"
echo "  3. Add commands:  ${PLUGIN_DIR}/commands/"
echo "  4. Update docs:   ${PLUGIN_DIR}/docs/FEATURES.md"
echo "  5. Install:       ./install.sh"
echo ""
