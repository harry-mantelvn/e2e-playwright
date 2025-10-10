#!/bin/bash

# Demo Script for POM Showcase
# Interactive guide for live presentation

echo "🎯 POM SHOWCASE DEMO SCRIPT"
echo "================================"
echo "This script will guide you through the live demo portion"
echo ""

# Function to wait for user input
wait_for_input() {
    echo ""
    echo "Press ENTER to continue to next step..."
    read -r
}

# Function to run command with explanation
run_demo_command() {
    local description="$1"
    local command="$2"
    
    echo ""
    echo "📋 NEXT: $description"
    echo "💻 Command: $command"
    echo ""
    echo "Press ENTER to execute..."
    read -r
    
    echo "Executing: $command"
    eval "$command"
}

echo "Make sure you're in the correct directory:"
echo "cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom"
echo ""

wait_for_input

echo "🚀 DEMO SEQUENCE"
echo "=================="
echo ""

echo "1. Show Framework Structure"
echo "2. Demonstrate Page Objects"  
echo "3. Run Live Tests"
echo "4. Generate Reports"
echo ""

wait_for_input

echo "📁 STEP 1: Show Framework Structure"
echo "======================================"
echo ""
echo "Open these files in VS Code tabs (in order):"
echo "1. pages/base-page.ts"
echo "2. pages/contact-page/contact.page.ts"
echo "3. helper/page-factory.ts"
echo "4. tests/regression/contact/submit-contact-form.spec.ts"
echo ""

wait_for_input

echo "💻 STEP 2: Live Coding Demonstration"
echo "======================================"
echo ""
echo "Show each file and explain:"
echo "- BasePage: Common functionality"
echo "- ContactPage: Page-specific implementation"
echo "- PageFactory: Instance management"
echo "- Test: Clean, readable business logic"
echo ""

wait_for_input

echo "🧪 STEP 3: Run Live Tests"
echo "=========================="

# Check if we're in the right directory
if [[ ! -f "package.json" ]]; then
    echo "❌ Error: Not in automationexercise-e2e-pom directory"
    echo "Please navigate to the correct directory first:"
    echo "cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom"
    exit 1
fi

run_demo_command "Install dependencies (if needed)" "npm install"

run_demo_command "Run contact form test" "npm run test:contact"

echo ""
echo "✅ Test completed! Show the terminal output to audience."

wait_for_input

echo "📊 STEP 4: Generate and Show Reports"
echo "====================================="

run_demo_command "Generate Allure report" "npm run allure:generate"

echo ""
echo "📈 Opening Allure report in browser..."
echo "This will show professional test reporting with:"
echo "- Test execution timeline"
echo "- Screenshots and videos"
echo "- Detailed step breakdown"
echo "- Test metrics and trends"

wait_for_input

run_demo_command "Open Allure report" "npm run allure:open"

echo ""
echo "🎯 DEMO COMPLETE!"
echo "=================="
echo ""
echo "Key points to emphasize:"
echo "✅ Clean, maintainable code structure"
echo "✅ Business-readable test scenarios"
echo "✅ Professional reporting"
echo "✅ Robust error handling"
echo "✅ Easy to extend and maintain"
echo ""

echo "💡 ADDITIONAL DEMO COMMANDS (if time permits):"
echo "=============================================="
echo ""
echo "Show different test types:"
echo "npm run test:auth          # Authentication tests"
echo "npm run test:smoke         # Smoke test suite"
echo "npm run test:ui            # Interactive UI mode"
echo ""
echo "Show debugging capabilities:"
echo "npm run test:debug         # Debug mode"
echo "npm run test:headed        # Headed browser mode"
echo ""

echo "🎤 Q&A PREPARATION"
echo "==================="
echo ""
echo "Common questions and where to find answers:"
echo ""
echo "Q: How do you handle dynamic locators?"
echo "A: Show data-driven approach in test-data.ts"
echo ""
echo "Q: What about API testing?"
echo "A: Show api-helper.ts and API test examples"
echo ""
echo "Q: How do you manage test environments?"
echo "A: Show env-config.ts and environment setup"
echo ""
echo "Q: What about CI/CD integration?"
echo "A: Show .github/workflows/e2e-automation.yml"
echo ""

echo "✨ PRESENTATION TIPS"
echo "==================="
echo ""
echo "1. Keep energy high during demo"
echo "2. Explain what you're typing as you type"
echo "3. Point out key benefits as they appear"
echo "4. Have backup screenshots ready"
echo "5. Stay calm if something fails - it happens!"
echo ""

echo "🎯 Good luck with your presentation! 🚀"
