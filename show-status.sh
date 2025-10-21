#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          E2E PIPELINE - CURRENT STATUS & DEMO              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📦 What's Ready:${NC}"
echo "  ✅ AI analysis script (analyze-github.py)"
echo "  ✅ Sample test results with failures"
echo "  ✅ Professional senior QA-level analysis"
echo "  ✅ Fallback mode (works without GitHub token)"
echo "  ✅ CI/CD compatible (stdout/stderr separated)"
echo "  ✅ Known bug: typo in smoke-auth.spec.ts (line 47)"
echo ""

echo -e "${BLUE}🎯 Quick Demo Options:${NC}"
echo ""
echo "  1️⃣  Run AI Analysis Demo (fastest - 10 seconds)"
echo "     ./demo-ai-analysis.sh"
echo ""
echo "  2️⃣  View Existing Analysis Output"
echo "     cat ai-analysis/final-output.json | python3 -m json.tool"
echo ""
echo "  3️⃣  Run Full E2E Pipeline"
echo "     ./test-full-pipeline.sh"
echo ""
echo "  4️⃣  Test with Real Playwright Tests"
echo "     cd automationexercise-e2e-pom"
echo "     npx playwright test tests/smoke/smoke-auth.spec.ts --reporter=json > ../ai-analysis/real-results.json"
echo "     cd ../ai-analysis"
echo "     python3 analyze-github.py real-results.json --fallback"
echo ""

echo -e "${YELLOW}🐛 Current Known Issue:${NC}"
echo "  File: automationexercise-e2e-pom/tests/smoke/smoke-auth.spec.ts"
echo "  Line: 47"
echo "  Bug:  await expect(authPage.currentPage).toHaveURL(/.*signuppp/);"
echo "  Fix:  await expect(authPage.currentPage).toHaveURL(/.*signup/);"
echo ""

echo -e "${GREEN}✨ What the AI Analysis Detects:${NC}"
echo "  🔍 Root Cause: Identifies the typo and explains impact"
echo "  📊 Category: Classifies as 'Test Code Bug - Regex Pattern Error'"
echo "  ⚠️  Severity: Rates as 'High' priority"
echo "  💡 Recommendations: Provides actionable fix steps"
echo "  📝 Code Example: Shows exact before/after code"
echo ""

echo -e "${BLUE}📊 View Sample Analysis Now:${NC}"
echo ""

if [ -f "ai-analysis/final-output.json" ]; then
    echo "Executive Summary from last analysis:"
    python3 -c "
import json
try:
    with open('ai-analysis/final-output.json') as f:
        data = json.load(f)
        exec_summary = data.get('executive_summary', {})
        print(f\"  • Total Failures: {exec_summary.get('total_failures', 'N/A')}\")
        print(f\"  • Critical Issues: {exec_summary.get('critical_issues', 'N/A')}\")
        print(f\"  • Needs Immediate Action: {exec_summary.get('needs_immediate_action', 'N/A')}\")
        print(f\"  • Estimated Fix Time: {exec_summary.get('estimated_fix_time_minutes', 'N/A')} minutes\")
        print(f\"  • Test Health Score: {exec_summary.get('test_health_score', 'N/A')}/100\")
except Exception as e:
    print(f\"  Error loading: {e}\")
"
    echo ""
else
    echo "  No analysis output found yet. Run demo first!"
    echo ""
fi

echo -e "${GREEN}🚀 Recommended Next Steps:${NC}"
echo "  1. Run the demo:  ./demo-ai-analysis.sh"
echo "  2. Review output in terminal"
echo "  3. Check demo-output.json for full details"
echo "  4. (Optional) Fix the typo and re-run"
echo "  5. Push to GitHub and let CI run it"
echo ""

echo -e "${BLUE}📚 Documentation:${NC}"
echo "  • E2E-PIPELINE-GUIDE.md - Complete walkthrough"
echo "  • PROFESSIONAL-AI-ANALYSIS.md - How the AI analysis works"
echo "  • BUG-FIX-TYPO.md - Details on the typo bug"
echo "  • AI-ANALYSIS-SUCCESS-STORY.md - Before/after comparison"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Ready! Run: ./demo-ai-analysis.sh                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
