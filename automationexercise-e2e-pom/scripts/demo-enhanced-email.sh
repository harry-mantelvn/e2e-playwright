#!/bin/bash

# Demo Enhanced Email Report
# This script demonstrates the new enhanced email report features

echo "🚀 ENHANCED EMAIL REPORT DEMO"
echo "======================================"
echo ""

# Make sure we're in the right directory
if [[ ! -f "package.json" ]]; then
    echo "❌ Error: Not in automationexercise-e2e-pom directory"
    echo "Please navigate to the correct directory first:"
    echo "cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom"
    exit 1
fi

echo "📋 Enhanced Email Report Features:"
echo "• Detailed test case count (not just test files)"
echo "• Pass/Fail rates with actual test names"
echo "• Quick links to pipeline and artifacts"
echo "• Test coverage analysis"
echo "• Smart recommendations based on results"
echo "• Risk level assessment"
echo "• Action items for different scenarios"
echo ""

# Function to wait for user input
wait_for_input() {
    echo ""
    echo "Press ENTER to continue..."
    read -r
}

echo "🔧 Setting up demo environment..."
echo "Making scripts executable..."
chmod +x generate-test-metrics.sh
chmod +x generate-enhanced-email-report.sh
chmod +x generate-email-report.sh

wait_for_input

echo "📊 STEP 1: Generating Test Metrics"
echo "===================================="
echo "This will analyze our test files and create detailed metrics..."

./generate-test-metrics.sh

echo ""
echo "✅ Metrics generated! Let's see what we collected:"
if [ -f "test-summary/metrics.json" ]; then
    echo ""
    echo "📈 Key Metrics from JSON:"
    echo "------------------------"
    grep -E '"total_tests|"total_test_cases|"pass_rate|"test_coverage' test-summary/metrics.json | sed 's/,$//' | sed 's/^  //'
    echo ""
else
    echo "⚠️ Metrics file not found, but enhanced report will use fallback values"
fi

wait_for_input

echo "📧 STEP 2: Generating Enhanced Email Report"
echo "============================================="
echo "Creating beautiful, comprehensive email report..."

# Set some demo environment variables
export GITHUB_REPOSITORY="your-org/e2e-playwright-framework"
export GITHUB_RUN_ID="12345678"
export GITHUB_SERVER_URL="https://github.com"

./generate-enhanced-email-report.sh

echo ""
echo "✅ Enhanced email report generated!"

wait_for_input

echo "🎯 STEP 3: Viewing the Enhanced Report"
echo "======================================="
echo "Opening the enhanced email report in your browser..."

if [ -f "test-summary/enhanced-email-report.html" ]; then
    echo ""
    echo "📧 Enhanced Email Report Features:"
    echo "• Professional design with status indicators"
    echo "• Detailed test case breakdown"
    echo "• Failed and passed test names"
    echo "• Quick access links to pipeline"
    echo "• Test coverage metrics"
    echo "• Smart recommendations"
    echo "• Risk level assessment"
    echo "• Action items based on results"
    echo ""
    
    # Open in default browser
    if command -v open &> /dev/null; then
        open "test-summary/enhanced-email-report.html"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "test-summary/enhanced-email-report.html"
    else
        echo "📂 Please open this file manually:"
        echo "$(pwd)/test-summary/enhanced-email-report.html"
    fi
    
    echo ""
    echo "🔍 Report file location:"
    echo "$(pwd)/test-summary/enhanced-email-report.html"
else
    echo "❌ Enhanced report file not found!"
    exit 1
fi

wait_for_input

echo "📋 STEP 4: Comparing with Original Report"
echo "=========================================="
echo "Let's generate the original report for comparison..."

./generate-email-report.sh

if [ -f "test-summary/professional-email.html" ]; then
    echo ""
    echo "📊 Original vs Enhanced Report:"
    echo "• Original: Basic metrics and configuration"
    echo "• Enhanced: Detailed test cases, recommendations, coverage"
    echo ""
    echo "🔍 Original report location:"
    echo "$(pwd)/test-summary/professional-email.html"
    echo ""
    echo "You can open both reports to compare the differences!"
fi

wait_for_input

