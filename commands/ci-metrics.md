---
name: ci-metrics
description: Show DORA metrics dashboard for the current project's CI/CD performance
argument-hint: "[--range 30d|7d|90d|180d]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Task
---

# CI Metrics — DORA Dashboard

Calculate and display the four DORA metrics for the current project using real GitHub Actions data.

## What This Command Does

1. **Pulls** GitHub Actions workflow run history via `gh` CLI
2. **Calculates** the four DORA metrics:
   - Deployment Frequency
   - Lead Time for Changes
   - Change Failure Rate
   - Mean Time to Recovery (MTTR)
3. **Classifies** performance tier (Elite / High / Medium / Low)
4. **Shows trends** compared to previous period
5. **Provides** actionable improvement insights

## Usage

```bash
# Default: last 30 days
/ci-metrics

# Custom range
/ci-metrics --range 7d
/ci-metrics --range 90d
/ci-metrics --range 180d
```

## Implementation Steps

### Step 1: Parse Arguments

Extract the `--range` argument if provided. Default to `30d`.

Valid range formats: `7d`, `14d`, `30d`, `60d`, `90d`, `180d`, `365d`

### Step 2: Dispatch Metrics Tracker Agent

Use the Task tool to launch the `metrics-tracker` agent:

```
Task with subagent_type="ci-standards:metrics-tracker"
Description: "Calculate DORA metrics for current project"
Prompt: Include the range parameter and any context from the current project
```

### Step 3: Display Dashboard

The metrics-tracker agent returns a formatted dashboard. Display it directly to the user.

The dashboard includes:
- Overall performance tier
- Individual metric values and tiers
- Trend indicators (↑ improving, → stable, ↓ degrading)
- Recent deployments table
- Improvement insights
- DORA benchmark reference

## Error Handling

**If `gh` CLI is not available:**
```
The GitHub CLI (gh) is required for DORA metrics.
Install: brew install gh
Authenticate: gh auth login
```

**If no workflow history exists:**
```
No deployment workflows found in this repository.
Run /ci-standards ci to set up a standardized CI/CD workflow first.
```

**If no production deployments found:**
```
No production deployments found (no successful runs on main branch).
Metrics will be calculated once deployments start flowing.
```

## Tips

- Run regularly to track improvement over time
- Use `--range 7d` for a quick pulse check
- Use `--range 90d` for trend analysis
- Compare metrics before and after CI standards adoption
- Share dashboard with team during retrospectives

## See Also

- `dora-metrics` skill — DORA metric definitions and benchmarks
- `ci-patterns` skill — CI/CD standards that improve DORA metrics
- `/ci-standards` — Set up CI/CD workflows
