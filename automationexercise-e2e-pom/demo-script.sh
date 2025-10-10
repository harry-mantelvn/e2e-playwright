#!/bin/bash

# 🎬 Live Demo Script for POM Showcase
# This script provides commands for the 10-minute presentation

echo "🎯 POM Pattern Showcase - Demo Commands"
echo "======================================"

# Function to pause and wait for presenter
pause_for_presenter() {
    echo ""
    echo "⏸️  Press ENTER to continue to next demo step..."
    read -r
}

echo "📋 Available demo commands:"
echo ""
echo "1. Framework Overview Demo"
echo "2. Contact Form Test Demo" 
echo "3. Allure Report Demo"
echo "4. Framework Commands Demo"
echo ""

while true; do
    echo "🎬 Select demo (1-4) or 'q' to quit:"
    read -r choice
    
    case $choice in
        1)
            echo ""
            echo "🚀 DEMO 1: Framework Overview"
            echo "=============================="
            
            echo "📁 Show project structure:"
            tree -L 2 -I 'node_modules|test-results|test-reports' || ls -la
            pause_for_presenter
            
            echo "📊 Show available NPM scripts:"
            echo "Test execution commands:"
            grep -E "test:|allure:|report:" package.json | head -10
            pause_for_presenter
            
            echo "🗂️ Show Page Objects structure:"
            find pages -name "*.ts" -type f | head -10
            pause_for_presenter
            ;;
            
        2)
            echo ""
            echo "🧪 DEMO 2: Contact Form Test Execution"
            echo "======================================"
            
            echo "🔍 First, let's see the test structure:"
            echo "Contact form test location:"
            ls -la tests/regression/contact/
            pause_for_presenter
            
            echo "📝 Show test content preview:"
            echo "Key test steps in submit-contact-form.spec.ts:"
            grep -A 2 -B 1 "test.step" tests/regression/contact/submit-contact-form.spec.ts | head -15
            pause_for_presenter
            
            echo "🏃‍♂️ Running contact form regression test..."
            echo "Command: npm run test:regression"
            npm run test:regression
            pause_for_presenter
            ;;
            
        3)
            echo ""
            echo "📊 DEMO 3: Allure Report Showcase"
            echo "================================="
            
            echo "📈 Generating Allure report..."
            npm run allure:generate
            pause_for_presenter
            
            echo "🌐 Opening Allure report in browser..."
            echo "This will show:"
            echo "- Test execution timeline"
            echo "- Step-by-step breakdown"
            echo "- Screenshots on failures"
            echo "- Professional dashboard"
            npm run allure:open
            pause_for_presenter
            ;;
            
        4)
            echo ""
            echo "⚡ DEMO 4: Framework Commands Showcase"
            echo "===================================="
            
            echo "🚀 Quick connectivity test:"
            echo "Command: npm run test:quick"
            npm run test:quick
            pause_for_presenter
            
            echo "💨 Smoke test execution:"
            echo "Command: npm run test:smoke"
            npm run test:smoke
            pause_for_presenter
            
            echo "🛠️ Helper script demo:"
            echo "Command: ./test-helper.sh help"
            ./test-helper.sh help
            pause_for_presenter
            
            echo "📋 Show all available commands:"
            echo "All test commands:"
            grep -E '"test:|"allure:|"report:|"clean"' package.json
            pause_for_presenter
            ;;
            
        q)
            echo "👋 Demo completed! Good luck with the presentation!"
            break
            ;;
            
        *)
            echo "❌ Invalid choice. Please select 1-4 or 'q'"
            ;;
    esac
    
    echo ""
    echo "🔄 Return to main menu..."
    echo ""
done

# Final tips for presenter
echo ""
echo "🎯 PRESENTATION TIPS:"
echo "===================="
echo "✅ Emphasize business-friendly test code"
echo "✅ Point out single source of truth for selectors"
echo "✅ Highlight maintainability benefits"
echo "✅ Show professional reporting capabilities"
echo "✅ Mention CI/CD integration"
echo ""
echo "🆘 BACKUP COMMANDS if demo fails:"
echo "================================="
echo "npm run test:basic          # Simplest test"
echo "npm run allure:serve        # Alternative report viewing"
echo "./run-test.sh smoke         # Helper script alternative"
echo "cat TEST-COMMANDS.md        # Show documentation"
echo ""
echo "📚 Key files to reference:"
echo "=========================="
echo "- pages/contact-page/contact.page.ts (Page Object example)"
echo "- tests/regression/contact/submit-contact-form.spec.ts (Test example)"
echo "- helper/page-factory.ts (Factory pattern)"
echo "- FRAMEWORK-MINDMAP.md (Architecture overview)"
