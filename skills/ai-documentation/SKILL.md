---
name: AI Documentation
description: This skill activates when creating documentation for AI agents, writing CLAUDE.md files, generating operational guides, or standardizing project documentation. Use when user mentions "AI documentation", "CLAUDE.md", "agent guide", "OpenClaw", or needs help structuring project docs for AI assistants.
version: 1.0.0
---

# AI Agent Documentation Standards

Learn how to write comprehensive, actionable documentation that helps AI agents (like Claude, OpenClaw, etc.) understand and work effectively with your projects.

## Documentation Philosophy

**Goal**: Enable AI agents to understand your project without human intervention.

**Principles**:
1. **Specificity over generality** - Exact file paths, not "the config file"
2. **Examples over explanations** - Working code, not just descriptions
3. **Critical rules first** - What never to break, prominently displayed
4. **Action-oriented** - What to do, not just what exists

## Two-File System

### CLAUDE.md - Project Overview

**Purpose**: High-level understanding of the project

**Location**: Repository root

**Audience**: Any AI agent working on the project

**Length**: 200-400 lines

**Tone**: Informative, reference-style

### docs/AI_AGENT_GUIDE.md - Operational Guide

**Purpose**: Detailed operational instructions and patterns

**Location**: `docs/` directory

**Audience**: AI agents performing tasks

**Length**: 500-1000 lines

**Tone**: Instructional, prescriptive

## CLAUDE.md Structure

### Template

```markdown
# Project Name

[One-sentence project description]

## Project Overview

[2-3 paragraphs explaining what this project does and why it exists]

**Live**: [URL if deployed]

## Tech Stack

- **Framework**: [React + Vite, Next.js 15, Hono]
- **Styling**: [CSS Modules, Tailwind CSS v4, etc.]
- **Runtime**: [Cloudflare Workers]
- **Deploy**: [GitHub Actions → Cloudflare]
- **Package Manager**: [npm, pnpm, yarn]

## Architecture

```
src/
├── components/      # React components
├── workers/         # Cloudflare Worker code
├── App.tsx
└── main.tsx
```

[Explain directory structure and how files relate]

## CI/CD Workflow

GitHub Actions pipeline (`.github/workflows/deploy.yml`):

```
push to branch → resolve-env → ci-gate → deploy
```

### Branch → Environment Mapping

| Branch | Environment | Worker Name |
|--------|-------------|-------------|
| development | development | project-name-dev |
| staging | staging | project-name |
| main | production | project-name |

### GitHub Secrets Required

- `CLOUDFLARE_API_TOKEN` - Cloudflare API token
- `CLOUDFLARE_ACCOUNT_ID` - Cloudflare account ID

### Deployment Flow

1. Push to development/staging/main
2. **Resolve Environment** - maps branch to environment
3. **CI Gate** - runs typecheck + build
4. **Deploy Worker** - deploys to Cloudflare

## Commands

```bash
npm run dev         # Local development
npm run build       # Production build
npm run typecheck   # TypeScript validation
npm run deploy      # Manual deployment
```

## Key Configuration Notes

[Project-specific wrangler.toml or other config details]

## Design System

**Colors**:
- Primary: #hexcode (description)
- Secondary: #hexcode (description)

**Fonts**:
- Headings: [Font name]
- Body: [Font name]

**Component Library**: [shadcn/ui, custom, none]

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/health` | GET | Health check |
| `/api/contact` | POST | Form submission |

## Critical Rules (NEVER Break These)

### CI/CD
- ❌ **NEVER** use `continue-on-error: true`
- ✅ **ALWAYS** use Node 22
- ✅ **ALWAYS** follow 3-job pattern
- ❌ **NEVER** enable `workers_dev`

### Code Quality
- ✅ **ALWAYS** run typecheck before commit
- ✅ **ALWAYS** test locally before pushing
- ❌ **NEVER** commit with TypeScript errors

## Repository

