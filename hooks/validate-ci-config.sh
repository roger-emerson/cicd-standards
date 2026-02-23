#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# CI Standards — Pre-Write/Edit Validator
# Blocks writes that violate critical CI/CD rules.
#
# Exit codes:
#   0 = allow (file is compliant or not a CI config file)
#   2 = block (violation found — message sent to Claude)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Read tool_input JSON from stdin
INPUT=$(cat)

# Extract file_path — works for both Write (file_path) and Edit (file_path)
FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')

# If we can't determine the file path, allow the write
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Determine if this is a file we care about
# ─────────────────────────────────────────────────────────────────────────────
IS_WORKFLOW=false
IS_WRANGLER_TOML=false
IS_WRANGLER_JSONC=false

case "$FILE_PATH" in
  */.github/workflows/*.yml|*/.github/workflows/*.yaml)
    IS_WORKFLOW=true
    ;;
  */wrangler.toml)
    IS_WRANGLER_TOML=true
    ;;
  */wrangler.jsonc)
    IS_WRANGLER_JSONC=true
    ;;
  *)
    # Not a CI config file — allow
    exit 0
    ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# Extract content from tool input
# For Write: "content" field
# For Edit: "new_string" field (we validate the replacement text)
# ─────────────────────────────────────────────────────────────────────────────
CONTENT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # Try 'content' first (Write tool), then 'new_string' (Edit tool)
    print(data.get('content', data.get('new_string', '')))
except:
    print('')
" 2>/dev/null || echo "")

if [ -z "$CONTENT" ]; then
  exit 0
fi

VIOLATIONS=""

# ─────────────────────────────────────────────────────────────────────────────
# GitHub Actions Workflow Checks
# ─────────────────────────────────────────────────────────────────────────────
if [ "$IS_WORKFLOW" = true ]; then

  # CRITICAL: No continue-on-error
  if echo "$CONTENT" | grep -qi "continue-on-error.*true"; then
    VIOLATIONS="${VIOLATIONS}CRITICAL: 'continue-on-error: true' found. This masks failures and must never be used.\n"
  fi

  # CRITICAL: Node version must be 22
  if echo "$CONTENT" | grep -qE "node-version.*['\"]?(1[0-9]|20|21|23|24)['\"]?" 2>/dev/null; then
    VIOLATIONS="${VIOLATIONS}CRITICAL: Node version must be 22. Found a non-22 version specified.\n"
  fi

  # WARNING: Check for 3-job structure (resolve-env, ci-gate, deploy)
  HAS_RESOLVE=$(echo "$CONTENT" | grep -c "resolve-env" || true)
  HAS_CIGATE=$(echo "$CONTENT" | grep -c "ci-gate" || true)
  HAS_DEPLOY=$(echo "$CONTENT" | grep -c "deploy" || true)
  if [ "$HAS_RESOLVE" -eq 0 ] || [ "$HAS_CIGATE" -eq 0 ] || [ "$HAS_DEPLOY" -eq 0 ]; then
    VIOLATIONS="${VIOLATIONS}WARNING: Workflow should follow the 3-job pattern (resolve-env → ci-gate → deploy).\n"
  fi

  # WARNING: Check for timeout-minutes on jobs
  HAS_TIMEOUT=$(echo "$CONTENT" | grep -c "timeout-minutes" || true)
  if [ "$HAS_TIMEOUT" -eq 0 ]; then
    VIOLATIONS="${VIOLATIONS}WARNING: No timeout-minutes found. All jobs should have timeouts (1m/5m/10m).\n"
  fi

  # WARNING: Check for matrix strategy (anti-pattern)
  if echo "$CONTENT" | grep -q "matrix:"; then
    VIOLATIONS="${VIOLATIONS}WARNING: Matrix strategy detected. Use single Node 22 version, not matrix testing.\n"
  fi

fi

# ─────────────────────────────────────────────────────────────────────────────
# Wrangler TOML Checks
# ─────────────────────────────────────────────────────────────────────────────
if [ "$IS_WRANGLER_TOML" = true ]; then

  # CRITICAL: workers_dev must be false
  if echo "$CONTENT" | grep -qE "workers_dev\s*=\s*true"; then
    VIOLATIONS="${VIOLATIONS}CRITICAL: 'workers_dev = true' found in wrangler.toml. Must always be false to prevent unintended public .workers.dev URLs.\n"
  fi

fi

# ─────────────────────────────────────────────────────────────────────────────
# Wrangler JSONC Checks
# ─────────────────────────────────────────────────────────────────────────────
if [ "$IS_WRANGLER_JSONC" = true ]; then

  # CRITICAL: workers_dev must be false
  if echo "$CONTENT" | grep -qE '"workers_dev"\s*:\s*true'; then
    VIOLATIONS="${VIOLATIONS}CRITICAL: 'workers_dev: true' found in wrangler.jsonc. Must always be false.\n"
  fi

fi

# ─────────────────────────────────────────────────────────────────────────────
# Report Results
# ─────────────────────────────────────────────────────────────────────────────
if [ -n "$VIOLATIONS" ]; then
  # Check if any are CRITICAL (those block; WARNINGs just inform)
  if echo "$VIOLATIONS" | grep -q "^CRITICAL:"; then
    echo "CI Standards Violation — write blocked:"
    echo ""
    echo -e "$VIOLATIONS"
    echo "Fix the CRITICAL violations before writing this file."
    echo "Reference: enforcement-rules skill for full rule definitions."
    exit 2
  else
    # Warnings only — allow but inform
    echo "CI Standards Warnings (write allowed):"
    echo ""
    echo -e "$VIOLATIONS"
    echo "Consider addressing these warnings."
    exit 0
  fi
fi

# All clear
exit 0
