#!/bin/bash
cd /Users/nam.nguyenduc/e2e-playwright/ai-analysis
echo "Testing improved failure detection..."
python3 analyze-github.py sample-test-results.json test-debug.json
echo ""
echo "Checking output..."
cat test-debug.json | python3 -m json.tool | grep -A 5 "executive_summary"
