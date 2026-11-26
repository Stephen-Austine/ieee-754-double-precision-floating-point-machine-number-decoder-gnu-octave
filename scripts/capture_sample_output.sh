#!/usr/bin/env bash
# Re-create the plain-text sample output stored in docs/sample-output/.
# Run from anywhere:  bash scripts/capture_sample_output.sh
set -euo pipefail
cd "$(dirname "$0")/.."

octave --no-gui --quiet src/demo_ieee754.m > docs/sample-output/demo-ieee754.txt  2>/dev/null
octave --no-gui --quiet tests/run_tests.m  > docs/sample-output/test-results.txt  2>/dev/null
echo "Sample output written to docs/sample-output/"