- **GitHub**: [owner/repo-name]
- **Primary branch**: main
```

### Key Sections Explained

**Project Overview**:
- What the project does
- Who it's for
- Why it exists
- Current status

**Tech Stack**:
- Frameworks and versions
- Key dependencies
- Build tools
- Deployment platform

**Architecture**:
- Directory structure
- File organization
- How components relate
- Build output locations

**CI/CD Workflow**:
- How deployment works
- Branch strategy
- Required secrets
- Deployment steps

**Commands**:
- Common npm scripts
- What each command does
- When to use them

**Design System** (if applicable):
- Color palette with hex codes
- Typography choices
- Component patterns
- Accessibility notes

**API Endpoints** (if applicable):
- All routes
- Request/response formats
- Authentication needs

**Critical Rules**:
- What NEVER to do
- What ALWAYS to do
- Why these rules exist

## docs/AI_AGENT_GUIDE.md Structure

### Template

```markdown
# AI Agent Operational Guide

Detailed instructions for AI agents working on [Project Name].

## Table of Contents

1. Standard Workflow Pattern
2. File Locations
3. Common Tasks
4. Critical Rules (NEVER Break These)
5. Troubleshooting
6. Verification Steps

## Standard Workflow Pattern

### CI/CD Workflow (Detailed)

[Explain each job in the GitHub Actions workflow]

**resolve-env Job**:
- Maps Git branch to environment name
- Outputs: `environment` variable
- Timeout: 1 minute
- Always runs first

**ci-gate Job**:
- Validates code quality
- Steps: npm ci → typecheck → build
- Timeout: 5 minutes
- Depends on: resolve-env

**deploy Job**:
- Deploys to Cloudflare Workers
- Uses: GitHub environment secrets
- Timeout: 10 minutes
- Depends on: resolve-env, ci-gate

## File Locations

### CI/CD Configuration
- GitHub Actions: `.github/workflows/deploy.yml`
- Wrangler config: `wrangler.toml` or `wrangler.jsonc`
- Node version: `.nvmrc`

### React Application (if applicable)
- Components: `src/components/`
- Pages: `src/pages/` or `src/app/`
- Styles: `src/theme/` or `src/styles/`
- Main entry: `src/main.tsx`

### Cloudflare Worker (if applicable)
- Worker code: `src/workers/index.ts`
- API routes: `src/workers/routes/`
- Utilities: `src/workers/lib/`

### Build Output
- Vite build: `dist/`
- Next.js build: `.next/` and `.open-next/`
- TypeScript: No output (noEmit: true)

### Configuration
- TypeScript (frontend): `tsconfig.json`
- TypeScript (worker): `tsconfig.worker.json`
- Vite: `vite.config.ts`
- Next.js: `next.config.js`
- Package manager: `package.json`

## Common Tasks

### Task 1: Adding a New React Component

**Step-by-step**:

1. Create component file in `src/components/`:
   ```tsx
   // src/components/NewComponent.tsx
   export function NewComponent() {
     return <div>Content</div>
   }
   ```

2. Create CSS module (if using CSS Modules):
   ```css
   /* src/components/NewComponent.module.css */
   .container { /* styles */ }
   ```

3. Export from index:
   ```ts
   // src/components/index.ts
   export { NewComponent } from './NewComponent'
   ```

4. Import and use:
   ```tsx
   import { NewComponent } from './components'
   ```

**Verify**:
- Component renders locally (`npm run dev`)
- TypeScript compiles (`npm run typecheck`)
- Build succeeds (`npm run build`)

### Task 2: Updating CI/CD Workflow

**When to modify**:
- Adding new environment
- Changing deployment strategy
- Adding build steps

**How to modify**:

1. Edit `.github/workflows/deploy.yml`

2. **If adding environment**:
   ```yaml
   case "$BRANCH" in
     development) echo "environment=development" ;;
     staging) echo "environment=staging" ;;
     main) echo "environment=production" ;;
     preview) echo "environment=preview" ;;  # New
   esac
   ```

3. **If changing deployment**:
   Update deploy job's run command

4. **Test changes**:
   - Push to non-main branch first
   - Verify workflow runs correctly
   - Check deployment succeeds

**Never**:
- Add `continue-on-error: true`
- Change Node version from 22
- Remove typecheck step
- Break 3-job pattern

### Task 3: Adding New API Endpoint

**For Cloudflare Worker**:

