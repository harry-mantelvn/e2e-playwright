#!/bin/bash
set -e

cd /Users/nam.nguyenduc/e2e-playwright

echo "🚀 Pushing Senior QA Level AI Analysis v3.0"
echo "=============================================="
echo ""

echo "📦 Adding files..."
git add ai-analysis/analyze-github.py
git add SENIOR-QA-ANALYSIS.md
git add FIX-FAILURE-DETECTION.md

echo "✅ Committing..."
git commit -m "feat: Upgrade to Senior QA level analysis v3.0

🎯 Major improvements:
- Senior QA engineer-style prompt for deeper analysis
- Failure categorization (code/environment/flaky/config)
- Root cause with technical explanations
- Reproduction steps identification
- Code examples with fixes
- Pattern detection and analysis
- Environment issue detection
- Flaky test indicators
- Suite health monitoring
- Most problematic files tracking
- Immediate actions prioritization
- Effort estimation per failure

📊 Output includes:
- Detailed root cause per failure
- Failure hotspots
- Common patterns analysis  
- Environment issues
- Flaky test indicators
- Immediate actions required
- Long-term recommendations

🔧 Also fixed:
- Improved error message extraction
- Added debug logging
- Better failure detection
- Handle multiple error formats"

echo ""
echo "🚀 Pushing to GitHub..."
git push origin feat/ai-analyze-report

echo ""
echo "✅ Done! Changes pushed successfully."
echo ""
echo "🎉 Your AI analysis is now at Senior QA Engineer level!"
echo ""
echo "📊 Next: Run workflow on GitHub Actions to see the enhanced analysis"
echo "https://github.com/harry-mantelvn/e2e-playwright/actions"
