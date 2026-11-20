#!/usr/bin/env python3
"""progress.py: print honest progress, "% done | N open bugs".

    progress.py --tests INDEX --known-failures FILE [--bugs FILE] [--label TEXT] [--detail] [--json]

INDEX    the test list. Either TOML with one [[test]] per spec row:
             [[test]]
             id = "T1.2"
             status = "done"        # done | built | todo (anything but "done" counts as not done)
         or plain text, one row per line: "<id> [status]" (no status = todo; "#" starts a comment).
FILE     known-failures TOML, one [[failure]] per row with at least `id` (and `bug`, `test` if known).
--bugs   optional: other open bugs, TOML [[bug]] with `id`, optional `test_id` and `status` (open | fixed),
         or plain text, one bug ID per line, optionally followed by the test ID.

Rules
  - A row is done only when its status is "done" AND no open bug points at it.
  - Open bugs = the unique bugs of the known-failures rows + the open bugs of --bugs.
  - The % is never printed without the open-bug count.
Exit 0. Exit 2 on a file that can't be read.
Needs Python 3.11+ (tomllib), no other packages.
"""
import argparse
import json
import sys
import tomllib
from pathlib import Path

DONE = {"done", "pass", "passes", "passed"}


def read_toml(path):
    with open(path, "rb") as f:
        return tomllib.load(f)


def is_toml(path):
    return Path(path).suffix.lower() == ".toml"


def text_rows(path):
    for line in Path(path).read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            yield line.split()


def load_tests(path):
    if is_toml(path):
        rows = read_toml(path).get("test", [])
        return {str(r["id"]): str(r.get("status", "todo")).lower() for r in rows}
    return {p[0]: (p[1].lower() if len(p) > 1 else "todo") for p in text_rows(path)}


def load_known_failures(path):
    """Returns {bug_key: test_id}. A row without `bug` counts as its own bug."""
    bugs = {}
    for r in read_toml(path).get("failure", []):
        rid = str(r["id"])
        key = str(r.get("bug") or f"{rid}:{r.get('test', '*')}")
        bugs.setdefault(key, rid)
    return bugs


def load_bugs(path):
    bugs = {}
    if is_toml(path):
        for r in read_toml(path).get("bug", []):
            if str(r.get("status", "open")).lower() != "fixed":
                bugs[str(r["id"])] = str(r.get("test_id", ""))
    else:
        for p in text_rows(path):
            bugs[p[0]] = p[1] if len(p) > 1 else ""
    return bugs


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tests", required=True)
    ap.add_argument("--known-failures", required=True)
    ap.add_argument("--bugs")
    ap.add_argument("--label", default="")
    ap.add_argument("--detail", action="store_true", help="list the rows that aren't done and why")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args(argv)

    try:
        tests = load_tests(a.tests)
        open_bugs = load_known_failures(a.known_failures) if Path(a.known_failures).exists() else {}
        if a.bugs:
            for k, v in load_bugs(a.bugs).items():
                open_bugs.setdefault(k, v)
    except (OSError, tomllib.TOMLDecodeError, KeyError) as e:
        print(f"progress.py: can't read input: {e}", file=sys.stderr)
        return 2

    blocked = {}
    for bug, tid in open_bugs.items():
        if tid:
            blocked.setdefault(tid, []).append(bug)

    total = len(tests)
    done = [t for t, s in tests.items() if s in DONE and t not in blocked]
    pct = 100.0 * len(done) / total if total else 0.0
    n_bugs = len(open_bugs)

    if a.json:
        print(json.dumps({"label": a.label, "rows": total, "done": len(done), "percent": round(pct, 1),
                          "open_bugs": n_bugs, "blocked_rows": blocked}, indent=2))
        return 0

    prefix = f"{a.label}  " if a.label else ""
    print(f"{prefix}{pct:.1f} % done | {n_bugs} open bug{'s' if n_bugs != 1 else ''}"
          f"  ({len(done)} of {total} rows)")
    if a.detail:
        for t, s in tests.items():
            if t in blocked:
                print(f"  {t:12} open bug: {', '.join(blocked[t])}")
            elif s not in DONE:
                print(f"  {t:12} {s}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
