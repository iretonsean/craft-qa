#!/usr/bin/env bash
# canary-run.sh: prove a test can fail. Run the test clean (it must pass), apply a seeded-bug patch, run it again
# (it must fail), revert.
#
#   canary-run.sh <seed.patch> -- <test command ...>
#
# Exit 0 (CANARY OK) when the test passes clean and fails with the seed. Exit 1 (CANARY FAIL) when it passes with the
# seed, or fails without it (then the failure proves nothing). Exit 2 when the patch doesn't apply.
# The patch is always reverted, also on Ctrl+C.
# Needs bash and git (uses "git apply", also outside a repo).
set -uo pipefail

[ $# -ge 3 ] && [ "$2" = "--" ] || { sed -n '2,10p' "$0"; exit 2; }
patch="$1"; shift 2

git apply --check "$patch" 2>/dev/null || { echo "CANARY ERROR: $patch doesn't apply"; exit 2; }
if ! clean=$("$@" 2>&1); then
  echo "CANARY FAIL: the test fails without the seed, so its failure with the seed proves nothing. Fix the test first."
  printf '%s\n' "$clean" | tail -3
  exit 1
fi
git apply "$patch"
trap 'git apply -R "$patch"' EXIT

log=$("$@" 2>&1); rc=$?
if [ "$rc" -eq 0 ]; then
  echo "CANARY FAIL: the test passed with the seeded bug ($patch). It can't catch this bug; rewrite it."
  exit 1
fi
line=$(printf '%s\n' "$log" | grep -m1 -iE 'assert|fail|panicked|error|expected' || printf '%s\n' "$log" | tail -1)
echo "CANARY OK: the test failed with the seeded bug (exit $rc)"
echo "failing log line: $line"
