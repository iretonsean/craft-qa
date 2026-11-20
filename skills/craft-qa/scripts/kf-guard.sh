#!/usr/bin/env bash
# kf-guard.sh: fail when a branch adds a known-failures row in a commit without an owner's approval trailer.
#
#   kf-guard.sh [--base REF] [--file PATH] [--trailer NAME] [--approvers "Name A,Name B"]
#
#   --base       compare base..HEAD (default origin/main; in CI fetch with full depth)
#   --file       the known-failures file (default known-failures.toml)
#   --trailer    the commit trailer key (default Approved-by)
#   --approvers  optional comma-separated names; the trailer value must start with one of them
#
# For each non-merge commit in base..HEAD that adds a "[[failure]]" line to the file, the commit message must have
# "<trailer>: <name>". Prints one line per added row and a summary. Exit 1 when a row isn't approved or git fails.
# Needs bash and git 2.22+ (trailer formatting).
set -uo pipefail

base="origin/main"; file="known-failures.toml"; trailer="Approved-by"; approvers=""
while [ $# -gt 0 ]; do
  case "$1" in
    --base) base="$2"; shift 2 ;;
    --file) file="$2"; shift 2 ;;
    --trailer) trailer="$2"; shift 2 ;;
    --approvers) approvers="$2"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "kf-guard: unknown argument $1" >&2; exit 2 ;;
  esac
done

if ! commits=$(git rev-list --no-merges --reverse "$base..HEAD" -- "$file" 2>&1); then
  echo "kf-guard FAIL: git can't list $base..HEAD ($commits)"; exit 1
fi

added=0; bad=0
for c in $commits; do
  rows=$(git show --format= -U0 "$c" -- "$file" | grep -cE '^\+[[:space:]]*\[\[failure\]\]')
  [ "$rows" -gt 0 ] || continue
  added=$((added + rows))
  who=$(git log -1 --format="%(trailers:key=$trailer,valueonly,separator=%x2C)" "$c" | tr -d '\n' | sed 's/^ *//;s/ *$//')
  short=$(git rev-parse --short "$c")
  if [ -z "$who" ]; then
    echo "NOT APPROVED  $short adds $rows row(s) to $file with no '$trailer:' trailer"
    bad=$((bad + rows)); continue
  fi
  if [ -n "$approvers" ]; then
    ok=0
    IFS=',' read -ra names <<< "$approvers"
    for n in "${names[@]}"; do
      n=$(echo "$n" | sed 's/^ *//;s/ *$//')
      case "$who" in "$n"*) ok=1 ;; esac
    done
    if [ "$ok" -eq 0 ]; then
      echo "NOT APPROVED  $short adds $rows row(s); '$trailer: $who' isn't in the approvers list"
      bad=$((bad + rows)); continue
    fi
  fi
  echo "approved      $short adds $rows row(s); $trailer: $who"
done

if [ "$bad" -gt 0 ]; then
  echo "kf-guard FAIL: $bad of $added added row(s) not approved"; exit 1
fi
echo "kf-guard OK: $added added row(s), all approved"
