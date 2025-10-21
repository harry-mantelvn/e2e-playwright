#!/bin/bash

echo "🚀 Committing and Pushing AI Analysis Integration"
echo "=================================================="
echo ""

cd /Users/nam.nguyenduc/e2e-playwright

# 1. Add all AI analysis files
echo "📦 Adding AI analysis files..."
git add ai-analysis/

# 2. Add workflow file
echo "⚙️  Adding workflow file..."
git add .github/workflows/e2e-automation.yml

# 3. Add documentation
echo "📚 Adding documentation..."
git add PUSH-INSTRUCTIONS.md
git add SAFE-PUSH-GUIDE.md
git add SETUP-GUIDE-STEP-BY-STEP.md

# 4. Check what will be committed
echo ""
echo "📋 Files to be committed:"
git status --short

echo ""
echo "✅ Ready to commit!"
echo ""

# 5. Commit
read -p "Proceed with commit? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git commit -m "feat: Add AI analysis integration with GitHub Copilot

- Add AI analysis scripts (analyze-github.py)
- Add requirements-github.txt for Python dependencies
- Update workflow to include AI analysis job
- Sanitize all webhook URL examples in documentation
- Add comprehensive setup and testing guides"

    echo ""
    echo "🚀 Pushing to GitHub..."
    git push origin feat/ai-analyze-report
    
    echo ""
    echo "✅ Done! Check GitHub Actions:"
    echo "   https://github.com/harry-mantelvn/e2e-playwright/actions"
else
    echo "❌ Commit cancelled"
fi
