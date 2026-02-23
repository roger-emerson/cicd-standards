---
name: CI/CD Patterns
description: This skill activates when setting up CI/CD workflows, configuring GitHub Actions, deploying to Cloudflare Workers, or standardizing deployment processes. Use when user mentions "CI/CD", "GitHub Actions", "deployment workflow", "Cloudflare deploy", or needs help with continuous integration patterns.
version: 2.0.0
---

# CI/CD Patterns for Cloudflare Workers

Master the standardized 3-job workflow pattern for deploying to Cloudflare Workers via GitHub Actions.

## Core Pattern: 3-Job Workflow

All CI/CD workflows follow this exact structure:

```
resolve-env → ci-gate → deploy
(1 min)       (5 min)    (10 min)
```

### Job 1: resolve-env

**Purpose**: Map Git branch name to deployment environment

**Configuration**:
- Timeout: 1 minute
- Runs on: ubuntu-latest
- Outputs: `environment` (development|staging|production)

**Branch Mapping**:
| Branch | Environment | Worker Name |
|--------|-------------|-------------|
| development | development | project-name-dev |
| staging | staging | project-name |
| main | production | project-name |

**Implementation**:
```yaml
resolve-env:
  name: Resolve Environment
  runs-on: ubuntu-latest
  timeout-minutes: 1
  outputs:
    environment: ${{ steps.env.outputs.environment }}
  steps:
    - name: Map branch to environment
      id: env
      env:
        BRANCH: ${{ github.ref_name }}
      run: |
        case "$BRANCH" in
          development)
            echo "environment=development" >> "$GITHUB_OUTPUT"
            ;;
          staging)
            echo "environment=staging" >> "$GITHUB_OUTPUT"
            ;;
          main)
            echo "environment=production" >> "$GITHUB_OUTPUT"
            ;;
          *)
            echo "::error::Unsupported branch: $BRANCH"
            exit 1
            ;;
        esac
```

### Job 2: ci-gate

**Purpose**: Quality checks before deployment (typecheck + build)

**Configuration**:
- Timeout: 5 minutes
- Depends on: resolve-env
- Runs on: ubuntu-latest
- Node version: 22

**Steps**:
1. Checkout code
2. Setup Node.js 22
3. `npm ci` (clean install)
4. `npm run typecheck` (TypeScript validation)
5. `npm run build` (build verification)

**Implementation**:
```yaml
ci-gate:
  name: CI Gate
  needs: resolve-env
  runs-on: ubuntu-latest
  timeout-minutes: 5
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: "22"
        cache: "npm"
    - run: npm ci
    - name: Type check
      run: npm run typecheck
    - name: Build check
      run: npm run build
```

### Job 3: deploy

**Purpose**: Deploy to Cloudflare Workers

**Configuration**:
- Timeout: 10 minutes
- Depends on: resolve-env, ci-gate
- Runs on: ubuntu-latest
- Uses GitHub environment for secrets

**Deployment Strategy by Project Type**:

**React + Vite + Workers**:
```yaml
- run: npm run build
- run: npx wrangler deploy --env development  # if dev
```

**Next.js + OpenNext**:
```yaml
- run: npm run deploy:dev  # or npm run deploy
```

**Hono Only**:
```yaml
- run: npx wrangler deploy --env development
```