1. Add route handler in worker code:
   ```ts
   // src/workers/index.ts
   if (url.pathname === '/api/new-endpoint' && request.method === 'POST') {
     const data = await request.json()
     // Handle request
     return new Response(JSON.stringify({ success: true }))
   }
   ```

2. Update CORS headers if needed

3. Add to API Endpoints section in CLAUDE.md

**For Next.js**:

1. Create route handler:
   ```ts
   // src/app/api/new-endpoint/route.ts
   export async function POST(request: Request) {
     const data = await request.json()
     return Response.json({ success: true })
   }
   ```

2. Update CLAUDE.md

**Verify**:
- Test locally with curl/Postman
- Check CORS headers
- Verify error handling

### Task 4: Deploying to Environments

**Development**:
```bash
git checkout development
git push origin development
# → Deploys to project-name-dev.workers.dev
```

**Staging**:
```bash
git checkout staging
git merge development
git push origin staging
# → Deploys to project-name.workers.dev (staging)
```

**Production**:
```bash
git checkout main
git merge staging
git push origin main
# → Deploys to project-name.workers.dev (production)
```

**Manual deployment**:
```bash
npm run deploy              # Production
npm run deploy:dev          # Development (Next.js only)
npx wrangler deploy --env development  # Development (Vite/Hono)
```

## Critical Rules (NEVER Break These)

### Rule 1: Never use `continue-on-error: true`

**Why**: Masks failures, deployments succeed even when broken

**Bad**:
```yaml
- run: npm run build
  continue-on-error: true  # ❌ WRONG
```

**Good**:
```yaml
- run: npm run build  # ✅ Fails loudly
```

**Exception**: None. Always let failures fail.

### Rule 2: Always use Node 22

**Why**: Consistency across environments, known compatibility

**Bad**:
```yaml
node-version: "20"  # ❌ WRONG
```

**Good**:
```yaml
node-version: "22"  # ✅ Correct
```

**Exception**: None. Always Node 22.

### Rule 3: Always follow 3-job pattern

**Why**: Separation of concerns, clear failure points

**Required jobs**:
1. resolve-env (branch → environment)
2. ci-gate (typecheck + build)
3. deploy (deployment)

**Never**:
- Combine jobs
- Add extra jobs
- Reorder jobs

### Rule 4: Never enable workers_dev subdomain

**Why**: Prevents unintended public URLs

**In wrangler.toml**:
```toml
workers_dev = false  # ✅ Always false
```

**In all environments**:
```toml
[env.development]
workers_dev = false  # ✅ Also false
```

### Rule 5: Always run typecheck before deploy

**Why**: Catches type errors before runtime

**In CI**:
```yaml
- name: Type check
  run: npm run typecheck
```

**Locally before push**:
```bash
npm run typecheck && npm run build
```

## Troubleshooting

### Issue 1: "npm run typecheck" fails

**Symptoms**:
- TypeScript errors in CI
- Build succeeds but typecheck fails

**Diagnosis**:
```bash
npm run typecheck  # Run locally
tsc --noEmit --listFiles  # See what's being checked
```

**Solutions**:
1. Fix type errors in code
2. Add missing type definitions
3. Update `@types/*` packages
4. Check tsconfig includes/excludes

**Common causes**:
- Unused variables (remove them)
- Missing type annotations
- Incorrect import paths

### Issue 2: Build succeeds locally but fails in CI

**Symptoms**:
- `npm run build` works locally
- Fails in GitHub Actions

**Diagnosis**:
```bash
npm ci  # Clean install
rm -rf dist/ .next/  # Clear build cache
npm run build  # Try fresh build
```

**Solutions**:
1. Delete `node_modules` and reinstall
2. Check for environment-specific code
3. Verify all dependencies are in package.json
4. Check Node version matches (22)

**Common causes**:
- Dev dependencies in dependencies
- Missing dependencies
- Cached build artifacts

### Issue 3: Deployment succeeds but Worker doesn't respond

**Symptoms**:
- GitHub Actions shows success
- Worker returns 404 or 500

**Diagnosis**:
```bash
# Check Cloudflare Workers dashboard
# View worker logs
# Test health endpoint
curl https://project-name.workers.dev/api/health
```

