# CI Standards Plugin

**Baseline template for all coding initiatives** - standardize CI/CD workflows and AI agent documentation across any project.

## Overview

This plugin automates the setup of:
- ✅ **GitHub Actions CI/CD** - 3-job workflow (resolve-env → ci-gate → deploy)
- ✅ **AI Documentation** - CLAUDE.md + AI agent operational guides
- ✅ **TypeScript Configuration** - Consistent type checking across projects
- ✅ **Cloudflare Workers** - Deployment configuration and patterns

## Supported Project Types

1. **React + Vite + Cloudflare Workers**
   - Modern React apps with serverless backend
   - Example: Single-page apps with API routes

2. **Next.js 15 + OpenNext + Cloudflare**
   - Full-stack Next.js apps on Cloudflare
   - Server-side rendering + edge deployment

3. **Hono + Cloudflare Workers**
   - Lightweight API-only projects
   - Ultra-fast serverless APIs

## Quick Start

### Set up a new project or update existing one:

```bash
/ci-standards
```

The command will:
1. Analyze your project type
2. Show you what will be created/updated
3. Generate standardized CI/CD and documentation

### What Gets Created

**CI/CD Workflow** (`.github/workflows/deploy.yml`):
- 3-job pattern: resolve-env → ci-gate → deploy
- Branch→environment mapping (development/staging/main)
- TypeScript type checking
- Automated Cloudflare Workers deployment

**Documentation**:
- `CLAUDE.md` - Project overview for AI assistants
- `docs/AI_AGENT_GUIDE.md` - Operational guide with critical rules

**Configuration**:
- TypeScript configs (tsconfig.json, tsconfig.worker.json)
- Wrangler configuration (wrangler.toml)
- Node version file (.nvmrc)

## Critical Standards

All generated files follow these principles:

### CI/CD Rules
- ❌ **NEVER** use `continue-on-error: true`
- ✅ **ALWAYS** use Node 22
- ✅ **ALWAYS** use 3-job pattern
- ❌ **NEVER** enable `workers_dev` subdomain
- ✅ **ALWAYS** run typecheck before deploy
- ✅ **ALWAYS** map branches to environments

### Documentation Rules
- 📋 Include critical rules section
- 📋 Document common tasks
- 📋 Provide troubleshooting steps
- 📋 List exact file paths
- 📋 Include working code examples

## Installation

This plugin is installed at: `~/.claude/plugins/ci-standards/`

It's automatically available in all Claude Code sessions.

## Components

### Command
- `/ci-standards` - Interactive setup workflow

### Skills
- `ci-patterns` - CI/CD workflow knowledge
- `project-types` - Project architecture patterns
- `ai-documentation` - AI agent documentation standards

### Agents
- `project-analyzer` - Detects project type and configuration
- `workflow-generator` - Generates standardized GitHub Actions workflow
- `docs-generator` - Creates AI agent documentation

## Examples

### Full Setup (New Project)
```bash
/ci-standards
→ Select: Full setup (CI/CD + docs + TypeScript)
→ Confirm project type
→ Review changes
→ Apply
```

### Update CI/CD Only
```bash
/ci-standards
→ Select: CI/CD only
→ Review workflow diff
→ Apply
```

### Generate Docs Only
```bash
/ci-standards
→ Select: Documentation only
→ Review generated files
→ Apply
```

## Version History

- **1.0.0** - Initial release
  - GitHub Actions + Cloudflare Workers
  - 3 project types (React+Vite, Next.js, Hono)
  - TypeScript always enabled
  - Comprehensive AI documentation

## License

MIT License - Use freely in any project.

## Author

Roger Emerson (roger@echeloncapital.group)
