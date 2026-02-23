# CI Standards Plugin

**Enforce, generate, and measure CI/CD standards across projects** — with real-time violation blocking, DORA metrics, and support for 7 project architectures.

## Overview

This plugin provides three layers of CI/CD standardization:

1. **Enforce** — Hooks block violations in real-time before files are written
2. **Generate** — Agents create standardized workflows, configs, and documentation
3. **Measure** — DORA metrics dashboard tracks delivery performance

### What's Enforced

- ❌ **NEVER** `continue-on-error: true` (blocks write)
- ❌ **NEVER** `workers_dev = true` (blocks write)
- ❌ **NEVER** Node version other than 22 (blocks write)
- ✅ **ALWAYS** 3-job pattern (resolve-env → ci-gate → deploy)
- ✅ **ALWAYS** timeouts on all jobs
- ✅ **ALWAYS** typecheck before deploy

### What's Generated

- `.github/workflows/deploy.yml` — Standardized 3-job CI/CD workflow
- `CLAUDE.md` — AI agent project overview
- `docs/AI_AGENT_GUIDE.md` — Operational guide with critical rules
- TypeScript and Wrangler configuration

### What's Measured

- **Deployment Frequency** — How often you ship
- **Lead Time for Changes** — How fast you ship
- **Change Failure Rate** — How reliable your shipping is
- **Mean Time to Recovery** — How fast you recover from failures

## Supported Project Types

| # | Type | Deploy Command | Key Feature |
|---|------|---------------|-------------|
| 1 | React + Vite + Workers | `npx wrangler deploy` | SPA with API backend |
| 2 | Next.js 15 + OpenNext | `opennextjs-cloudflare deploy` | SSR/SSG on edge |
| 3 | Hono + Workers | `npx wrangler deploy` | Lightweight API |
| 4 | Cloudflare Pages (Astro) | `wrangler pages deploy` | Static-first sites |
| 5 | Workers + Durable Objects | `npx wrangler deploy` | Stateful apps |
| 6 | Workers + R2 | `npx wrangler deploy` | Storage-heavy apps |
| 7 | Generic (any platform) | `npm run deploy` | Non-Cloudflare fallback |

## Quick Start

### Set up a new project:

```bash
/ci-standards
```

### Generate CI/CD only:

```bash
/ci-standards ci
```

### Generate documentation only:

```bash
/ci-standards docs
```

### View DORA metrics:

```bash
/ci-metrics
/ci-metrics --range 90d
```

### Analyze project (report only):

```bash
/ci-standards analyze
```

## Installation

### From nupraxus marketplace:

```bash
# Add marketplace (one-time)
/plugin marketplace add nupraxus/claude-plugins-marketplace

# Install plugin
/plugin install ci-standards@nupraxus-plugins
```

### Manual installation:

```bash
# Clone to plugins directory
git clone https://github.com/nupraxus/ci-standards-plugin.git ~/.claude/plugins/ci-standards
```

## Components

### Commands
- `/ci-standards` — Interactive setup workflow (full, ci, docs, analyze, metrics)
- `/ci-metrics` — DORA metrics dashboard with configurable range

### Agents
- `project-analyzer` — Detects project type and configuration across 7 architectures
- `workflow-generator` — Generates standardized GitHub Actions workflows
- `docs-generator` — Creates AI agent documentation (CLAUDE.md + AI_AGENT_GUIDE.md)
- `metrics-tracker` — Calculates DORA metrics from GitHub Actions data

### Skills
- `ci-patterns` — CI/CD workflow knowledge and patterns
- `project-types` — Project architecture patterns (7 types)
- `ai-documentation` — AI agent documentation standards
- `enforcement-rules` — Codified rules with severity levels
- `dora-metrics` — DORA metric definitions and benchmarks

### Hooks
- `validate-ci-config.sh` — Pre-write validator (blocks CRITICAL violations)
- `session-audit.sh` — Session start compliance audit (informational)

## Enforcement

The plugin includes enforcement hooks that run automatically:

### Pre-Write Validation

Every `Write` or `Edit` to CI config files is validated:

| File Pattern | Checks |
|-------------|--------|
| `.github/workflows/*.yml` | No continue-on-error, Node 22, 3-job pattern, timeouts |
| `wrangler.toml` | No workers_dev = true |
| `wrangler.jsonc` | No workers_dev: true |

**CRITICAL** violations block the write. **WARNING** violations allow the write with a message.

### Session Audit

On session start, the plugin scans the project and reports:
- Compliance score (percentage)
- Existing violations
- Missing required files
- Recommendations

## DORA Metrics

Track your software delivery performance with the four DORA metrics:

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| Deploy Frequency | On-demand | Daily-Weekly | Weekly-Monthly | <Monthly |
| Lead Time | <1 hour | 1d-1w | 1w-1m | >1 month |
| Failure Rate | <5% | 5-10% | 10-15% | >15% |
| MTTR | <1 hour | <1 day | 1d-1w | >1 week |

Requires the GitHub CLI (`gh`) to be installed and authenticated.

## Version History

- **2.0.0** — Enforcement hooks, DORA metrics, 7 project types, marketplace distribution
- **1.0.0** — Initial release: generation-only, 3 project types

See [CHANGELOG.md](CHANGELOG.md) for full details.

## License

MIT License — Use freely in any project.

## Author

Roger Emerson — [nupraxus](https://github.com/nupraxus)