echo "🎭 STEP 5: Testing Different Scenarios"
echo "======================================="
echo "Let's simulate different test results to see how recommendations change..."

# Create scenarios with different pass rates
echo ""
echo "🎯 Scenario 1: Excellent Results (98% pass rate)"
echo "Creating mock metrics for high pass rate..."

cat > test-summary/metrics.json << 'EOF'
{
    "total_tests": 20,
    "total_test_cases": 45,
    "passed_tests": 44,
    "failed_tests": 1,
    "skipped_tests": 0,
    "pass_rate": 98,
    "fail_rate": 2,
    "skip_rate": 0,
    "test_coverage_percentage": 92,
    "duration": "8m 15s",
    "smoke_tests": 5,
    "regression_tests": 12,
    "basic_tests": 3,
    "failed_test_names": "Contact Form Edge Case Validation",
    "passed_test_names": "User Authentication|Product Search|Shopping Cart|Checkout Process|Navigation Flow",
    "execution_timestamp": "2025-10-10T15:30:00Z",
    "test_environment": "staging",
    "browser": "chromium",
    "parallel_workers": "4"
}
EOF

./generate-enhanced-email-report.sh
echo "✅ Excellent scenario report generated!"

wait_for_input

echo "⚠️ Scenario 2: Critical Issues (65% pass rate)"
echo "Creating mock metrics for critical scenario..."

cat > test-summary/metrics.json << 'EOF'
{
    "total_tests": 20,
    "total_test_cases": 45,
    "passed_tests": 29,
    "failed_tests": 16,
    "skipped_tests": 0,
    "pass_rate": 65,
    "fail_rate": 35,
    "skip_rate": 0,
    "test_coverage_percentage": 88,
    "duration": "12m 45s",
    "smoke_tests": 5,
    "regression_tests": 12,
    "basic_tests": 3,
    "failed_test_names": "User Authentication|Contact Form Submission|Product Search|Shopping Cart|Checkout Process|Payment Gateway|Form Validation|Navigation Flow|Data Persistence|Error Handling",
    "passed_test_names": "Home Page Load|Basic Navigation|Header Component|Footer Links|Page Titles",
    "execution_timestamp": "2025-10-10T15:30:00Z",
    "test_environment": "staging",
    "browser": "chromium",
    "parallel_workers": "4"
}
EOF

./generate-enhanced-email-report.sh
mv test-summary/enhanced-email-report.html test-summary/critical-scenario-report.html
echo "🚨 Critical scenario report generated as critical-scenario-report.html!"

wait_for_input

echo "🎉 DEMO COMPLETE!"
echo "=================="
echo ""
echo "📁 Generated Reports:"
echo "• Enhanced Email Report: test-summary/enhanced-email-report.html"
echo "• Original Email Report: test-summary/professional-email.html"
echo "• Critical Scenario: test-summary/critical-scenario-report.html"
echo ""
echo "🔧 Available Commands:"
echo "• npm run email:enhanced    # Generate enhanced email report"
echo "• npm run email:generate    # Generate original email report"
echo "• npm run metrics:generate  # Generate test metrics"
echo "• npm run reports:complete  # Generate all reports"
echo ""
echo "✨ Key Enhanced Features Demonstrated:"
echo "• 📊 Detailed test case metrics (not just test files)"
echo "• 📝 Individual test case names (passed/failed)"
echo "• 🔗 Quick access links to pipeline and artifacts"
echo "• 📈 Test coverage analysis with percentages"
echo "• 🎯 Smart recommendations based on pass rates"
echo "• ⚠️ Risk level assessment (Low/Medium/High/Critical)"
echo "• 📋 Actionable items for different scenarios"
echo "• 🎨 Professional design with status indicators"
echo ""
echo "The enhanced email report provides comprehensive insights for"
echo "managers and stakeholders to make informed decisions about"
echo "deployment readiness and quality status!"
echo ""

# Restore original metrics if they existed
if [ -f "test-summary/metrics-backup.json" ]; then
    mv test-summary/metrics-backup.json test-summary/metrics.json
    echo "📁 Original metrics restored"
fi

echo "🎯 Demo completed successfully! Check out the generated reports."
