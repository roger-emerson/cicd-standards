---
name: Enforcement Rules
description: This skill activates when discussing CI/CD rule enforcement, compliance validation, hook behavior, or when a write is blocked by the cicd-standards validator. Use when user mentions "enforcement", "blocked write", "compliance", "violations", "CI rules", or needs to understand why a file write was rejected.
version: 2.0.0
---

# CI Standards Enforcement Rules

Codified rules enforced by the cicd-standards hooks. These rules are checked in real-time on every Write/Edit to CI config files and reported at session start via project audit.

## Severity Levels

| Severity | Hook Behavior | Symbol |
|----------|--------------|--------|
| **CRITICAL** | Blocks the write (exit 2) | ❌ |
| **WARNING** | Allows write, shows message (exit 0 + message) | ⚠️ |
| **INFO** | Logged at session audit only | 📋 |

## Rule Definitions

### RULE-001: No continue-on-error (CRITICAL)

**Applies to:** `.github/workflows/*.yml`
**Pattern:** `continue-on-error: true`
**Severity:** CRITICAL — blocks write

**Why:** Masks CI failures. A workflow step that fails silently means broken code ships to production. There is no valid use case for this in deployment workflows.

**Bad:**
```yaml
- name: Build
  run: npm run build
  continue-on-error: true  # ❌ BLOCKED
```

**Good:**
```yaml
- name: Build
  run: npm run build  # ✅ Fails loudly
```

**Exception:** None. This rule has no exceptions.

---

### RULE-002: Node 22 Only (CRITICAL)

**Applies to:** `.github/workflows/*.yml`
**Pattern:** `node-version` set to anything other than `22`
**Severity:** CRITICAL — blocks write

**Why:** Consistency across all environments. Node 22 is the standard runtime. Mixed versions cause subtle dependency and behavior differences.

**Bad:**
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: "20"  # ❌ BLOCKED
```

**Good:**
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: "22"  # ✅ Standard
```

**Reference:** Also enforced via `.nvmrc` containing `22`.

---

### RULE-003: No workers_dev (CRITICAL)

**Applies to:** `wrangler.toml`, `wrangler.jsonc`
**Pattern:** `workers_dev = true` or `"workers_dev": true`
**Severity:** CRITICAL — blocks write

**Why:** Enabling `workers_dev` creates a public `.workers.dev` subdomain that bypasses custom domain routing and environment isolation. This is a security and operational risk.

**Bad (TOML):**
```toml
workers_dev = true  # ❌ BLOCKED
```

**Bad (JSONC):**
```jsonc
"workers_dev": true  // ❌ BLOCKED
```

**Good:**
```toml
workers_dev = false  # ✅ Always false
```

**Note:** Must be false in ALL environments, including `[env.development]`.

---

### RULE-004: 3-Job Workflow Pattern (WARNING)

**Applies to:** `.github/workflows/*.yml`
**Pattern:** Missing `resolve-env`, `ci-gate`, or `deploy` job names
**Severity:** WARNING — allows write with message

**Why:** The 3-job pattern (resolve-env → ci-gate → deploy) provides clear separation of concerns: environment resolution, quality gates, and deployment. Deviating from this pattern reduces clarity and makes debugging harder.

**Required jobs:**
1. `resolve-env` — maps branch to environment
2. `ci-gate` — typecheck + build validation
3. `deploy` — actual deployment

**Note:** This is a WARNING because some workflows (non-deployment) may legitimately have different structures.

---

### RULE-005: Timeout Protection (WARNING)

**Applies to:** `.github/workflows/*.yml`
**Pattern:** Missing `timeout-minutes` on jobs
**Severity:** WARNING — allows write with message

**Why:** Without timeouts, stuck jobs consume runner minutes indefinitely. Standard timeouts:
- `resolve-env`: 1 minute
- `ci-gate`: 5 minutes
- `deploy`: 10 minutes

---

### RULE-006: No Matrix Testing (WARNING)

**Applies to:** `.github/workflows/*.yml`
**Pattern:** `matrix:` strategy block
**Severity:** WARNING — allows write with message

**Why:** Matrix testing across multiple Node versions wastes CI minutes. We pin to Node 22 only. Testing against 18, 20, and 22 triples CI time for no benefit when the deployment target is always 22.

---

### RULE-007: Typecheck Required (INFO)

**Applies to:** `.github/workflows/*.yml`
**Checked at:** Session audit only
**Severity:** INFO

**Why:** `npm run typecheck` must run in the ci-gate job before deployment. Catches type errors at build time instead of runtime.

**Expected:**
```yaml
- name: Type check
  run: npm run typecheck
```

---

### RULE-008: .nvmrc Present (INFO)

**Applies to:** Project root
**Checked at:** Session audit only
**Severity:** INFO

**Why:** `.nvmrc` pins the Node version for local development, ensuring consistency with CI.

**Expected content:**
```
22
```

---

### RULE-009: AI Documentation Present (INFO)

**Applies to:** Project root
**Checked at:** Session audit only
**Severity:** INFO

**Why:** `CLAUDE.md` and `docs/AI_AGENT_GUIDE.md` provide AI agents with project context, reducing errors and improving output quality.

---

## Enforcement Points

### Pre-Write Hook (`validate-ci-config.sh`)

Runs on every `Write` or `Edit` tool call. Checks the target file path against patterns:

| File Pattern | Rules Checked |
|-------------|---------------|
| `.github/workflows/*.yml` | RULE-001, 002, 004, 005, 006 |
| `wrangler.toml` | RULE-003 |
| `wrangler.jsonc` | RULE-003 |
| All other files | Passed through (no checks) |

**Behavior:**
- CRITICAL violation → exit 2 (write blocked)
- WARNING only → exit 0 with message (write allowed)
- No violations → exit 0 silently (write allowed)

### Session Audit (`session-audit.sh`)

Runs at session start. Scans project for existing CI files and reports:

| Check | Rules |
|-------|-------|
| Workflow files | RULE-001, 002, 004, 005 |
| Wrangler config | RULE-003 |
| .nvmrc | RULE-008 |
| AI documentation | RULE-009 |
| tsconfig.json | INFO check |

**Output:** Compliance score (percentage) + categorized findings.

## Handling Blocked Writes

When a write is blocked by the validator:

1. **Read the violation message** — it explains exactly what rule was broken
2. **Fix the content** — remove the violating pattern
3. **Re-attempt the write** — the hook will re-validate
4. **If the rule seems wrong for this case** — explain to the user why the rule exists and let them decide whether to override

**You cannot bypass the hook.** The user must adjust their plugin settings to disable enforcement if they want to override. This is intentional — critical rules should be hard to bypass.

## Rule Evolution

Rules are versioned with the plugin. When adding new rules:
1. Assign the next RULE-XXX number
2. Define severity (CRITICAL blocks, WARNING informs, INFO audits)
3. Add pattern matching to the appropriate hook script
4. Document the rule in this skill
5. Test with both compliant and non-compliant content
