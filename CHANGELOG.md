# Changelog

All notable changes to the cicd-standards plugin will be documented in this file.

## [2.1.0] - 2026-02-23

### Added

**Deterministic Workflow Generation (Template-First)**
- `templates/workflows/workers.yml` — Literal YAML template for Cloudflare Workers projects (react-vite, hono, workers-do, workers-r2)
- `templates/workflows/nextjs-opennext.yml` — Literal YAML template for Next.js + OpenNext projects
- `templates/workflows/pages.yml` — Literal YAML template for Cloudflare Pages projects (including Next.js static export)
- `templates/workflows/generic.yml` — Literal YAML template for non-Cloudflare projects
- All templates use `{{VARIABLE}}` placeholders substituted by the workflow-generator agent
- Templates enforce the canonical 3-job pattern (resolve-env → ci-gate → deploy) by construction

**Package Manager Support**
- Automatic detection of npm vs pnpm via lockfile presence (pnpm-lock.yaml → pnpm, package-lock.json → npm)
- Package manager substitution variables: `{{PM_CACHE}}`, `{{PM_INSTALL}}`, `{{PM_RUN}}`, `{{PM_EXEC}}`, `{{PNPM_SETUP_STEP}}`
- Session audit now checks package manager consistency (warns if workflow cache doesn't match lockfile)

**Next.js Static Export Detection**
- Projects with `output: "export"` in next.config (without `@opennextjs/cloudflare`) classified as `pages`, not `nextjs`
- Uses `templates/workflows/pages.yml` with `{{OUTPUT_DIR}}` set to `out`

### Changed
- `agents/workflow-generator.md` — Added "CRITICAL: Template-First Generation" section that overrides prose-based generation with read-template-and-substitute approach
- `agents/project-analyzer.md` — Added Next.js static export detection logic and package manager detection step with output format
- `hooks/session-audit.sh` — Added package manager consistency check between lockfile and workflow cache strategy
- `skills/ci-patterns/SKILL.md` — Added template files reference table and pnpm variant section
- `skills/project-types/SKILL.md` — Added Next.js Static Export as a subtype under Cloudflare Pages
- `skills/enforcement-rules/SKILL.md` — Updated RULE-007 to accept both `npm run typecheck` and `pnpm run typecheck`

## [2.0.0] - 2026-02-22

### Added

**Phase 1: Enforcement Hooks (Shift-Left)**
- `hooks/hooks.json` — Hook registration manifest for PreToolUse and SessionStart
- `hooks/validate-ci-config.sh` — Pre-write validator that blocks CI config violations in real-time
  - Checks workflow files for `continue-on-error`, Node version, 3-job pattern, timeouts, matrix strategy
  - Checks wrangler.toml/jsonc for `workers_dev = true`
  - CRITICAL violations block writes; WARNINGs inform but allow
- `hooks/session-audit.sh` — Session start audit that scans project and reports compliance status
- `skills/enforcement-rules/SKILL.md` — Codified rules with severity levels (CRITICAL/WARNING/INFO) and 9 named rules (RULE-001 through RULE-009)

**Phase 2: DORA Metrics**
- `agents/metrics-tracker.md` — Agent that calculates 4 DORA metrics from GitHub Actions data via `gh` CLI
- `skills/dora-metrics/SKILL.md` — DORA metric definitions, benchmarks, tier classifications, and improvement strategies
- `commands/ci-metrics.md` — New `/ci-metrics` command for DORA metrics dashboard with `--range` support

**Phase 3: Scope Expansion (7 Project Types)**
- Cloudflare Pages (Astro, SolidStart, Remix) — `wrangler pages deploy` pattern
- Workers + Durable Objects — stateful apps with migration awareness
- Workers + R2 — storage-heavy apps with bucket configuration
- Generic (Non-Cloudflare) — fallback for any Node.js/Docker project using the 3-job pattern

**Phase 4: Distribution**
- `CHANGELOG.md` — Version history tracking
- Plugin metadata: `homepage` and `repository` fields in plugin.json
- Marketplace-ready distribution with nupraxus branding

### Changed
- `plugin.json` — Bumped to v2.0.0, updated description, added keywords
- `commands/cicd-standards.md` — Added `metrics` as 5th argument option, updated See Also
- `agents/project-analyzer.md` — Extended detection for 4 new project types
- `agents/workflow-generator.md` — Added deploy templates for Pages, DO, R2, and generic
- `agents/docs-generator.md` — Added framework-specific intelligence for all new types
- `skills/ci-patterns/SKILL.md` — Added CI patterns for Pages, DO, R2, and generic deployments
- `skills/project-types/SKILL.md` — Expanded from 3 to 7 supported architectures
- `README.md` — Updated for v2.0.0 with all new features and installation instructions

## [1.0.0] - 2026-02-21

### Added
- Initial release
- `/cicd-standards` command with interactive workflow
- 3 project types: React+Vite, Next.js+OpenNext, Hono
- 3-job CI pattern (resolve-env → ci-gate → deploy)
- AI documentation generation (CLAUDE.md + AI_AGENT_GUIDE.md)
- `project-analyzer` agent
- `workflow-generator` agent
- `docs-generator` agent
- `ci-patterns` skill
- `project-types` skill
- `ai-documentation` skill
