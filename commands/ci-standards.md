---
name: ci-standards
description: Standardize CI/CD workflows and AI documentation across projects
argument-hint: "[full|ci|docs|analyze]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Task
  - AskUserQuestion
---

# CI Standards Setup

Analyze the current project and set up standardized CI/CD workflows and AI agent documentation.

## What This Command Does

1. **Analyzes** the current project to determine:
   - Project type (React+Vite, Next.js, Hono, or unknown)
   - Existing configuration
   - What needs to be created/updated

2. **Generates** based on user selection:
   - **Full setup**: CI/CD + documentation + TypeScript
   - **CI only**: GitHub Actions workflow
   - **Docs only**: CLAUDE.md + AI_AGENT_GUIDE.md
   - **Analyze**: Report only, no changes

3. **Validates** and shows diffs before applying changes

## Usage

```bash
# Interactive mode (recommended)
/ci-standards

# Direct mode with argument
/ci-standards full
/ci-standards ci
/ci-standards docs
/ci-standards analyze
```

## Implementation Steps

### Step 1: Dispatch Project Analyzer Agent

Use the Task tool to launch the `project-analyzer` agent:

```
Task with subagent_type="ci-standards:project-analyzer"
Description: "Analyze project structure and configuration"
```

The agent will return a project analysis report including:
- Project type (react-vite, nextjs, hono, unknown)
- Detected dependencies and frameworks
- Existing CI/CD configuration
- Missing standardized files
- Recommendations

### Step 2: Get User Selection

If no argument provided, use AskUserQuestion to show options:

```markdown
**What would you like to standardize?**

Options:
- Full setup (CI/CD + docs + TypeScript)
- CI/CD workflow only
- Documentation only
- Analyze project (report only)
```

### Step 3: Dispatch Appropriate Agents

Based on user selection, dispatch one or more agents:

**For "Full setup" or "CI only":**
```
Task with subagent_type="ci-standards:workflow-generator"
Description: "Generate GitHub Actions workflow for [project-type]"
Prompt: Include project analysis results from Step 1
```

**For "Full setup" or "Docs only":**
```
Task with subagent_type="ci-standards:docs-generator"
Description: "Generate AI documentation for [project-type]"
Prompt: Include project analysis results from Step 1
```

### Step 4: Review and Confirm

Before writing any files:

1. **Show what will be created/modified:**
   - List file paths
   - Show diffs for existing files
   - Highlight new files

2. **Ask for confirmation:**
   ```markdown
   **Ready to apply these changes?**

   Files to create:
   - .github/workflows/deploy.yml (new)
   - CLAUDE.md (new)
   - docs/AI_AGENT_GUIDE.md (new)

   Files to update:
   - package.json (add typecheck script)
   - wrangler.toml (update configuration)

   Create backups? [Yes/No]
   ```

3. **Create .bak backups if user confirms:**
   ```bash
   cp .github/workflows/deploy.yml .github/workflows/deploy.yml.bak
   ```

### Step 5: Apply Changes

Write all files using the Write tool.

### Step 6: Summary

Show completion message:

```markdown
✅ **CI Standards Applied**

Created:
- `.github/workflows/deploy.yml` - 3-job CI/CD workflow
- `CLAUDE.md` - AI agent project overview
- `docs/AI_AGENT_GUIDE.md` - Operational guide

Next steps:
1. Review generated files
2. Set GitHub secrets: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID
3. Push to trigger first deployment
4. Share docs with AI agents

Backups created with .bak extension.
```

## Error Handling

**If project type cannot be determined:**
- Ask user to manually select type
- Offer generic template option
- Provide guidance on what's needed for detection

**If files exist and user declines overwrite:**
- Show paths where backup files are
- Offer to create files with .new extension for manual review

**If dependencies are missing:**
- List required dependencies
- Offer to add them to package.json
- Show installation command

## Tips

- Run from project root directory
- Ensure package.json exists for accurate detection
- Review diffs carefully before applying
- Keep .bak files until you verify everything works
- Run `/ci-standards analyze` first if unsure

## See Also

- `ci-patterns` skill - CI/CD workflow knowledge
- `project-types` skill - Project architecture patterns
- `ai-documentation` skill - Documentation standards