**Solutions**:
1. Check worker code exports default handler
2. Verify wrangler.toml main entry is correct
3. Check environment secrets are set
4. Review worker logs for errors

**Common causes**:
- Missing export default
- Wrong main entry in wrangler.toml
- Missing secrets
- Runtime errors in worker code

## Verification Steps

### After Making Changes

**1. Local verification**:
```bash
npm run typecheck  # TypeScript
npm run build      # Build succeeds
npm run dev        # Test locally
```

**2. Git workflow**:
```bash
git add .
git commit -m "Clear, descriptive message"
git push origin [branch]
```

**3. CI verification**:
- Watch GitHub Actions run
- Check all 3 jobs succeed
- Verify deployment completes

**4. Deployment verification**:
```bash
# Test health endpoint
curl https://project-name.workers.dev/api/health

# Test frontend
open https://project-name.workers.dev/

# Check Cloudflare dashboard
# - Worker logs
# - Analytics
# - Error rates
```

### Before Merging to Main

**Checklist**:
- [ ] All tests pass locally
- [ ] TypeScript compiles with no errors
- [ ] Build succeeds
- [ ] Deployed to development and tested
- [ ] Deployed to staging and tested
- [ ] No `continue-on-error` in workflows
- [ ] Documentation updated (CLAUDE.md)
- [ ] API endpoints documented (if added)

## Quick Reference

### Commands
```bash
npm run dev         # Local dev server
npm run build       # Production build
npm run typecheck   # Type checking
npm run deploy      # Deploy to Cloudflare
```

### URLs
- Development: https://project-name-dev.workers.dev
- Staging: https://project-name.workers.dev (staging env)
- Production: https://project-name.workers.dev

### File Paths
- Workflow: `.github/workflows/deploy.yml`
- Wrangler: `wrangler.toml` or `wrangler.jsonc`
- TypeScript: `tsconfig.json`, `tsconfig.worker.json`
- Worker: `src/workers/index.ts`
- Frontend: `src/main.tsx` or `src/app/layout.tsx`
```

### Content Generation Rules

**For CLAUDE.md**:

1. **Auto-detect color palette**:
   - Read `src/theme/colors.js` or similar
   - Extract hex codes and names
   - Include in Design System section

2. **Auto-detect API endpoints**:
   - Parse Worker code (`src/workers/index.ts`)
   - Find route handlers (`if (url.pathname === ...)`)
   - List in API Endpoints table

3. **Auto-detect tech stack**:
   - Read `package.json` dependencies
   - Identify framework (react, next, hono)
   - List versions

**For AI_AGENT_GUIDE.md**:

1. **Include actual file paths**:
   - Never say "the config file"
   - Always: `wrangler.toml` or `.github/workflows/deploy.yml`

2. **Include working code examples**:
   - Copy from actual project if possible
   - Show complete snippets, not fragments

3. **Project-specific critical rules**:
   - Standard rules (Node 22, no continue-on-error)
   - Plus any project-specific rules
   - Always with examples

## Writing Style

### Imperative vs. Descriptive

**Bad** (too vague):
> The project uses React for the frontend.

**Good** (specific):
> The project uses React 18 with Vite 6 for the frontend. Components are in `src/components/`.

### Active Voice

**Bad**:
> TypeScript should be run before deploying.

**Good**:
> Run `npm run typecheck` before every deployment.

### Concrete Examples

**Bad**:
> Configure your environment variables.

**Good**:
```bash
# In GitHub repo → Settings → Secrets
Add: CLOUDFLARE_API_TOKEN
Add: CLOUDFLARE_ACCOUNT_ID
```

## Maintenance

### When to Update

- New features added
- API endpoints change
- Deployment process changes
- Critical rules change
- Tech stack upgrades

### What to Update

**CLAUDE.md**:
- Tech stack versions
- API endpoint table
- Color palette (if changed)
- Commands (if changed)

**AI_AGENT_GUIDE.md**:
- Common tasks (if new patterns)
- Troubleshooting (if new issues)
- File locations (if moved)

## References

- See `templates/CLAUDE.md` for complete example
- See `templates/AI_AGENT_GUIDE.md` for complete example
- See `ci-patterns` skill for workflow details
- See `project-types` skill for architecture patterns
