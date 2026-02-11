# Setup Guide

This template creates a **multi-plugin Claude Code marketplace** repository.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and available as `claude`
- [Node.js](https://nodejs.org/) (provides `npx`, required by the Context7 MCP server)
- Python 3 (used by `create-plugin.sh` for JSON manipulation)

## Quick Start (Recommended)

1. Create a repo from this template (GitHub "Use this template" or clone manually)
2. Run the interactive setup script:

```bash
./setup.sh
```

The script prompts for 5 marketplace-level values, replaces placeholders, and optionally removes itself when done.

3. Create your first plugin:

```bash
./create-plugin.sh my-plugin "Description of my plugin"
```

4. Add agents, skills, and commands to the plugin, then commit and push.

That's it. The rest of this guide documents the manual process if you prefer.

---

## Manual Setup

### Step 1: Clone or Copy This Template

```bash
# If using GitHub template repos:
gh repo create my-repo --template <template-owner>/<template-repo> --private --clone

# Or copy manually:
cp -r template/ /path/to/my-new-repo
cd /path/to/my-new-repo
git init
```

### Step 2: Choose Your Values

Fill in the table below with your project's values:

| Placeholder | Your Value | Description |
|---|---|---|
| `{{GITHUB_OWNER}}` | | GitHub username or org (e.g., `janedoe`) |
| `{{REPO_NAME}}` | | Repository name (e.g., `my-claude-marketplace`) |
| `{{MARKETPLACE_NAME}}` | | Short marketplace identifier, used in `plugin@marketplace` (e.g., `my-marketplace`) |
| `{{MARKETPLACE_DESCRIPTION}}` | | One-line description (e.g., `A collection of Claude Code plugins`) |
| `{{AUTHOR_NAME}}` | | Default author name for plugins (e.g., `Jane Doe`) |

### Step 3: Replace Placeholders

Run these `sed` commands from the repository root. Replace the right-hand values with your choices from Step 2.

> **macOS note:** The `sed -i ''` syntax is for macOS. On Linux, use `sed -i` (without the empty quotes).

```bash
FILES=".claude-plugin/marketplace.json create-plugin.sh install.sh update.sh uninstall.sh README.md CLAUDE.md"

sed -i '' 's|{{GITHUB_OWNER}}|YOUR_GITHUB_OWNER|g' $FILES
sed -i '' 's|{{REPO_NAME}}|YOUR_REPO_NAME|g' $FILES
sed -i '' 's|{{MARKETPLACE_NAME}}|YOUR_MARKETPLACE_NAME|g' $FILES
sed -i '' 's|{{MARKETPLACE_DESCRIPTION}}|YOUR_MARKETPLACE_DESCRIPTION|g' $FILES
sed -i '' 's|{{AUTHOR_NAME}}|YOUR_AUTHOR_NAME|g' $FILES
```

### Step 4: Make Scripts Executable

```bash
chmod +x install.sh update.sh uninstall.sh create-plugin.sh
```

### Step 5: Create Your First Plugin

```bash
./create-plugin.sh my-plugin "Description of my plugin"
```

This scaffolds a complete plugin directory and registers it in `marketplace.json`.

### Step 6: Add Features to the Plugin

Add agent, skill, and command definition files to the plugin directory:

- `plugins/my-plugin/agents/` for agent definitions
- `plugins/my-plugin/skills/` for skill definitions
- `plugins/my-plugin/commands/` for command definitions

### Step 7: Initialize and Push

```bash
git add -A
git commit -m "Initial marketplace setup"
git remote add origin git@github.com:YOUR_GITHUB_OWNER/YOUR_REPO_NAME.git
git push -u origin main
```

### Step 8: Install and Test

```bash
./install.sh
```

Then open Claude Code and verify:
- Your agents trigger for relevant questions
- `/commands` works correctly
- `/plugin` shows your plugins as installed

### Step 9: Clean Up

Once everything works, you can delete this `SETUP.md` file:

```bash
rm SETUP.md
git add -A && git commit -m "Remove setup guide"
```

### Quick Reference

After setup and creating a plugin, your repo structure will look like:

```
├── .claude-plugin/
│   └── marketplace.json
├── .claude/
│   └── settings.local.json
├── .mcp.json
├── .gitignore
├── CLAUDE.md
├── README.md
├── create-plugin.sh
├── install.sh
├── update.sh
├── uninstall.sh
└── plugins/my-plugin/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── agents/
    ├── commands/
    │   └── commands.md
    ├── docs/
    │   └── FEATURES.md
    ├── skills/
    ├── install.sh
    ├── update.sh
    ├── uninstall.sh
    └── README.md
```
