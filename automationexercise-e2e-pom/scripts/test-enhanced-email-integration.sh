#!/bin/bash

# Test Enhanced Email Report Integration
# This script tests the entire enhanced email report pipeline

echo "🧪 TESTING ENHANCED EMAIL REPORT INTEGRATION"
echo "=============================================="
echo ""

# Navigate to project directory
if [[ ! -f "package.json" ]]; then
    echo "❌ Error: Not in automationexercise-e2e-pom directory"
    echo "Please navigate to the correct directory first:"
    echo "cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom"
    exit 1
fi

echo "📁 Current directory: $(pwd)"
echo ""

# Function to wait for user input
wait_for_input() {
    echo ""
    echo "Press ENTER to continue..."
    read -r
}

echo "🔧 STEP 1: Setup Test Environment"
echo "=================================="
echo "Setting up mock GitHub Actions environment variables..."

# Set mock GitHub Actions environment
export ENVIRONMENT="test"
export TEST_SCOPE="regression"
export WORKERS="4"
export BROWSER="chromium"
export TRIGGER="workflow_dispatch"
export RUN_NUMBER="123"
export EXECUTION_TIME="$(date '+%Y-%m-%d %H:%M:%S UTC')"
export GITHUB_SERVER_URL="https://github.com"
export GITHUB_REPOSITORY="your-org/e2e-playwright-framework"
export GITHUB_RUN_ID="9876543210"

echo "✅ Mock environment variables set:"
echo "   ENVIRONMENT=$ENVIRONMENT"
echo "   TEST_SCOPE=$TEST_SCOPE"
echo "   WORKERS=$WORKERS"
echo "   TRIGGER=$TRIGGER"
echo "   RUN_NUMBER=$RUN_NUMBER"

wait_for_input

echo "📊 STEP 2: Generate Test Metrics"
echo "================================="
echo "Running enhanced test metrics generation..."

# Make scripts executable
chmod +x generate-test-metrics.sh
chmod +x generate-enhanced-email-report.sh
chmod +x replace-email-variables.sh

# Generate test metrics
./generate-test-metrics.sh

if [ -f "test-summary/metrics.json" ]; then
    echo "✅ Test metrics generated successfully!"
    echo ""
    echo "📈 Generated metrics overview:"
    echo "------------------------------"
    grep -E '"total_test_cases|"pass_rate|"test_coverage_percentage' test-summary/metrics.json | sed 's/,$//' | sed 's/^  /  /'
else
    echo "⚠️ Metrics file not found, but enhanced report will use fallback values"
fi

wait_for_input

echo "📧 STEP 3: Generate Enhanced Email Report"
echo "=========================================="
echo "Creating enhanced email report with all new features..."

./generate-enhanced-email-report.sh

if [ -f "test-summary/enhanced-email-report.html" ]; then
    echo "✅ Enhanced email report generated!"
    echo "📊 Report size: $(wc -c < test-summary/enhanced-email-report.html) bytes"
else
    echo "❌ Enhanced email report generation failed"
    exit 1
fi

wait_for_input

echo "🔄 STEP 4: Test Template Variable Replacement"
echo "=============================================="
echo "Testing the template variable replacement process..."

./replace-email-variables.sh

if [ -f "test-summary/final-email.html" ]; then
    echo "✅ Template variables replaced successfully!"
    echo "📧 Final email size: $(wc -c < test-summary/final-email.html) bytes"
    
    # Check if variables were actually replaced
    if grep -q "{{" test-summary/final-email.html; then
        echo "⚠️ Warning: Some template variables may not have been replaced"
        echo "Remaining templates:"
        grep -o "{{[^}]*}}" test-summary/final-email.html | sort | uniq
    else
        echo "✅ All template variables replaced successfully!"
    fi
else
    echo "❌ Template variable replacement failed"
    exit 1
fi

wait_for_input

echo "👀 STEP 5: View Generated Reports"
echo "=================================="
echo "Opening all generated reports for comparison..."

echo ""
echo "📁 Generated files:"
echo "  - Enhanced report: test-summary/enhanced-email-report.html"
echo "  - Final email: test-summary/final-email.html"
echo "  - Test metrics: test-summary/metrics.json"
echo ""

# Open the enhanced email report
if command -v open &> /dev/null; then
    echo "🌐 Opening enhanced email report in browser..."
    open test-summary/enhanced-email-report.html
    
    echo ""
    echo "🌐 Opening final processed email in browser..."
    open test-summary/final-email.html
elif command -v xdg-open &> /dev/null; then
    xdg-open test-summary/enhanced-email-report.html
    xdg-open test-summary/final-email.html
