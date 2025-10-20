#!/bin/bash

# 🤖 AI Analysis Demo Script
# This script demonstrates the AI-powered test analysis system

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🤖 AI-Powered Test Analysis - Demo Script               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if OpenAI API key is set
check_api_key() {
    print_status "Checking OpenAI API key..."
    
    if [ -z "$OPENAI_API_KEY" ]; then
        print_warning "OPENAI_API_KEY not set"
        print_status "AI analysis will run in statistical-only mode (no GPT-4)"
        echo ""
        echo "To enable full AI features:"
        echo "  export OPENAI_API_KEY='sk-proj-your-key-here'"
        echo ""
        AI_ENABLED=false
    else
        print_success "OPENAI_API_KEY is set"
        AI_ENABLED=true
    fi
    echo ""
}

# Check Python installation
check_python() {
    print_status "Checking Python installation..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 not found. Please install Python 3.11+"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_success "Python ${PYTHON_VERSION} found"
    echo ""
}

# Install dependencies
install_dependencies() {
    print_status "Installing AI analysis dependencies..."
    
    cd ai-analysis
    
    if [ ! -f "requirements.txt" ]; then
        print_error "requirements.txt not found in ai-analysis/"
        exit 1
    fi
    
    pip3 install -q -r requirements.txt
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
    
    cd ..
    echo ""
}

# Run test suite
run_tests() {
    print_status "Running E2E test suite (smoke tests)..."
    echo ""
    
    cd automationexercise-e2e-pom
    
    # Clean previous reports
    npm run clean > /dev/null 2>&1 || true
    
    # Run smoke tests
    print_status "Executing Playwright tests..."
    npm run test:smoke:ci
    
    echo ""
    print_success "Tests completed"
    
    cd ..
    echo ""
}

# Generate metrics
generate_metrics() {
    print_status "Generating test metrics..."
    
    cd automationexercise-e2e-pom
    
    npm run metrics:generate > /dev/null 2>&1
    
    if [ -f "test-summary/metrics.json" ]; then
        print_success "Metrics generated successfully"
        
        # Display key metrics
        echo ""
        print_status "Test Results Summary:"
        echo ""
        
        if command -v jq &> /dev/null; then
            echo "  Total Tests: $(cat test-summary/metrics.json | jq -r '.total_test_cases // 0')"
            echo "  Passed: $(cat test-summary/metrics.json | jq -r '.passed_tests // 0')"
            echo "  Failed: $(cat test-summary/metrics.json | jq -r '.failed_tests // 0')"
            echo "  Pass Rate: $(cat test-summary/metrics.json | jq -r '.pass_rate // 0')%"
        else
            print_warning "Install 'jq' to see formatted metrics (brew install jq)"
            echo "  Metrics file: test-summary/metrics.json"
        fi
    else
        print_error "Failed to generate metrics"
        exit 1
    fi
    
    cd ..
    echo ""
}

# Run AI analysis
run_ai_analysis() {
    print_status "Running AI-powered test analysis..."
    echo ""
    
    cd ai-analysis
    
    echo "═══════════════════════════════════════════════════════════"
    python3 analyze.py
    echo "═══════════════════════════════════════════════════════════"
    
    echo ""
    
    if [ -f "../automationexercise-e2e-pom/test-summary/ai-analysis.json" ]; then
        print_success "AI analysis completed successfully"
    else
        print_error "AI analysis failed to generate output"
        exit 1
    fi
    
    cd ..
    echo ""
}

