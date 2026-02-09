# Setup Guide

This template creates a **Claude Code plugin marketplace** repository.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and available as `claude`
- [Node.js](https://nodejs.org/) (provides `npx`, required by the Context7 MCP server)

## Quick Start (Recommended)

1. Create a repo from this template (GitHub "Use this template" or clone manually)
2. Run the interactive setup script:

```bash
./setup.sh
```

The script prompts for all 12 values, replaces placeholders, renames directories/files, and optionally removes itself when done.

3. Customize your agent (Core Competencies, examples) and commit.

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
| `{{REPO_NAME}}` | | Repository name (e.g., `ai-agent-backend`) |
| `{{PLUGIN_NAME}}` | | Plugin identifier, kebab-case (e.g., `backend`) |
| `{{PLUGIN_DESCRIPTION}}` | | One-line description (e.g., `AI agents for backend development`) |
| `{{AUTHOR_NAME}}` | | Your display name (e.g., `Jane Doe`) |
| `{{PLUGIN_VERSION}}` | | Initial semver version (e.g., `0.1.0`) |
| `{{PLUGIN_CATEGORY}}` | | Marketplace category (e.g., `development`) |
| `{{AGENT_NAME}}` | | Agent identifier, kebab-case (e.g., `backend-developer`) |
| `{{AGENT_DISPLAY_NAME}}` | | Human-readable agent name (e.g., `Backend Developer`) |
| `{{AGENT_DESCRIPTION_SHORT}}` | | One-sentence agent summary (e.g., `A backend developer agent`) |
| `{{AGENT_ROLE}}` | | Role description following "You are" (e.g., `a senior backend developer with deep expertise in server-side architecture`) |
| `{{AGENT_COLOR}}` | | Agent color in Claude Code (e.g., `green`, `blue`, `red`, `yellow`, `cyan`, `magenta`) |

### Step 3: Replace Placeholders

Run these `sed` commands from the repository root. Replace the right-hand values with your choices from Step 2.

> **macOS note:** The `sed -i ''` syntax is for macOS. On Linux, use `sed -i` (without the empty quotes).

```bash
# --- Identity placeholders ---
sed -i '' 's/{{GITHUB_OWNER}}/YOUR_GITHUB_OWNER/g' \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  install.sh update.sh uninstall.sh \
  README.md CLAUDE.md

sed -i '' 's/{{REPO_NAME}}/YOUR_REPO_NAME/g' \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  install.sh update.sh uninstall.sh \
  README.md CLAUDE.md

sed -i '' 's/{{PLUGIN_NAME}}/YOUR_PLUGIN_NAME/g' \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  plugins/my-plugin/README.md \
  plugins/my-plugin/commands/commands.md \
  install.sh update.sh uninstall.sh \
  README.md CLAUDE.md docs/FEATURES.md

sed -i '' 's/{{PLUGIN_DESCRIPTION}}/YOUR_PLUGIN_DESCRIPTION/g' \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  plugins/my-plugin/README.md \
  README.md

sed -i '' 's/{{AUTHOR_NAME}}/YOUR_AUTHOR_NAME/g' \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json

sed -i '' 's/{{PLUGIN_VERSION}}/YOUR_PLUGIN_VERSION/g' \
  .claude-plugin/marketplace.json \
  plugins/my-plugin/.claude-plugin/plugin.json \
  CLAUDE.md

sed -i '' 's/{{PLUGIN_CATEGORY}}/YOUR_PLUGIN_CATEGORY/g' \
  .claude-plugin/marketplace.json

# --- Agent placeholders ---
sed -i '' 's/{{AGENT_NAME}}/YOUR_AGENT_NAME/g' \
  plugins/my-plugin/agents/my-agent.md \
  README.md CLAUDE.md docs/FEATURES.md

sed -i '' 's/{{AGENT_DISPLAY_NAME}}/YOUR_AGENT_DISPLAY_NAME/g' \
  README.md

sed -i '' 's/{{AGENT_DESCRIPTION_SHORT}}/YOUR_AGENT_DESCRIPTION_SHORT/g' \
  README.md docs/FEATURES.md

sed -i '' 's/{{AGENT_ROLE}}/YOUR_AGENT_ROLE/g' \
  plugins/my-plugin/agents/my-agent.md

sed -i '' 's/{{AGENT_COLOR}}/YOUR_AGENT_COLOR/g' \
  plugins/my-plugin/agents/my-agent.md
```

### Step 4: Rename Directories and Files

Rename the plugin directory and agent file to match your chosen names:

```bash
# Rename plugin directory (replace YOUR_PLUGIN_NAME)
mv plugins/my-plugin plugins/YOUR_PLUGIN_NAME

# Rename agent file (replace YOUR_AGENT_NAME)
mv plugins/YOUR_PLUGIN_NAME/agents/my-agent.md plugins/YOUR_PLUGIN_NAME/agents/YOUR_AGENT_NAME.md
```

**Important:** After renaming, update the `source` field in `.claude-plugin/marketplace.json`:

```bash
# Update the source path (replace YOUR_PLUGIN_NAME)
sed -i '' 's|./plugins/my-plugin|./plugins/YOUR_PLUGIN_NAME|g' .claude-plugin/marketplace.json
```

### Step 5: Customize the Agent

Open `plugins/YOUR_PLUGIN_NAME/agents/YOUR_AGENT_NAME.md` and customize:

1. **Examples in the frontmatter** — Replace the generic examples with domain-specific ones that match your agent's expertise.
2. **Core Competencies** — Replace the placeholder competencies (marked with `<!-- CUSTOMIZE -->`) with the specific skills relevant to your agent's domain.
3. **External Actions** — Update the list of external services to match the ones your agent might interact with.

### Step 6: Customize the Commands

Open the command files in `plugins/YOUR_PLUGIN_NAME/commands/` and customize:

1. **`commands.md`** — Update the command table if you add or rename commands.

### Step 7: Make Scripts Executable

```bash
chmod +x install.sh update.sh uninstall.sh
```

### Step 8: Initialize and Push

```bash
git add -A
git commit -m "Initial plugin setup"
git remote add origin git@github.com:YOUR_GITHUB_OWNER/YOUR_REPO_NAME.git
git push -u origin main
```

### Step 9: Install and Test

```bash
./install.sh
```

Then open Claude Code and verify:
- The agent triggers for relevant questions
- `/commands` works correctly
- `/plugin` shows your plugin as installed

### Step 10: Clean Up

Once everything works, you can delete this `SETUP.md` file:

```bash
rm SETUP.md
git add -A && git commit -m "Remove setup guide"
```

### Quick Reference

After setup, your repo structure will look like:

```
├── .claude-plugin/
│   └── marketplace.json
├── .claude/
│   └── settings.local.json
├── .mcp.json
├── .gitignore
├── CLAUDE.md
├── README.md
├── docs/
│   └── FEATURES.md
├── install.sh
├── update.sh
├── uninstall.sh
└── plugins/YOUR_PLUGIN_NAME/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── README.md
    ├── agents/
    │   └── YOUR_AGENT_NAME.md
    ├── commands/
    │   └── commands.md
    └── skills/
        └── .gitkeep
```
