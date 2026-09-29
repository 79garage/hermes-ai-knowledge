#!/usr/bin/env bash
# Regression test for scripts/scan.sh: every planted bug in fixture/ must be reported,
# and fixture/internal/service/good.go (correct patterns) must produce zero hits.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT=$(bash "$HERE/../scripts/scan.sh" "$HERE/fixture" all 2>&1)

EXPECTED=(EH-01 EH-02 EH-03 EH-04 EH-05 EH-06 EH-07 EH-08 EH-09 EH-10 EH-11 EH-12
          FP-01 FP-02 FP-03 FP-04 FP-05 FP-06 FP-07 FP-10 FP-11
          CO-01 CO-02 CO-02b CO-03 CO-04 CO-04b CO-06 CO-07 CO-08 CO-09 CO-10
          DI-02 DI-03 DI-04 DI-05 DI-06 DI-07 DI-10 DI-11)
fail=0
for id in "${EXPECTED[@]}"; do
  grep -q "^== $id " <<<"$OUT" || { echo "MISSING $id"; fail=1; }
done
if grep -q 'good\.go' <<<"$OUT"; then
  echo "FALSE POSITIVE in good.go:"; grep 'good\.go' <<<"$OUT"; fail=1
fi
[[ $fail -eq 0 ]] && echo "ok: ${#EXPECTED[@]} checks detected, good.go clean"
exit $fail