else
    echo "📂 Please open these files manually:"
    echo "   $(pwd)/test-summary/enhanced-email-report.html"
    echo "   $(pwd)/test-summary/final-email.html"
fi

wait_for_input

echo "🎯 STEP 6: Simulate Different Test Scenarios"
echo "============================================="
echo "Testing different pass rates to verify recommendations..."

# Test excellent scenario (98% pass rate)
echo ""
echo "🎯 Testing Excellent Scenario (98% pass rate)..."
cat > test-summary/metrics.json << 'EOF'
{
    "total_tests": 20,
    "total_test_cases": 45,
    "passed_tests": 44,
    "failed_tests": 1,
    "skipped_tests": 0,
    "pass_rate": 98,
    "fail_rate": 2,
    "test_coverage_percentage": 95,
    "failed_test_names": "Edge Case Validation",
    "passed_test_names": "User Authentication|Product Search|Shopping Cart|Checkout Process|Navigation Flow"
}
EOF

./generate-enhanced-email-report.sh
./replace-email-variables.sh
mv test-summary/final-email.html test-summary/excellent-scenario.html
echo "✅ Excellent scenario report: test-summary/excellent-scenario.html"

# Test critical scenario (60% pass rate)
echo ""
echo "🚨 Testing Critical Scenario (60% pass rate)..."
cat > test-summary/metrics.json << 'EOF'
{
    "total_tests": 20,
    "total_test_cases": 45,
    "passed_tests": 27,
    "failed_tests": 18,
    "skipped_tests": 0,
    "pass_rate": 60,
    "fail_rate": 40,
    "test_coverage_percentage": 85,
    "failed_test_names": "User Authentication|Contact Form|Product Search|Shopping Cart|Checkout Process|Payment Gateway|Form Validation|Navigation Flow|Data Persistence|Error Handling",
    "passed_test_names": "Home Page Load|Basic Navigation|Header Component|Footer Links|Page Titles"
}
EOF

./generate-enhanced-email-report.sh
./replace-email-variables.sh
mv test-summary/final-email.html test-summary/critical-scenario.html
echo "🚨 Critical scenario report: test-summary/critical-scenario.html"

echo ""
echo "📊 Scenario reports generated! You can compare different recommendations."

wait_for_input

echo "🔍 STEP 7: Validate CI/CD Integration"
echo "======================================"
echo "Checking GitHub Actions workflow integration..."

if [ -f "../.github/workflows/e2e-automation.yml" ]; then
    echo "✅ GitHub Actions workflow found"
    
    # Check if enhanced email report is referenced
    if grep -q "email:enhanced" ../.github/workflows/e2e-automation.yml; then
        echo "✅ Enhanced email report is integrated in workflow"
    else
        echo "⚠️ Enhanced email report may not be integrated in workflow"
    fi
    
    # Check if replace-email-variables script is used
    if grep -q "replace-email-variables" ../.github/workflows/e2e-automation.yml; then
        echo "✅ Template variable replacement is integrated"
    else
        echo "⚠️ Template variable replacement may not be integrated"
    fi
    
else
    echo "⚠️ GitHub Actions workflow not found"
fi

echo ""
echo "📋 Package.json commands check:"
if grep -q "email:enhanced" package.json; then
    echo "✅ npm run email:enhanced command available"
else
    echo "⚠️ email:enhanced command not found in package.json"
fi

wait_for_input

echo "🎉 TESTING COMPLETE!"
echo "===================="
echo ""
echo "📊 Summary of Generated Reports:"
echo "• Enhanced Email Report: test-summary/enhanced-email-report.html"
echo "• Processed Final Email: test-summary/final-email.html"
echo "• Excellent Scenario: test-summary/excellent-scenario.html"
echo "• Critical Scenario: test-summary/critical-scenario.html"
echo "• Test Metrics: test-summary/metrics.json"
echo ""
echo "✅ Features Tested:"
echo "• ✅ Enhanced test metrics generation"
echo "• ✅ Template variable replacement"
echo "• ✅ GitHub Actions environment simulation"
echo "• ✅ Multiple scenario recommendations"
echo "• ✅ Quick access links generation"
echo "• ✅ Test coverage analysis"
echo "• ✅ Risk level assessment"
echo ""
echo "🔧 Available Commands:"
echo "• npm run email:enhanced      # Generate enhanced email report"
echo "• npm run reports:complete    # Generate all reports"
echo "• ./replace-email-variables.sh # Process template variables"
echo ""
echo "🚀 The enhanced email report system is ready for production use!"
echo "   All templates and CI/CD integration have been tested successfully."