**Implementation**:
```yaml
deploy:
  name: Deploy Worker (${{ needs.resolve-env.outputs.environment }})
  needs: [resolve-env, ci-gate]
  runs-on: ubuntu-latest
  timeout-minutes: 10
  environment: ${{ needs.resolve-env.outputs.environment }}
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: "22"
        cache: "npm"
    - run: npm ci
    - name: Deploy to Cloudflare Workers
      run: |
        if [ "${{ needs.resolve-env.outputs.environment }}" = "development" ]; then
          npx wrangler deploy --env development
        else
          npx wrangler deploy
        fi
      env:
        CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

## Critical Rules

### NEVER Do These

1. **❌ NEVER use `continue-on-error: true`**
   - Masks failures
   - Deployments succeed even when broken
   - Creates false confidence

   ```yaml
   # BAD
   - run: npm run build
     continue-on-error: true  # ❌ WRONG

   # GOOD
   - run: npm run build  # ✅ Fails loudly
   ```

2. **❌ NEVER use Node versions other than 22**
   ```yaml
   # BAD
   node-version: "20"  # ❌ WRONG

   # GOOD
   node-version: "22"  # ✅ Consistent
   ```

3. **❌ NEVER enable workers_dev subdomain**
   ```toml
   # In wrangler.toml
   workers_dev = false  # ✅ Always
   ```

4. **❌ NEVER skip typecheck**
   - Must run before deploy
   - Catches type errors early
   - Prevents runtime issues

5. **❌ NEVER use matrix testing**
   ```yaml
   # BAD
   strategy:
     matrix:
       node-version: [18, 20, 22]  # ❌ Wastes time

   # GOOD
   node-version: "22"  # ✅ Single version
   ```

### ALWAYS Do These

1. **✅ ALWAYS use 3-job pattern**
   - resolve-env first
   - ci-gate second
   - deploy last
   - No additional jobs

2. **✅ ALWAYS use concurrency control**
   ```yaml
   concurrency:
     group: deploy-${{ github.ref_name }}
     cancel-in-progress: ${{ github.ref_name != 'main' }}
   ```

   - Cancels old deploys on development/staging
   - Always completes production deploys

3. **✅ ALWAYS set timeouts**
   - resolve-env: 1 minute
   - ci-gate: 5 minutes
   - deploy: 10 minutes

4. **✅ ALWAYS use GitHub environment contexts**
   ```yaml
   environment: ${{ needs.resolve-env.outputs.environment }}
   ```
   - Enables environment-specific secrets
   - Provides deployment protection rules

5. **✅ ALWAYS use npx wrangler**
   ```yaml
   # GOOD
   npx wrangler deploy  # ✅ Uses package.json version

   # BAD
   wrangler deploy      # ❌ Uses globally installed version
   ```

## Workflow Configuration

### Trigger Events

```yaml
on:
  push:
    branches: [development, staging, main]
  workflow_dispatch:  # Manual trigger
```

**Why these triggers**:
- `push` to dev/staging/main: Automatic deployment
- `workflow_dispatch`: Manual deploys when needed
- No `pull_request`: Don't deploy on PRs

### Environment Variables

```yaml
env:
  NODE_VERSION: "22"
