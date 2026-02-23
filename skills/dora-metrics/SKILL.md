---
name: DORA Metrics
description: This skill activates when discussing software delivery performance, DORA metrics, deployment frequency, lead time, change failure rate, MTTR, or CI/CD health measurement. Use when user mentions "DORA", "metrics", "deployment frequency", "lead time", "failure rate", "MTTR", "delivery performance", or needs to understand software delivery measurement.
version: 2.0.0
---

# DORA Metrics for Software Delivery

Measure and improve software delivery performance using the four key metrics defined by the DORA (DevOps Research and Assessment) research program.

## What Are DORA Metrics?

DORA metrics are the industry-standard measurement framework for software delivery performance, backed by years of research across thousands of organizations. They measure two dimensions:

**Throughput** (how fast you ship):
1. Deployment Frequency
2. Lead Time for Changes

**Stability** (how reliable your shipping is):
3. Change Failure Rate
4. Mean Time to Recovery (MTTR)

Elite teams excel at **both** throughput and stability — they ship faster AND more reliably.

## The Four Metrics

### 1. Deployment Frequency

**What it measures:** How often your team deploys to production.

**How to calculate:**
```
Count successful deployments to production in the time period.
Divide by the number of days/weeks.
```

**In our CI context:** Count successful GitHub Actions runs on the `main` branch.

**Benchmarks:**
| Tier | Frequency | What It Means |
|------|-----------|---------------|
| Elite | On-demand (multiple/day) | Team ships whenever a feature is ready |
| High | Daily to weekly | Regular, predictable releases |
| Medium | Weekly to monthly | Batched releases |
| Low | Less than monthly | Large, infrequent releases |

**How to improve:**
- Reduce batch sizes (smaller PRs)
- Automate deployment pipeline (3-job pattern handles this)
- Remove manual approval gates on non-production environments
- Build confidence through automated testing

### 2. Lead Time for Changes

**What it measures:** Time from code commit to running in production.

**How to calculate:**
```
For each production deployment:
  lead_time = deployment_completed_at - first_commit_time
Take the median of all lead times.
```

**In our CI context:** Time from push to `main` to successful deployment completion.

**Benchmarks:**
| Tier | Lead Time | What It Means |
|------|-----------|---------------|
| Elite | Less than 1 hour | Fully automated pipeline |
| High | 1 day to 1 week | Some manual steps or batching |
| Medium | 1 week to 1 month | Significant process overhead |
| Low | More than 1 month | Heavy process, manual deployment |

**How to improve:**
- Automate CI/CD fully (the 3-job pattern gives ~15 min lead time)
- Remove manual gates on dev/staging
- Optimize build times (caching, parallel steps)
- Keep PRs small and focused

### 3. Change Failure Rate

**What it measures:** Percentage of deployments that cause a failure.

**How to calculate:**
```
change_failure_rate = failed_deploys / total_deploys × 100
```

**In our CI context:** Ratio of failed to total GitHub Actions runs on `main`.

**Benchmarks:**
| Tier | Rate | What It Means |
|------|------|---------------|
| Elite | 0-5% | Strong quality gates catch issues early |
| High | 5-10% | Good but some gaps in testing |
| Medium | 10-15% | Testing catches most but not all issues |
| Low | 15%+ | Significant quality gaps |

**How to improve:**
- Add typecheck to CI gate (already in 3-job pattern)
- Add automated tests before deploy
- Use environment progression (dev → staging → production)
- Review deployments before merging to main
- Never use `continue-on-error: true` (masks real failures)

### 4. Mean Time to Recovery (MTTR)

**What it measures:** How quickly you recover from a production failure.

**How to calculate:**
```
For each failed production deployment:
  recovery_time = next_success_at - failure_at
Take the mean of all recovery times.
```

**Benchmarks:**
| Tier | MTTR | What It Means |
|------|------|---------------|
| Elite | Less than 1 hour | Fast detection and automated recovery |
| High | Less than 1 day | Good incident response |
| Medium | 1 day to 1 week | Slow detection or complex recovery |
| Low | More than 1 week | Severe process or architecture issues |

**How to improve:**
- Enable observability in wrangler.toml (already standard)
- Set up Cloudflare Workers monitoring
- Have a quick rollback process
- Keep deployments small (easier to diagnose failures)
- Use branch-to-environment mapping for testing before production

## Performance Tiers

Overall tier = the **lowest** individual metric tier. A team is only as strong as its weakest metric.

| Tier | Characteristics |
|------|----------------|
| **Elite** | Ship on-demand, <1hr lead time, <5% failure, <1hr recovery |
| **High** | Ship daily-weekly, good quality gates, fast recovery |
| **Medium** | Regular releases but with process overhead or quality gaps |
| **Low** | Infrequent releases, high failure rates, slow recovery |

## How CI Standards Help

The ci-standards plugin directly impacts DORA metrics:

| Standard | DORA Impact |
|----------|-------------|
| 3-job pattern | Reduces lead time (automated pipeline) |
| No continue-on-error | Improves failure rate (real failures caught) |
| Typecheck in CI gate | Improves failure rate (type errors caught early) |
| Branch→environment mapping | Enables deployment frequency (safe to deploy often) |
| Timeout protection | Improves MTTR (stuck jobs don't block recovery) |
| Concurrency control | Improves lead time (no queuing on dev/staging) |
| Observability enabled | Improves MTTR (faster failure detection) |

## Quality Gates

Use DORA metrics to define quality gates — thresholds that must be met before certain actions:

### Suggested Gates

| Gate | Metric | Threshold | Action |
|------|--------|-----------|--------|
| Deploy to staging | Change Failure Rate | <15% (last 30 days) | Auto-deploy if below |
| Deploy to production | Change Failure Rate | <10% (last 30 days) | Require review if above |
| Release confidence | All 4 metrics | High tier or better | Green light for releases |

These are suggestions — implement gates based on your team's maturity and risk tolerance.

## Using the Metrics Command

```bash
# Default: last 30 days
/ci-metrics

# Custom range
/ci-metrics --range 90d
/ci-metrics --range 7d

# Via ci-standards command
/ci-standards metrics
```

## Interpreting Results

### High Frequency + High Failure Rate
You're shipping fast but breaking things. Focus on quality gates (typecheck, testing).

### Low Frequency + Low Failure Rate
You're shipping safely but slowly. Reduce batch sizes, automate more.

### High Frequency + Low Failure Rate (Elite)
You're shipping fast and reliably. Maintain current practices, optimize lead time.

### Low MTTR
Recovery is fast when things break. Good incident response and small deployments help.

### High MTTR
Recovery is slow. Investigate: Is it detection time? Or fix time? Enable observability, reduce deployment complexity.

## References

- DORA State of DevOps Reports: https://dora.dev
- Accelerate (book): Forsgren, Humble, Kim
- `metrics-tracker` agent — calculates these metrics from real data
- `ci-patterns` skill — the standards that improve these metrics
