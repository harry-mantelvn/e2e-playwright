#!/bin/bash

set -e  # Exit on error

echo "======================================"
echo "E2E PIPELINE TEST - Full Walkthrough"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Step 1: Testing AI Analysis with Sample Results (Fallback Mode)${NC}"
echo "--------------------------------------"
cd /Users/nam.nguyenduc/e2e-playwright/ai-analysis

echo "Running analysis on sample-test-results.json..."
python3 analyze-github.py sample-test-results.json --fallback 2>test-pipeline.log 1>test-pipeline-output.json

echo ""
echo -e "${GREEN}✓ Analysis completed${NC}"
echo ""
echo -e "${YELLOW}Debug Log (stderr):${NC}"
cat test-pipeline.log
echo ""
echo -e "${YELLOW}Analysis Output (stdout - JSON):${NC}"
cat test-pipeline-output.json | python3 -m json.tool
echo ""
echo ""

echo -e "${BLUE}Step 2: Checking Key Metrics${NC}"
echo "--------------------------------------"
echo -e "${YELLOW}Total Failures Detected:${NC}"
cat test-pipeline-output.json | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['summary']['total_failures'])"

echo -e "${YELLOW}Failed Tests:${NC}"
cat test-pipeline-output.json | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f'  - {t}') for t in data['summary']['failed_tests']]"

echo ""
echo -e "${YELLOW}Executive Summary:${NC}"
cat test-pipeline-output.json | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['executive_summary'])"

echo ""
echo ""

echo -e "${BLUE}Step 3: Viewing Detailed Analysis for First Failure${NC}"
echo "--------------------------------------"
cat test-pipeline-output.json | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data['failures']:
    failure = data['failures'][0]
    print(f\"Test: {failure['test_name']}\")
    print(f\"File: {failure['file']}\")
    print(f\"Root Cause: {failure['analysis']['root_cause']}\")
    print(f\"Category: {failure['analysis']['category']}\")
    print(f\"Severity: {failure['analysis']['severity']}\")
    print(f\"\\nRecommendations:\")
    for i, rec in enumerate(failure['analysis']['recommendations'], 1):
        print(f\"  {i}. {rec}\")
"

echo ""
echo ""

echo -e "${GREEN}======================================"
echo "PIPELINE TEST COMPLETED SUCCESSFULLY!"
echo "======================================${NC}"
echo ""
echo "Files generated:"
echo "  - test-pipeline.log (debug output)"
echo "  - test-pipeline-output.json (analysis results)"
echo ""
echo "Next steps:"
echo "  1. Review the output above"
echo "  2. Run actual Playwright tests: cd automationexercise-e2e-pom && npx playwright test --reporter=json > ../ai-analysis/real-test-results.json"
echo "  3. Analyze real results: python3 analyze-github.py real-test-results.json"
echo "  4. Fix the typo in smoke-auth.spec.ts (signuppp → signup)"
echo "  5. Re-run tests to verify all pass"
