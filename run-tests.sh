#!/bin/bash

# Test runner script for local validation
# Usage: ./run-tests.sh [environment] [scope] [workers]

set -e

# Default values
ENVIRONMENT=${1:-test}
SCOPE=${2:-smoke}
WORKERS=${3:-3}

echo "Starting E2E Test Execution"
echo "Environment: $ENVIRONMENT"
echo "Scope: $SCOPE" 
echo "Workers: $WORKERS"
echo "================================"

cd automationexercise-e2e-pom

# Clean previous reports
echo "Cleaning previous reports..."
npm run clean

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm ci
fi

# Install Playwright browsers if needed
echo "Installing Playwright browsers..."
npx playwright install --with-deps

# Run tests based on scope
echo "Running tests..."
case "$SCOPE" in
    "smoke")
        npx cross-env NODE_ENV=$ENVIRONMENT npx playwright test tests/smoke --workers=$WORKERS
        ;;
    "regression")
        npx cross-env NODE_ENV=$ENVIRONMENT npx playwright test tests/regression --workers=$WORKERS
        ;;
    "basic")
        npx cross-env NODE_ENV=$ENVIRONMENT npx playwright test tests/basic.spec.ts --workers=$WORKERS
        ;;
    "all")
        npx cross-env NODE_ENV=$ENVIRONMENT npx playwright test --workers=$WORKERS
        ;;
    *)
        echo "Unknown scope: $SCOPE"
        echo "Available scopes: smoke, regression, basic, all"
        exit 1
        ;;
esac

# Generate reports
echo "Generating reports..."
npm run reports

# Run AI Analysis on test results
echo ""
echo "================================"
echo "Running AI Test Analysis..."
echo "================================"

cd ../ai-analysis

# Find the most recent test results
if [ -f "../automationexercise-e2e-pom/test-reports/allure-results/data/test-cases/*.json" ]; then
    echo "✅ Test results found, analyzing..."
    
    # Use fallback mode by default, or AI if GITHUB_TOKEN is set
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "🤖 Using GitHub Copilot AI for analysis..."
        python3 analyze-github.py --test-results ../automationexercise-e2e-pom/test-reports/allure-results 2>analysis.log 1>analysis-output.json || \
            python3 analyze-github.py --fallback 2>analysis.log 1>analysis-output.json
    else
        echo "📊 Using professional fallback analysis (set GITHUB_TOKEN for AI mode)..."
        python3 analyze-github.py --test-results ../automationexercise-e2e-pom/test-reports/allure-results --fallback 2>analysis.log 1>analysis-output.json
    fi
    
    # Display summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 AI ANALYSIS SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -f "analysis-output.json" ]; then
        python3 -c "
import json
try:
    with open('analysis-output.json') as f:
        data = json.load(f)
        summary = data.get('summary', {})
        print(f\"Total Tests: {summary.get('total_tests', 0)}\")
        print(f\"Passed: {summary.get('passed_tests', 0)}\")
        print(f\"Failed: {summary.get('total_failures', 0)}\")
        print(f\"Pass Rate: {summary.get('pass_rate', 0):.1f}%\")
        
        if summary.get('total_failures', 0) > 0:
            print(\"\n❌ Failed Tests:\")
            for test in summary.get('failed_tests', []):
                print(f\"  • {test}\")
        else:
            print(\"\n✅ All tests passed!\")
except Exception as e:
    print(f\"Error reading analysis: {e}\")
"
        echo ""
        echo "📁 Full analysis saved to: ai-analysis/analysis-output.json"
        echo "📋 Debug log saved to: ai-analysis/analysis.log"
    else
        echo "⚠️ Analysis output not generated"
    fi
else
    echo "⚠️ No test results found, skipping AI analysis"
fi

cd ../automationexercise-e2e-pom

echo ""
echo "================================"
echo "Test execution completed!"
echo "================================"
echo "Reports available in:"
echo "  - test-reports/ (HTML report)"
echo "  - allure-report/ (Allure report)"
echo "  - ../ai-analysis/analysis-output.json (AI Analysis)"
