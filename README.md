# {{REPO_NAME}}

{{MARKETPLACE_DESCRIPTION}}

This repository acts as a **private plugin marketplace** (same pattern as `anthropics/claude-plugins-official`) that can contain multiple plugins. Each plugin is self-contained with its own agents, skills, commands, and lifecycle scripts.

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| *(none yet)* | Run `./create-plugin.sh` to add one | — |

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and available as `claude`
- [Node.js](https://nodejs.org/) (provides `npx`, required by the Context7 MCP server)
- Python 3 (used by `create-plugin.sh` for JSON manipulation)

## Quick Start

### Install all plugins

```bash
./install.sh
```

### Update all plugins

```bash
./update.sh
```

### Uninstall all plugins

```bash
./uninstall.sh
```

### Manual commands

```bash
# Add marketplace
claude plugin marketplace add {{GITHUB_OWNER}}/{{REPO_NAME}}

# Install a specific plugin
claude plugin install <plugin-name>@{{MARKETPLACE_NAME}}

# Update a specific plugin
claude plugin update <plugin-name>@{{MARKETPLACE_NAME}}

# Uninstall a specific plugin
claude plugin uninstall <plugin-name>@{{MARKETPLACE_NAME}}

# Remove marketplace
claude plugin marketplace remove {{GITHUB_OWNER}}/{{REPO_NAME}}
```

After installing, run `/plugin` in Claude Code to confirm plugins are listed and enabled.

## Single Plugin Management

Each plugin has its own lifecycle scripts:

```bash
# Install just one plugin
plugins/<plugin-name>/install.sh

# Update just one plugin
plugins/<plugin-name>/update.sh

# Uninstall just one plugin
plugins/<plugin-name>/uninstall.sh
```

## Repository Structure

```
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest (required by CLI)
├── create-plugin.sh              # Scaffold a new plugin
├── install.sh / update.sh / uninstall.sh  # Root lifecycle scripts (all plugins)
└── plugins/<plugin-name>/
    ├── .claude-plugin/
    │   └── plugin.json           # Plugin manifest
    ├── agents/                   # Agent definitions
    ├── skills/                   # Skill definitions
    ├── commands/                 # Command definitions
    ├── docs/
    │   └── FEATURES.md           # Feature catalog for this plugin
    ├── install.sh / update.sh / uninstall.sh  # Per-plugin lifecycle scripts
    └── README.md
```

## Adding a New Plugin

```bash
./create-plugin.sh <plugin-name> "<description>"
```

This creates the full plugin directory structure, registers it in `marketplace.json`, and generates per-plugin lifecycle scripts and documentation.

**Example:**

```bash
./create-plugin.sh backend-tools "AI agents for backend development"
```

## Adding Features to a Plugin

1. **Agent** — Add a definition file to `plugins/<plugin-name>/agents/`
2. **Skill** — Add a definition file to `plugins/<plugin-name>/skills/`
3. **Command** — Add a definition file to `plugins/<plugin-name>/commands/`
4. Bump the `version` in `plugins/<plugin-name>/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
5. **Update documentation** — Update the plugin's `README.md` and `docs/FEATURES.md`
