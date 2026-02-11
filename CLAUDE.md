# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A private multi-plugin Claude Code marketplace (modeled after `anthropics/claude-plugins-official`). Plugins are created dynamically using `create-plugin.sh` and auto-discovered by the root lifecycle scripts.

## Current Plugins

*(none yet — run `./create-plugin.sh <name> "<description>"` to add one)*

## Repository Layout

```
├── .claude-plugin/marketplace.json   # Marketplace manifest (required by CLI)
├── create-plugin.sh                  # Scaffold a new plugin
├── install.sh / update.sh / uninstall.sh  # Root lifecycle scripts (auto-discover plugins)
└── plugins/<plugin-name>/
    ├── .claude-plugin/plugin.json    # Plugin manifest (name, version, metadata)
    ├── agents/                       # Agent definition files
    ├── skills/                       # Skill definition files
    ├── commands/                     # Command definition files
    ├── docs/FEATURES.md              # Per-plugin feature catalog
    ├── install.sh / update.sh / uninstall.sh  # Per-plugin lifecycle scripts
    └── README.md                     # Per-plugin documentation
```

## Key Commands

```bash
# Install all plugins into Claude Code
./install.sh

# Update all plugins to latest
./update.sh

# Remove all plugins
./uninstall.sh

# Create a new plugin
./create-plugin.sh <plugin-name> "<description>"

# Per-plugin lifecycle (from plugin directory)
plugins/<name>/install.sh
plugins/<name>/update.sh
plugins/<name>/uninstall.sh

# Verify plugins are registered
claude plugin list
```

## Definition File Format

### Agent (`agents/<name>.md`)

```yaml
---
name: "<agent-name>"
description: "<one-line description>"
examples:
  - title: "<example title>"
    prompt: "<example prompt>"
model: "sonnet"
color: "blue"
---
```

### Skill (`skills/<name>.md`)

```yaml
---
name: "<skill-name>"
description: "<one-line description>"
model: "sonnet"
---
```

### Command (`commands/<name>.md`)

```yaml
---
description: "<one-line description>"
model: "haiku"
---
```

## Adding a New Feature to an Existing Plugin

1. Add a definition file to the appropriate directory under `plugins/<plugin-name>/`:
   - `agents/` for agent definitions
   - `skills/` for skill definitions
   - `commands/` for command definitions
2. **After implementing any new skill**: Update relevant agents and commands that should reference or use the new skill
3. Bump `version` in both `plugins/<plugin-name>/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
4. Update the plugin's `README.md` and `docs/FEATURES.md` with the new feature

## Adding a New Plugin

```bash
./create-plugin.sh <plugin-name> "<description>"
```

This scaffolds the full plugin structure, registers it in `marketplace.json`, and creates per-plugin lifecycle scripts and documentation.

## Documentation Rules

- **Marketplace-level**: Keep `README.md` and `CLAUDE.md` up to date when adding or removing plugins
- **Plugin-level**: Keep each plugin's `README.md` and `docs/FEATURES.md` up to date when adding, modifying, or removing features within that plugin

Every code change that adds, modifies, or removes functionality must include corresponding documentation updates in the same changeset.

## MCP Servers

The project includes a `.mcp.json` at the repo root that configures shared MCP servers for all contributors.

| Server | Package | Purpose |
|--------|---------|---------|
| `context7` | `@upstash/context7-mcp@latest` | Fetches up-to-date, version-specific documentation and code examples from official sources |

**Documentation Lookup Order:**

1. **Always search Context7 MCP server first** for documentation and code examples
2. Fall back to **Web Search** only if Context7 doesn't have the needed documentation

**Prerequisite:** Node.js and `npx` must be available on the system (Context7 runs via `npx`).

Verify with:
```bash
claude mcp list          # Confirm context7 appears
```

## Marketplace Identifiers

- **Marketplace repo:** `{{GITHUB_OWNER}}/{{REPO_NAME}}`
- **Marketplace name:** `{{MARKETPLACE_NAME}}`
- **Plugin identifier pattern:** `<plugin-name>@{{MARKETPLACE_NAME}}`
