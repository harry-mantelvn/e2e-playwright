#!/bin/bash

# Demo script để test GitHub Copilot AI Analysis locally
# Run: ./demo-github-copilot.sh

set -e

echo "🤖 GitHub Copilot AI Analysis Demo"
echo "=================================="
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN not set"
    echo ""
    echo "To test locally, you need a GitHub Personal Access Token:"
    echo "1. Go to: https://github.com/settings/tokens"
    echo "2. Generate new token (classic)"
    echo "3. Select scopes: repo, workflow"
    echo "4. Export token:"
    echo "   export GITHUB_TOKEN='your_token_here'"
    echo ""
    echo "OR just run in GitHub Actions where GITHUB_TOKEN is automatic!"
    exit 1
fi

echo "✅ GITHUB_TOKEN found"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 not found"
    echo "Install Python 3: https://www.python.org/downloads/"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
cd ai-analysis
pip3 install -q -r requirements-github.txt
echo "✅ Dependencies installed"
echo ""

# Check for sample metrics file
cd ..
if [ ! -f "automationexercise-e2e-pom/test-summary/metrics.json" ]; then
    echo "⚠️  No metrics.json found. Creating sample data..."
    mkdir -p automationexercise-e2e-pom/test-summary
    
    cat > automationexercise-e2e-pom/test-summary/metrics.json << 'EOF'
{
  "total_tests": 8,
  "total_test_cases": 25,
  "passed_tests": 24,
  "failed_tests": 1,
  "skipped_tests": 0,
  "pass_rate": 96,
  "test_coverage_percentage": 85,
  "environment": "test",
  "test_scope": "all",
  "run_number": "demo-local",
  "execution_time": "45s",
  "failed_test_details": [
    {
      "name": "should login with valid credentials",
      "file": "tests/regression/auth/register-login-logout.spec.ts",
      "error": "Timeout 30000ms exceeded waiting for selector 'button[data-qa=\"login-button\"]'",
      "duration": 30500
    }
  ]
}
EOF
    echo "✅ Sample metrics.json created"
fi

echo ""
echo "🔍 Current test metrics:"
cat automationexercise-e2e-pom/test-summary/metrics.json | head -15
echo ""

# Run AI analysis
echo "🤖 Running GitHub Copilot AI Analysis..."
echo "Model: gpt-4o"
echo ""

cd ai-analysis
export GITHUB_MODEL="gpt-4o"
python3 analyze-github.py

echo ""
echo "✅ AI Analysis Complete!"
echo ""

# Show results
cd ..
if [ -f "automationexercise-e2e-pom/test-summary/ai-analysis.json" ]; then
    echo "📊 AI Analysis Results:"
    echo "======================="
    
    # Pretty print key sections
    python3 << 'PYTHON'
import json

with open('automationexercise-e2e-pom/test-summary/ai-analysis.json', 'r') as f:
    data = json.load(f)

print("\n🎯 QUALITY ASSESSMENT")
print("=" * 50)
ai = data.get('ai_analysis', {})
print(f"Status: {ai.get('quality_status', 'Unknown')}")
risk = ai.get('risk_assessment', {})
print(f"Risk Level: {risk.get('level', 'Unknown')}")
print(f"Deployment Ready: {risk.get('deployment_ready', False)}")

print("\n📊 TEST METRICS")
print("=" * 50)
metrics = data.get('test_metrics', {})
print(f"Total Tests: {metrics.get('total_test_cases', 0)}")
print(f"Passed: {metrics.get('passed_tests', 0)}")
print(f"Failed: {metrics.get('failed_tests', 0)}")
print(f"Pass Rate: {metrics.get('pass_rate', 0)}%")

print("\n💡 RECOMMENDATIONS")
print("=" * 50)
recs = ai.get('recommendations', [])
for i, rec in enumerate(recs[:3], 1):
    print(f"{i}. {rec}")

print("\n🔍 FAILURE ANALYSIS")
print("=" * 50)
failures = ai.get('failure_analysis', [])
if failures:
    for f in failures[:2]:
        print(f"\nPattern: {f.get('pattern', 'Unknown')}")
        print(f"Root Cause: {f.get('root_cause', 'Unknown')}")
        print(f"Impact: {f.get('impact', 'Unknown')}")
else:
    print("No failures to analyze")

print("\n📝 AI SUMMARY")
print("=" * 50)
summary = ai.get('ai_summary', ai.get('overall_insights', ''))
print(summary[:500] if summary else "No summary available")

print("\n" + "=" * 50)
print("✅ Full results saved to:")
print("   automationexercise-e2e-pom/test-summary/ai-analysis.json")
print("=" * 50)
PYTHON

else
    echo "❌ No AI analysis output found"
    exit 1
fi

echo ""
echo "🎉 Demo Complete!"
echo ""
echo "Next steps:"
echo "1. View full JSON: cat automationexercise-e2e-pom/test-summary/ai-analysis.json"
echo "2. Run in GitHub Actions for automatic analysis"
echo "3. Check GITHUB-COPILOT-SETUP.md for CI/CD integration"
echo ""
