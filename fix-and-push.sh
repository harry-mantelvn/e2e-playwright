#!/bin/bash

# Fix Secret Detection & Add AI Analysis - Complete Solution
set -e

echo "🔧 Fixing all issues..."

cd /Users/nam.nguyenduc/e2e-playwright

# Step 1: Stage all fixed files
echo "📝 Staging fixed files..."
git add PUSH-INSTRUCTIONS.md
git add SETUP-GUIDE-STEP-BY-STEP.md
git add SAFE-PUSH-GUIDE.md
git add .github/workflows/e2e-automation.yml

# Step 2: Check if we have changes
if git diff --cached --quiet; then
    echo "✅ No changes to commit (already fixed)"
else
    echo "📦 Committing fixes..."
    git commit --amend --no-edit
fi

# Step 3: Force push to overwrite history
echo "🚀 Force pushing to GitHub..."
git push origin feat/ai-analyze-report --force-with-lease

echo ""
echo "✅ Done! Your changes have been pushed."
echo ""
echo "🎯 What was fixed:"
echo "  1. ✅ Sanitized all Slack webhook URL examples"
echo "  2. ✅ Added AI analysis job to workflow"
echo "  3. ✅ Force pushed to overwrite git history"
echo ""
echo "🔗 Next steps:"
echo "  1. Go to: https://github.com/harry-mantelvn/e2e-playwright/actions"
echo "  2. Click 'E2E Test Automation' workflow"
echo "  3. Click 'Run workflow'"
echo "  4. Select options and run"
echo "  5. View AI analysis in the workflow output!"
echo ""
echo "🎉 Setup complete!"
