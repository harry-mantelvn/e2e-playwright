#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     TEST AI PIPELINE INTEGRATION - Quick Verification      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

# Test 1: Check if analyze-github.py exists
echo -e "${BLUE}Test 1: Checking AI analysis script...${NC}"
if [ -f "ai-analysis/analyze-github.py" ]; then
    echo -e "${GREEN}✅ PASSED: analyze-github.py exists${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED: analyze-github.py not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 2: Check if format script exists
echo -e "${BLUE}Test 2: Checking GitHub formatter script...${NC}"
if [ -f "ai-analysis/format-github-summary.py" ]; then
    echo -e "${GREEN}✅ PASSED: format-github-summary.py exists${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED: format-github-summary.py not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 3: Check if run-tests.sh has AI integration
echo -e "${BLUE}Test 3: Checking AI integration in run-tests.sh...${NC}"
if grep -q "Running AI Test Analysis" run-tests.sh; then
    echo -e "${GREEN}✅ PASSED: run-tests.sh has AI integration${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED: run-tests.sh missing AI integration${NC}"
    ((FAILED++))
fi
echo ""

# Test 4: Check if GitHub workflow has AI job
echo -e "${BLUE}Test 4: Checking AI job in GitHub workflow...${NC}"
if grep -q "ai-analysis:" .github/workflows/e2e-automation.yml; then
    echo -e "${GREEN}✅ PASSED: GitHub workflow has ai-analysis job${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED: GitHub workflow missing ai-analysis job${NC}"
    ((FAILED++))
fi
echo ""

# Test 5: Run AI analysis on sample data
echo -e "${BLUE}Test 5: Testing AI analysis with sample data...${NC}"
if [ -f "ai-analysis/sample-test-results.json" ]; then
    cd ai-analysis
    python3 analyze-github.py sample-test-results.json --fallback 2>test.log 1>test-output.json
    
    if [ -f "test-output.json" ] && [ -s "test-output.json" ]; then
        # Check if JSON is valid
        if python3 -c "import json; json.load(open('test-output.json'))" 2>/dev/null; then
            echo -e "${GREEN}✅ PASSED: AI analysis executes and produces valid JSON${NC}"
            ((PASSED++))
            
            # Show quick summary
            echo -e "${YELLOW}   Sample output:${NC}"
            python3 -c "
import json
with open('test-output.json') as f:
    data = json.load(f)
    summary = data.get('summary', {})
    print(f'   - Total tests: {summary.get(\"total_tests\", 0)}')
    print(f'   - Failures: {summary.get(\"total_failures\", 0)}')
"
        else
            echo -e "${RED}❌ FAILED: AI analysis produced invalid JSON${NC}"
            ((FAILED++))
        fi
    else
        echo -e "${RED}❌ FAILED: AI analysis did not produce output${NC}"
        ((FAILED++))
    fi
    
    # Cleanup
    rm -f test.log test-output.json
    cd ..
else
    echo -e "${YELLOW}⚠️  SKIPPED: No sample data found${NC}"
fi
echo ""

# Test 6: Check Python syntax
echo -e "${BLUE}Test 6: Validating Python syntax...${NC}"
SYNTAX_OK=true

if python3 -m py_compile ai-analysis/analyze-github.py 2>/dev/null; then
    echo -e "${GREEN}   ✅ analyze-github.py syntax OK${NC}"
else
    echo -e "${RED}   ❌ analyze-github.py has syntax errors${NC}"
    SYNTAX_OK=false
fi

if python3 -m py_compile ai-analysis/format-github-summary.py 2>/dev/null; then
    echo -e "${GREEN}   ✅ format-github-summary.py syntax OK${NC}"
else
    echo -e "${RED}   ❌ format-github-summary.py has syntax errors${NC}"
    SYNTAX_OK=false
fi

if [ "$SYNTAX_OK" = true ]; then
    echo -e "${GREEN}✅ PASSED: All Python scripts have valid syntax${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED: Python syntax errors detected${NC}"
    ((FAILED++))
fi
echo ""

# Test 7: Check documentation
echo -e "${BLUE}Test 7: Checking documentation...${NC}"
DOC_COUNT=0
[ -f "AI-PIPELINE-INTEGRATION.md" ] && ((DOC_COUNT++))
[ -f "PROFESSIONAL-AI-ANALYSIS.md" ] && ((DOC_COUNT++))
[ -f "E2E-PIPELINE-GUIDE.md" ] && ((DOC_COUNT++))

if [ $DOC_COUNT -ge 2 ]; then
    echo -e "${GREEN}✅ PASSED: Documentation available ($DOC_COUNT files)${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️  WARNING: Limited documentation ($DOC_COUNT files)${NC}"
fi
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                      TEST SUMMARY                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ ALL TESTS PASSED - Integration Ready!                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📚 Next Steps:${NC}"
    echo "  1. Run: ./run-tests.sh test smoke 3"
    echo "  2. Check: ai-analysis/analysis-output.json"
    echo "  3. Push to GitHub to test CI/CD integration"
    echo ""
    echo -e "${BLUE}📖 Documentation:${NC}"
    echo "  - AI-PIPELINE-INTEGRATION.md (Complete guide)"
    echo "  - PROFESSIONAL-AI-ANALYSIS.md (How it works)"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ SOME TESTS FAILED - Please Fix Issues                 ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please check the errors above and fix them."
    exit 1
fi
