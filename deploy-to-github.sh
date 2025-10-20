#!/bin/bash

# Quick script to commit and push for GitHub Actions testing

echo "🚀 Deploying GitHub Copilot AI Analysis to GitHub"
echo "=================================================="
echo ""

cd "$(dirname "$0")"

# Check git status
echo "📋 Checking git status..."
if ! git status &> /dev/null; then
    echo "❌ Not a git repository"
    exit 1
fi

echo "✅ Git repository found"
echo ""

# Show what will be committed
echo "📦 Files to commit:"
git status --short

echo ""
read -p "Continue with commit and push? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 0
fi

# Add files
echo ""
echo "📝 Adding files..."
git add .

# Commit
echo "💾 Committing..."
git commit -m "feat: Add GitHub Copilot AI analysis integration

- Add GitHub Models analyzer (analyze-github.py)
- Update workflow to use GitHub Copilot
- Add comprehensive documentation
- Zero-cost, token-based authentication
- Ready for production testing"

# Push
echo "🚀 Pushing to GitHub..."
git push

echo ""
echo "✅ Code pushed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Go to: https://github.com/YOUR_ORG/e2e-playwright/actions"
echo "2. Click 'E2E Test Automation'"
echo "3. Click 'Run workflow'"
echo "4. Select:"
echo "   - Environment: test"
echo "   - Test Scope: smoke"
echo "   - Workers: 3"
echo "5. Click 'Run workflow' button"
echo "6. Wait 3-5 minutes"
echo "7. View AI insights in workflow summary! 🎉"
echo ""
echo "🔗 Or click this link after push completes:"
echo "   https://github.com/YOUR_ORG/e2e-playwright/actions/workflows/e2e-automation.yml"
