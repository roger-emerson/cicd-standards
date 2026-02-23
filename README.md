# CICD Standards

**A Claude Code plugin that enforces, generates, and measures CI/CD pipeline quality.**

Stop shipping broken deployments. This plugin catches bad CI/CD practices before they reach production, generates standardized workflows for your projects, and tracks your team's delivery health over time using industry-standard DORA metrics.

---

## Table of Contents

- [What This Plugin Does](#what-this-plugin-does)
- [Who Is This For](#who-is-this-for)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Commands](#commands)
- [How Enforcement Works](#how-enforcement-works)
- [Supported Project Types](#supported-project-types)
- [DORA Metrics](#dora-metrics)
- [Plugin Architecture](#plugin-architecture)
- [Enforcement Rules Reference](#enforcement-rules-reference)
- [Frequently Asked Questions](#frequently-asked-questions)
- [Version History](#version-history)
- [License](#license)

---

## What This Plugin Does

The plugin operates on three levels:

### 1. Enforce (Automatic)

Every time Claude writes or edits a CI configuration file, a validation hook runs automatically. If the file contains a critical violation, **the write is blocked** before it ever hits your codebase. You do not need to remember the rules. The plugin remembers them for you.

### 2. Generate (On Demand)

Run a single command and the plugin analyzes your project, detects what framework you are using, and generates a production-ready GitHub Actions workflow, AI-friendly documentation, and proper TypeScript configuration. No copy-pasting from old projects.

### 3. Measure (On Demand)

Pull real data from your GitHub Actions history and see where your delivery pipeline stands. The plugin calculates the four DORA metrics (the industry standard for measuring software delivery performance) and tells you whether you are shipping like an elite team or if something needs attention.

---

## Who Is This For

- **Solo developers** who want a reliable deployment pipeline without memorizing every best practice.
- **Teams** that need consistent CI/CD across multiple repositories.
- **Tech leads** who want to enforce standards without writing custom linters.
- **Anyone deploying to Cloudflare Workers** (or any platform using GitHub Actions).

No prior knowledge of DORA metrics, GitHub Actions syntax, or Cloudflare Workers is required. The plugin guides you through everything.

---

## Installation

### Step 1: Add the marketplace

Open Claude Code and run:

```
/plugin marketplace add roger-emerson/cicd-standards
```

This tells Claude Code where to find the plugin. You only need to do this once.

### Step 2: Install the plugin

```
/plugin install cicd-standards@roger-emerson-cicd-standards
```

### Step 3: Restart Claude Code

The plugin loads on startup. Close and reopen Claude Code (or start a new session) for the plugin to take effect.

### Verify Installation

After restarting, you should see a compliance audit message when starting a session in any project directory. This means the session-audit hook is running. You can also run:

```
/cicd-standards analyze
```

This prints a report of your project's current CI/CD status without changing any files.

---

## Getting Started

### If you are setting up a new project

Navigate to your project directory and run:

```
/cicd-standards
```

The plugin will ask what you want to do:

| Option | What It Does |
|--------|-------------|
| **Full setup** | Generates CI/CD workflow + AI documentation + TypeScript config |
| **CI only** | Generates just the GitHub Actions workflow |
| **Docs only** | Generates CLAUDE.md and AI_AGENT_GUIDE.md |
| **Analyze** | Reports what your project has and what is missing (no changes made) |
| **Metrics** | Shows your DORA metrics dashboard |

You can also skip the menu by passing an argument directly:

```
/cicd-standards full
/cicd-standards ci
/cicd-standards docs
/cicd-standards analyze
/cicd-standards metrics
```

### If you just want to see your metrics

```
/ci-metrics
```

This pulls your GitHub Actions run history and calculates deployment frequency, lead time, failure rate, and recovery time. You need the [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated.

---

## Commands

### `/cicd-standards`

The main command. Analyzes your project and offers to generate standardized files.

**Arguments:**

| Argument | Description |
|----------|-------------|
| `full` | Generate everything: CI/CD workflow, documentation, and configuration |
| `ci` | Generate only the GitHub Actions deployment workflow |
| `docs` | Generate only CLAUDE.md and docs/AI_AGENT_GUIDE.md |
| `analyze` | Print a compliance report without making any changes |
| `metrics` | Show the DORA metrics dashboard (same as `/ci-metrics`) |
| *(none)* | Interactive mode: shows a menu of options |

**What gets generated:**

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | 3-job deployment workflow (resolve-env, ci-gate, deploy) |
| `CLAUDE.md` | Project overview for AI agents |
| `docs/AI_AGENT_GUIDE.md` | Operational guide with critical rules and common tasks |
| `wrangler.toml` updates | Observability, environment config, workers_dev = false |
| `package.json` updates | Adds `typecheck` script if missing |
| `.nvmrc` | Pins Node version to 22 |

Before writing any file, the plugin shows you exactly what will be created or changed and asks for confirmation. It can also create `.bak` backup files.

### `/ci-metrics`

Displays the DORA metrics dashboard for your project.

**Arguments:**

| Argument | Description |
|----------|-------------|
| `--range 7d` | Last 7 days |
| `--range 30d` | Last 30 days (default) |
| `--range 90d` | Last 90 days |
| `--range 180d` | Last 180 days |

**Requires:** GitHub CLI (`gh`) installed and authenticated. Install with `brew install gh` on macOS.

**Example output includes:**
- Overall performance tier (Elite / High / Medium / Low)
- Individual metric values and tier classifications
- Trend indicators showing improvement or degradation
- Recent deployments table
- Actionable improvement suggestions

---

## How Enforcement Works

The plugin includes two hooks that run automatically. You do not need to invoke them manually.

### Pre-Write Validation

**When it runs:** Every time Claude uses the Write or Edit tool on a CI configuration file.

**What it checks:**

| File | What Gets Validated |
|------|-------------------|
| `.github/workflows/*.yml` | No `continue-on-error: true`, Node version is 22, follows 3-job pattern, has timeouts, no matrix testing |
| `wrangler.toml` | `workers_dev` is not set to `true` |
| `wrangler.jsonc` | `workers_dev` is not set to `true` |

**What happens when a violation is found:**

- **CRITICAL violations** block the write entirely. Claude cannot save the file until the violation is fixed. This prevents dangerous patterns like `continue-on-error: true` from ever entering your codebase.
- **WARNING violations** allow the write but display a message. These are best practices that have legitimate exceptions.

Files that are not CI configuration (your application code, documentation, etc.) pass through without any checks.

### Session Audit

**When it runs:** At the start of every Claude Code session.

**What it does:** Scans the current project directory for existing CI configuration files and reports:

- A compliance score (percentage of checks passing)
- Any existing violations in your workflow files
- Missing recommended files (like `.nvmrc` or `CLAUDE.md`)
- Actionable recommendations

This is informational only. It never blocks anything.

---

## Supported Project Types

The plugin detects your project type automatically by examining your `package.json`, configuration files, and directory structure.

### 1. React + Vite + Cloudflare Workers

Single-page applications with a serverless API backend. Vite builds the frontend to `dist/`, and a Cloudflare Worker serves both static files and API routes.

**Detection:** Has `vite` and `react` in package.json, plus `wrangler.toml` with assets config.

**Deploy command:** `npx wrangler deploy`

### 2. Next.js 15 + OpenNext + Cloudflare

Full-stack applications with server-side rendering running on the edge. Uses the OpenNext adapter to deploy Next.js to Cloudflare Workers.

**Detection:** Has `next` and `@opennextjs/cloudflare` in package.json.

**Deploy command:** `opennextjs-cloudflare build && opennextjs-cloudflare deploy`

### 3. Hono + Cloudflare Workers

Lightweight API-only services. No frontend bundling. Smallest bundle size and fastest cold starts.

**Detection:** Has `hono` in package.json with no frontend framework dependencies.

**Deploy command:** `npx wrangler deploy`

### 4. Cloudflare Pages (Astro / SolidStart / Remix)

Static-first sites with optional server-side features via Pages Functions. Deploys to Cloudflare Pages instead of Workers.

**Detection:** Has `astro`, `solid-start`, or `@remix-run/cloudflare-pages` in package.json.

**Deploy command:** `npx wrangler pages deploy dist`

### 5. Workers + Durable Objects

Stateful serverless applications. Durable Objects provide strong consistency, WebSocket support, and coordination primitives.

**Detection:** Has `[durable_objects]` and `[[migrations]]` sections in `wrangler.toml`.

**Deploy command:** `npx wrangler deploy`

### 6. Workers + R2

Storage-heavy applications using Cloudflare's S3-compatible object storage. No egress fees.

**Detection:** Has `[[r2_buckets]]` section in `wrangler.toml`.

**Deploy command:** `npx wrangler deploy`

### 7. Generic (Any Platform)

For projects that do not deploy to Cloudflare. The 3-job CI pattern still applies. Works with Docker, npm publish, or any custom deployment script.

**Detection:** Fallback when no Cloudflare indicators are found but `package.json` exists.

**Deploy command:** `npm run deploy` (or your custom script)

---

## DORA Metrics

DORA stands for **DevOps Research and Assessment**. It is a research program (now part of Google Cloud) that identified four metrics that predict software delivery performance. Elite teams score well on all four.

### The Four Metrics

| Metric | What It Measures | How It Is Calculated |
|--------|-----------------|---------------------|
| **Deployment Frequency** | How often you ship to production | Count of successful deploys to `main` in the time period |
| **Lead Time for Changes** | How long from commit to production | Time from push to `main` until deployment completes |
| **Change Failure Rate** | What percentage of deploys cause failures | Failed deploys / total deploys |
| **Mean Time to Recovery** | How quickly you recover from failures | Average time from a failed deploy to the next success |

### Performance Tiers

| Tier | Deploy Frequency | Lead Time | Failure Rate | Recovery Time |
|------|-----------------|-----------|--------------|---------------|
| **Elite** | Multiple times per day | Less than 1 hour | Under 5% | Less than 1 hour |
| **High** | Daily to weekly | 1 day to 1 week | 5% to 10% | Less than 1 day |
| **Medium** | Weekly to monthly | 1 week to 1 month | 10% to 15% | 1 day to 1 week |
| **Low** | Less than monthly | More than 1 month | Over 15% | More than 1 week |

Your overall tier equals your **lowest** individual metric. A team that deploys hourly but takes a week to recover from failures is rated Low, not Elite.

### How This Plugin Improves Your Metrics

| Plugin Feature | DORA Impact |
|----------------|------------|
| Automated 3-job pipeline | Reduces lead time (no manual deploy steps) |
| Blocking `continue-on-error` | Improves failure rate (real failures are caught, not hidden) |
| Typecheck in CI gate | Improves failure rate (type errors caught before deploy) |
| Branch-to-environment mapping | Enables higher deploy frequency (safe to deploy often) |
| Timeout protection | Improves recovery time (stuck jobs do not block the pipeline) |
| Concurrency control | Reduces lead time (no queuing on development branches) |
| Observability enabled | Improves recovery time (failures detected faster) |

---

## Plugin Architecture

### Directory Structure

```
cicd-standards/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest (name, version, metadata)
│   └── marketplace.json         # Marketplace distribution config
├── commands/
│   ├── cicd-standards.md        # /cicd-standards command definition
│   └── ci-metrics.md            # /ci-metrics command definition
├── agents/
│   ├── project-analyzer.md      # Detects project type and configuration
│   ├── workflow-generator.md    # Generates GitHub Actions workflows
│   ├── docs-generator.md        # Creates AI documentation files
│   └── metrics-tracker.md       # Calculates DORA metrics
├── skills/
│   ├── ci-patterns/SKILL.md     # CI/CD workflow patterns and rules
│   ├── project-types/SKILL.md   # 7 project architecture definitions
│   ├── ai-documentation/SKILL.md # Documentation standards
│   ├── enforcement-rules/SKILL.md # 9 codified rules (RULE-001 to 009)
│   └── dora-metrics/SKILL.md    # DORA metric definitions and benchmarks
├── hooks/
│   ├── hooks.json               # Hook registration (triggers and timing)
│   ├── validate-ci-config.sh    # Pre-write validator (blocks violations)
│   └── session-audit.sh         # Session start compliance scan
├── README.md
├── CHANGELOG.md
└── LICENSE                      # MIT
```

### How the Pieces Fit Together

**Commands** are what you run (`/cicd-standards`, `/ci-metrics`). They orchestrate the workflow.

**Agents** are specialized sub-processes that do the heavy lifting. The command dispatches agents to analyze your project, generate files, or calculate metrics. Each agent has a focused role and its own set of tools.

**Skills** are knowledge bases. They contain the rules, patterns, and definitions that agents and commands reference. When Claude needs to know "what is the correct 3-job workflow pattern," it reads the `ci-patterns` skill.

**Hooks** are automatic triggers. They run without you asking. The pre-write hook validates files on every write. The session-audit hook scans your project on startup.

---

## Enforcement Rules Reference

Nine rules are codified, each with a severity level that determines behavior:

| ID | Rule | Severity | What Happens |
|----|------|----------|-------------|
| RULE-001 | No `continue-on-error: true` | CRITICAL | Write blocked |
| RULE-002 | Node version must be 22 | CRITICAL | Write blocked |
| RULE-003 | No `workers_dev = true` | CRITICAL | Write blocked |
| RULE-004 | Use 3-job workflow pattern | WARNING | Write allowed, message shown |
| RULE-005 | All jobs must have timeouts | WARNING | Write allowed, message shown |
| RULE-006 | No matrix testing strategy | WARNING | Write allowed, message shown |
| RULE-007 | Typecheck must run in CI gate | INFO | Reported at session audit |
| RULE-008 | `.nvmrc` must be present | INFO | Reported at session audit |
| RULE-009 | AI documentation must exist | INFO | Reported at session audit |

### Why Each Rule Exists

**RULE-001 (continue-on-error):** When a CI step fails silently, broken code ships to production. There is no safe use case for this in deployment workflows.

**RULE-002 (Node 22):** Mixed Node versions across local development, CI, and production cause subtle, hard-to-debug differences. Pinning to one version eliminates this class of bugs.

**RULE-003 (workers_dev):** Enabling `workers_dev` creates a public `.workers.dev` URL that bypasses your custom domain routing and environment isolation. This is a security risk.

**RULE-004 (3-job pattern):** The resolve-env / ci-gate / deploy structure separates concerns cleanly. Environment resolution happens first, quality checks happen second, and deployment happens last. This makes debugging straightforward because each job has one responsibility.

**RULE-005 (timeouts):** Without timeouts, a stuck job consumes GitHub Actions minutes indefinitely. Standard timeouts: 1 minute for environment resolution, 5 minutes for CI checks, 10 minutes for deployment.

**RULE-006 (no matrix):** Testing against multiple Node versions (18, 20, 22) triples CI time for no benefit when the deployment target is always Node 22.

**RULE-007 (typecheck):** Running `npm run typecheck` in the CI gate catches type errors at build time instead of runtime. This is one of the highest-value quality gates you can add.

**RULE-008 (.nvmrc):** Ensures local development uses the same Node version as CI, preventing "works on my machine" issues.

**RULE-009 (AI documentation):** `CLAUDE.md` and `docs/AI_AGENT_GUIDE.md` give AI agents project context, reducing errors and improving the quality of generated code.

---

## Frequently Asked Questions

### Can I use this without Cloudflare?

Yes. Project type 7 (Generic) works with any deployment target. The 3-job CI pattern, enforcement rules, DORA metrics, and documentation generation all work regardless of where you deploy. The Cloudflare-specific rules (like `workers_dev`) simply will not trigger if you do not have Cloudflare configuration files.

### What if a rule blocks something I actually need?

CRITICAL rules are intentionally hard to bypass. If you believe a rule is wrong for your use case, you can disable the enforcement hooks in your plugin settings. The rules exist because these patterns cause real production incidents. Consider whether the exception is truly necessary before disabling.

### Does this work with monorepos?

The plugin analyzes the current working directory. In a monorepo, navigate to the specific package directory before running `/cicd-standards`. The session audit scans from the project root.

### What is the 3-job pattern?

It is a GitHub Actions workflow structure with three sequential jobs:

1. **resolve-env** (1 min) — Reads the branch name and outputs which environment to deploy to (development, staging, or production).
2. **ci-gate** (5 min) — Runs `npm ci`, `npm run typecheck`, and `npm run build` to validate code quality.
3. **deploy** (10 min) — Deploys to the target environment using the appropriate command for your project type.

Each job depends on the previous one. If typecheck fails, deployment never runs.

### Do I need the GitHub CLI for anything?

Only for DORA metrics (`/ci-metrics`). The CLI pulls your workflow run history from GitHub. Everything else works without it. Install with `brew install gh` and authenticate with `gh auth login`.

### How do I update the plugin?

```
/plugin uninstall cicd-standards@roger-emerson-cicd-standards
/plugin install cicd-standards@roger-emerson-cicd-standards
```

Then restart Claude Code.

---

## Version History

| Version | Date | Highlights |
|---------|------|-----------|
| **2.0.0** | 2026-02-22 | Enforcement hooks, DORA metrics, 7 project types, marketplace distribution |
| **1.0.0** | 2026-02-21 | Initial release: workflow generation, 3 project types, documentation |

See [CHANGELOG.md](CHANGELOG.md) for the full list of changes.

---

## License

MIT License. Use freely in any project, commercial or personal.

---

## Author

Roger Emerson — [github.com/roger-emerson](https://github.com/roger-emerson)