```

**Required GitHub Secrets**:
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token with Workers deploy permissions
- `CLOUDFLARE_ACCOUNT_ID` - Cloudflare account ID

**How to set secrets**:
1. GitHub repo → Settings → Secrets → Actions
2. Add `CLOUDFLARE_API_TOKEN`
3. Add `CLOUDFLARE_ACCOUNT_ID`

## Project-Specific Adaptations

### React + Vite + Cloudflare Workers

**Build command**: `npm run build` (Vite builds to `dist/`)
**Deploy command**: `npx wrangler deploy`
**Special notes**:
- Wrangler serves `dist/` as static assets
- Worker handles `/api/*` routes first
- TypeScript for both frontend and worker

### Next.js + OpenNext

**Build command**: `npm run deploy` (OpenNext builds + deploys)
**Deploy command**: Handled by OpenNext CLI
**Special notes**:
- Uses `@opennextjs/cloudflare` package
- Separate deploy:dev script for development
- Wrangler config in JSONC format

### Hono Only

**Build command**: None (TypeScript compiles automatically)
**Deploy command**: `npx wrangler deploy`
**Special notes**:
- Lightweight Worker-only deployment
- No static assets
- Fastest deploy times

### Cloudflare Pages (Astro / SolidStart / Remix)

**Build command**: `npm run build` (framework builds to `dist/`)
**Deploy command**: `npx wrangler pages deploy dist --project-name=<name>`
**Special notes**:
- Uses `wrangler pages deploy` NOT `wrangler deploy`
- Build output directory varies by framework
- Pages Functions automatically deployed from `functions/` directory
- Environment handling via Pages project settings

**Deploy job adaptation:**
```yaml
- name: Deploy to Cloudflare Pages
  run: npx wrangler pages deploy dist --project-name=${{ vars.PAGES_PROJECT_NAME || 'project-name' }}
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

### Workers + Durable Objects

**Build command**: `npm run build` (if applicable)
**Deploy command**: `npx wrangler deploy`
**Special notes**:
- Durable Object migrations run automatically on deploy
- Migrations declared in `wrangler.toml` `[[migrations]]`
- First deploy creates DO classes; subsequent deploys can add/rename/delete
- No additional CI steps needed — Wrangler handles migrations

**Important**: Durable Object migrations are **irreversible**. The deploy step inherently handles this, but be aware that rolling back a DO migration requires a new forward migration.

### Workers + R2

**Build command**: `npm run build` (if applicable)
**Deploy command**: `npx wrangler deploy`
**Special notes**:
- R2 buckets must be created before first deploy (via dashboard or `wrangler r2 bucket create`)
- Wrangler handles R2 bindings automatically from `wrangler.toml`
- No extra CI steps for R2 — bindings are declarative

### Generic (Non-Cloudflare)

**Build command**: `npm run build`
**Deploy command**: `npm run deploy` (project-specific)
**Special notes**:
- Same 3-job pattern applies
- Deploy job uses whatever mechanism the project defines
- No Cloudflare secrets needed
- May use Docker, npm publish, rsync, or platform CLI

**Deploy job adaptation:**
```yaml
- name: Deploy
  run: npm run deploy
  env:
    # Project-specific secrets
    DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

**Docker variant:**
```yaml
- name: Build and push Docker image
  run: |
    docker build -t ${{ vars.DOCKER_REGISTRY }}/${{ github.repository }}:${{ github.sha }} .
    docker push ${{ vars.DOCKER_REGISTRY }}/${{ github.repository }}:${{ github.sha }}
```

## Wrangler Configuration

**Essential settings** in `wrangler.toml`:

```toml
name = "project-name"
compatibility_date = "2024-12-01"
workers_dev = false

[observability]
enabled = true
head_sampling_rate = 1

[observability.logs]
enabled = true
invocation_logs = true
head_sampling_rate = 1

[env.development]
name = "project-name-dev"
workers_dev = false
```

**Key points**:
- `workers_dev = false` prevents `.workers.dev` subdomain
- Observability enabled for monitoring
- Development environment has separate name

## Troubleshooting

### Deployment fails with "Missing script: typecheck"

**Solution**: Add to `package.json`:
```json
"scripts": {
  "typecheck": "tsc --noEmit"
}
```

### Deployment succeeds but Worker doesn't respond

**Check**:
1. Cloudflare Workers dashboard for errors
2. `wrangler.toml` has correct `main` field
3. Environment secrets are set
4. Worker code exports default fetch handler

### TypeScript errors in CI but not locally

**Causes**:
- Different TypeScript versions
- Missing type definitions
- Cached types locally

**Solution**:
```bash
npm ci  # Clean install
npm run typecheck  # Run locally
```

### Wrangler version mismatch errors

**Solution**: Always use `npx wrangler` not global `wrangler`

## Migration from Old Patterns

If converting from legacy workflows:

1. **Remove `continue-on-error` flags**
2. **Change to Node 22**
3. **Add 3-job structure**
4. **Remove matrix testing**
5. **Add environment mapping**
6. **Add concurrency control**

**Before**:
```yaml
jobs:
  build:
    strategy:
      matrix:
        node-version: [18, 20]
    steps:
      - run: npm run build
        continue-on-error: true
```

**After**:
```yaml
jobs:
  resolve-env: ...
  ci-gate:
    steps:
      - run: npm run build  # No continue-on-error
  deploy: ...
```

## References

- See `project-types` skill for project-specific configurations
- See `enforcement-rules` skill for compliance enforcement
- See `dora-metrics` skill for measuring CI/CD performance
- GitHub Actions docs: https://docs.github.com/actions
- Wrangler docs: https://developers.cloudflare.com/workers/wrangler/
- Cloudflare Pages docs: https://developers.cloudflare.com/pages