# Display AI insights
display_insights() {
    print_status "AI Analysis Insights:"
    echo ""
    
    ANALYSIS_FILE="automationexercise-e2e-pom/test-summary/ai-analysis.json"
    
    if [ ! -f "$ANALYSIS_FILE" ]; then
        print_error "Analysis file not found"
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        print_warning "Install 'jq' to see formatted insights (brew install jq)"
        echo "Analysis saved to: $ANALYSIS_FILE"
        return
    fi
    
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    AI ANALYSIS SUMMARY                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    HEALTH_SCORE=$(cat $ANALYSIS_FILE | jq -r '.summary.overall_health_score // 0')
    TREND=$(cat $ANALYSIS_FILE | jq -r '.summary.trend // "UNKNOWN"')
    AI_STATUS=$(cat $ANALYSIS_FILE | jq -r '.summary.ai_enabled // false')
    
    FAILURES=$(cat $ANALYSIS_FILE | jq -r '.summary.total_failures_analyzed // 0')
    FLAKY=$(cat $ANALYSIS_FILE | jq -r '.summary.flaky_tests_detected // 0')
    ANOMALIES=$(cat $ANALYSIS_FILE | jq -r '.summary.performance_anomalies // 0')
    ROOT_CAUSES=$(cat $ANALYSIS_FILE | jq -r '.summary.root_causes_identified // 0')
    
    # Health score badge
    if [ $HEALTH_SCORE -ge 90 ]; then
        HEALTH_STATUS="${GREEN}🟢 Excellent${NC}"
    elif [ $HEALTH_SCORE -ge 75 ]; then
        HEALTH_STATUS="${GREEN}🟡 Good${NC}"
    elif [ $HEALTH_SCORE -ge 60 ]; then
        HEALTH_STATUS="${YELLOW}🟠 Fair${NC}"
    else
        HEALTH_STATUS="${RED}🔴 Critical${NC}"
    fi
    
    echo -e "  Health Score:        ${HEALTH_STATUS} (${HEALTH_SCORE}/100)"
    echo "  Trend:               $TREND"
    
    if [ "$AI_STATUS" = "true" ]; then
        echo -e "  AI Analysis:         ${GREEN}✅ Enabled (GPT-4)${NC}"
    else
        echo -e "  AI Analysis:         ${YELLOW}⚠️  Statistical Only${NC}"
    fi
    
    echo ""
    echo "  Failures Analyzed:   $FAILURES"
    echo "  Flaky Tests:         $FLAKY"
    echo "  Anomalies:           $ANOMALIES"
    echo "  Root Causes:         $ROOT_CAUSES"
    echo ""
    
    # Show top recommendations
    REC_COUNT=$(cat $ANALYSIS_FILE | jq '.recommendations | length')
    
    if [ "$REC_COUNT" -gt 0 ]; then
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║                  TOP RECOMMENDATIONS                       ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        
        cat $ANALYSIS_FILE | jq -r '.recommendations[] | "  [\(.priority)] \(.title)\n     \(.description)\n"' | head -20
    fi
    
    # Show flaky tests if any
    FLAKY_COUNT=$(cat $ANALYSIS_FILE | jq '.flaky_tests | length')
    
    if [ "$FLAKY_COUNT" -gt 0 ]; then
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║                    FLAKY TESTS DETECTED                    ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        
        cat $ANALYSIS_FILE | jq -r '.flaky_tests[] | "  • \(.test_name)\n    Flakiness: \(.flakiness_score) | Pass Rate: \(.pass_rate)%\n    Recommendation: \(.recommendation)\n"' | head -20
    fi
    
    echo ""
    print_success "Full analysis available at: $ANALYSIS_FILE"
    echo ""
}

# Generate sample historical data
generate_sample_history() {
    print_status "Generating sample historical data for demo..."
    
    HISTORY_FILE="automationexercise-e2e-pom/test-summary/historical-data.json"
    
    cat > $HISTORY_FILE << 'EOF'
{
  "test-login": [
    {"status": "passed", "duration": 1200},
    {"status": "passed", "duration": 1150},
    {"status": "failed", "duration": 1300},
    {"status": "passed", "duration": 1180},
    {"status": "passed", "duration": 1220},
    {"status": "failed", "duration": 1350},
    {"status": "passed", "duration": 1190}
  ],
  "test-checkout": [
    {"status": "passed", "duration": 2100},
    {"status": "passed", "duration": 2050},
    {"status": "passed", "duration": 2150},
    {"status": "passed", "duration": 2080},
    {"status": "passed", "duration": 2120}
  ],
  "test-search": [
    {"status": "passed", "duration": 800},
    {"status": "failed", "duration": 900},
    {"status": "passed", "duration": 820},
    {"status": "failed", "duration": 850},
    {"status": "passed", "duration": 810},
    {"status": "passed", "duration": 830},
    {"status": "failed", "duration": 880}
  ]
}
EOF
    
    if [ -f "$HISTORY_FILE" ]; then
        print_success "Sample historical data created"
    fi
    
    echo ""
}

# Main execution
main() {
    echo ""
    
    # Step 1: Check environment
    check_api_key
    check_python
    
    # Step 2: Install dependencies
    print_status "═══ Step 1: Setup ═══"
    echo ""
    install_dependencies
    
    # Step 3: Run tests
    print_status "═══ Step 2: Execute Tests ═══"
    echo ""
    run_tests
    
    # Step 4: Generate metrics
    print_status "═══ Step 3: Generate Metrics ═══"
    echo ""
    generate_metrics
    
    # Step 5: Create sample history (for demo)
    generate_sample_history
    
    # Step 6: Run AI analysis
    print_status "═══ Step 4: AI Analysis ═══"
    echo ""
    run_ai_analysis
    
    # Step 7: Display insights
    print_status "═══ Step 5: Display Insights ═══"
    echo ""
    display_insights
    
    # Summary
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    DEMO COMPLETE! ✅                       ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ "$AI_ENABLED" = true ]; then
        print_success "AI-powered analysis with GPT-4 completed successfully"
    else
        print_warning "Demo ran in statistical-only mode"
        echo ""
        echo "To enable full AI features:"
        echo "  1. Get OpenAI API key from https://platform.openai.com/"
        echo "  2. export OPENAI_API_KEY='sk-proj-your-key-here'"
        echo "  3. Re-run this script"
    fi
    
    echo ""
    print_status "Next steps:"
    echo "  1. Review AI insights in: automationexercise-e2e-pom/test-summary/ai-analysis.json"
    echo "  2. Check detailed documentation: AI-SETUP-GUIDE.md"
    echo "  3. Set up GitHub Actions integration (already configured)"
    echo "  4. Add OPENAI_API_KEY to GitHub Secrets"
    echo ""
    
    print_success "System is ready for production use! 🚀"
    echo ""
}

# Run main function
main
