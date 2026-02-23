#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# CICD Standards — Session Start Audit
# Scans the current project for CI config files and reports compliance status.
# Non-blocking (informational only) — provides context to Claude at session start.
#
# Exit code: always 0 (never blocks)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Work from the current directory (project root)
PROJECT_DIR="${PWD}"

COMPLIANT=()
WARNINGS=()
VIOLATIONS=()
MISSING=()

# ─────────────────────────────────────────────────────────────────────────────
# Check for CI workflow files
# ─────────────────────────────────────────────────────────────────────────────
WORKFLOW_FILES=$(find "$PROJECT_DIR/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)

if [ -z "$WORKFLOW_FILES" ]; then
  MISSING+=("No GitHub Actions workflows found (.github/workflows/*.yml)")
else
  for WF in $WORKFLOW_FILES; do
    WF_NAME=$(basename "$WF")

    # Check continue-on-error
    if grep -qi "continue-on-error.*true" "$WF" 2>/dev/null; then
      VIOLATIONS+=("$WF_NAME: contains continue-on-error: true")
    fi

    # Check Node version
    if grep -qE "node-version.*['\"]?(1[0-9]|20|21|23|24)['\"]?" "$WF" 2>/dev/null; then
      VIOLATIONS+=("$WF_NAME: uses non-22 Node version")
    elif grep -qE "node-version" "$WF" 2>/dev/null; then
      COMPLIANT+=("$WF_NAME: Node version configured")
    fi

    # Check 3-job pattern
    HAS_RESOLVE=$(grep -c "resolve-env" "$WF" 2>/dev/null || true)
    HAS_CIGATE=$(grep -c "ci-gate" "$WF" 2>/dev/null || true)
    if [ "$HAS_RESOLVE" -gt 0 ] && [ "$HAS_CIGATE" -gt 0 ]; then
      COMPLIANT+=("$WF_NAME: follows 3-job pattern")
    else
      WARNINGS+=("$WF_NAME: does not follow 3-job pattern (resolve-env → ci-gate → deploy)")
    fi

    # Check timeouts
    HAS_TIMEOUT=$(grep -c "timeout-minutes" "$WF" 2>/dev/null || true)
    if [ "$HAS_TIMEOUT" -ge 3 ]; then
      COMPLIANT+=("$WF_NAME: timeouts configured")
    else
      WARNINGS+=("$WF_NAME: missing timeout-minutes on some jobs")
    fi
  done
fi

# ─────────────────────────────────────────────────────────────────────────────
# Check package manager consistency
# ─────────────────────────────────────────────────────────────────────────────
DETECTED_PM="npm"
if [ -f "$PROJECT_DIR/pnpm-lock.yaml" ]; then
  DETECTED_PM="pnpm"
elif [ -f "$PROJECT_DIR/yarn.lock" ]; then
  DETECTED_PM="yarn"
fi

if [ -n "$WORKFLOW_FILES" ]; then
  for WF in $WORKFLOW_FILES; do
    WF_NAME=$(basename "$WF")

    # Check if workflow cache strategy matches detected package manager
    if [ "$DETECTED_PM" = "pnpm" ]; then
      if grep -q 'cache: "npm"' "$WF" 2>/dev/null; then
        WARNINGS+=("$WF_NAME: uses npm cache but project uses pnpm (pnpm-lock.yaml found)")
      elif grep -q 'cache: "pnpm"' "$WF" 2>/dev/null; then
        COMPLIANT+=("$WF_NAME: cache matches package manager (pnpm)")
      fi
    elif [ "$DETECTED_PM" = "npm" ]; then
      if grep -q 'cache: "pnpm"' "$WF" 2>/dev/null; then
        WARNINGS+=("$WF_NAME: uses pnpm cache but project uses npm (package-lock.json found)")
      elif grep -q 'cache: "npm"' "$WF" 2>/dev/null; then
        COMPLIANT+=("$WF_NAME: cache matches package manager (npm)")
      fi
    fi
  done
fi

# ─────────────────────────────────────────────────────────────────────────────
# Check Wrangler configuration
# ─────────────────────────────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/wrangler.toml" ]; then
  if grep -qE "workers_dev\s*=\s*true" "$PROJECT_DIR/wrangler.toml" 2>/dev/null; then
    VIOLATIONS+=("wrangler.toml: workers_dev = true (must be false)")
  else
    COMPLIANT+=("wrangler.toml: workers_dev correctly set")
  fi
elif [ -f "$PROJECT_DIR/wrangler.jsonc" ]; then
  if grep -qE '"workers_dev"\s*:\s*true' "$PROJECT_DIR/wrangler.jsonc" 2>/dev/null; then
    VIOLATIONS+=("wrangler.jsonc: workers_dev is true (must be false)")
  else
    COMPLIANT+=("wrangler.jsonc: workers_dev correctly set")
  fi
else
  MISSING+=("No wrangler config found (wrangler.toml or wrangler.jsonc)")
fi

# ─────────────────────────────────────────────────────────────────────────────
# Check .nvmrc
# ─────────────────────────────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/.nvmrc" ]; then
  NVM_VERSION=$(cat "$PROJECT_DIR/.nvmrc" | tr -d '[:space:]')
  if [ "$NVM_VERSION" = "22" ]; then
    COMPLIANT+=(".nvmrc: Node 22")
  else
    WARNINGS+=(".nvmrc: specifies Node $NVM_VERSION (should be 22)")
  fi
else
  MISSING+=("No .nvmrc file (should specify Node 22)")
fi

# ─────────────────────────────────────────────────────────────────────────────
# Check AI documentation
# ─────────────────────────────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
  COMPLIANT+=("CLAUDE.md: present")
else
  MISSING+=("No CLAUDE.md (AI agent documentation)")
fi

if [ -f "$PROJECT_DIR/docs/AI_AGENT_GUIDE.md" ]; then
  COMPLIANT+=("docs/AI_AGENT_GUIDE.md: present")
else
  MISSING+=("No docs/AI_AGENT_GUIDE.md (operational guide)")
fi

# ─────────────────────────────────────────────────────────────────────────────
# Check TypeScript configuration
# ─────────────────────────────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
  COMPLIANT+=("tsconfig.json: present")
else
  MISSING+=("No tsconfig.json")
fi

# ─────────────────────────────────────────────────────────────────────────────
# Build summary
# ─────────────────────────────────────────────────────────────────────────────
TOTAL=$((${#COMPLIANT[@]} + ${#WARNINGS[@]} + ${#VIOLATIONS[@]} + ${#MISSING[@]}))
SCORE=0
if [ "$TOTAL" -gt 0 ]; then
  SCORE=$(( (${#COMPLIANT[@]} * 100) / TOTAL ))
fi

# Determine status
if [ ${#VIOLATIONS[@]} -gt 0 ]; then
  STATUS="VIOLATIONS FOUND"
elif [ ${#WARNINGS[@]} -gt 0 ] || [ ${#MISSING[@]} -gt 0 ]; then
  STATUS="NEEDS ATTENTION"
else
  STATUS="FULLY COMPLIANT"
fi

# Output as additionalContext JSON
cat <<EOF
{
  "additionalContext": "CICD Standards Audit — ${STATUS} (Score: ${SCORE}%)\n\nCompliant (${#COMPLIANT[@]}):$(for item in "${COMPLIANT[@]+"${COMPLIANT[@]}"}"; do echo "\n  ✅ $item"; done)\n\nViolations (${#VIOLATIONS[@]}):$(for item in "${VIOLATIONS[@]+"${VIOLATIONS[@]}"}"; do echo "\n  ❌ $item"; done)\n\nWarnings (${#WARNINGS[@]}):$(for item in "${WARNINGS[@]+"${WARNINGS[@]}"}"; do echo "\n  ⚠️ $item"; done)\n\nMissing (${#MISSING[@]}):$(for item in "${MISSING[@]+"${MISSING[@]}"}"; do echo "\n  📋 $item"; done)\n\nRun /cicd-standards to fix issues."
}
EOF

exit 0
