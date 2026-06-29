#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $1" >&2; exit 1; }

grep -q 'runtimeAuthorityTier' Utils/DepthCapabilityEntitlementProbe.swift || fail "missing runtimeAuthorityTier"
grep -q 'DEPTH_ENTITLEMENT_SHALLOW' project.yml || fail "Watch target missing DEPTH_ENTITLEMENT_SHALLOW compile flag"
grep -q 'infoPlistMetadataTier' Utils/DepthCapabilityEntitlementProbe.swift || fail "missing infoPlistMetadataTier"

echo "PASS: depth capability runtime authority wiring"
