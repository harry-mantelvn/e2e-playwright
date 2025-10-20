#!/bin/bash

# Test AI Analysis locally WITHOUT GitHub Token
# Will use statistical analysis instead of AI

set -e

echo "🧪 Local AI Analysis Test (Statistical Mode)"
echo "=============================================="
echo ""

cd "$(dirname "$0")"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found"
    exit 1
fi

echo "✅ Python: $(python3 --version)"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
if python3 -m pip install --user --quiet requests 2>/dev/null; then
    echo "✅ Dependencies installed (--user)"
elif pip3 install --break-system-packages --quiet requests 2>/dev/null; then
    echo "✅ Dependencies installed (--break-system-packages)"
else
    echo "⚠️  Using system requests library"
fi

# Ensure test data exists
echo ""
echo "📊 Preparing test data..."
mkdir -p ../automationexercise-e2e-pom/test-summary

if [ ! -f "../automationexercise-e2e-pom/test-summary/metrics.json" ]; then
    cat > ../automationexercise-e2e-pom/test-summary/metrics.json << 'EOF'
{
  "total_tests": 8,
  "total_test_cases": 25,
  "passed_tests": 23,
  "failed_tests": 2,
  "skipped_tests": 0,
  "pass_rate": 92,
  "test_coverage_percentage": 85,
  "environment": "test",
  "test_scope": "all",
  "run_number": "local-test",
  "execution_time": "45s",
  "failed_test_details": [
    {
      "name": "should login with valid credentials",
      "file": "tests/regression/auth/register-login-logout.spec.ts",
      "error": "Timeout 30000ms exceeded waiting for selector 'button[data-qa=\"login-button\"]'",
      "duration": 30500
    },
    {
      "name": "should add product to cart",
      "file": "tests/regression/products/add-to-cart-and-checkout.spec.ts",
      "error": "Element not found: .product-price",
      "duration": 15200
    }
  ]
}
EOF
    echo "✅ Sample test data created"
else
    echo "✅ Test data found"
fi

# Clear previous output
rm -f ../automationexercise-e2e-pom/test-summary/ai-analysis.json

echo ""
echo "🤖 Running AI Analysis..."
echo "Note: No GITHUB_TOKEN - using statistical analysis mode"
echo ""

# Run without token (will use fallback)
unset GITHUB_TOKEN
python3 analyze-github.py

echo ""
if [ -f "../automationexercise-e2e-pom/test-summary/ai-analysis.json" ]; then
    echo "✅ Analysis completed!"
    echo ""
    echo "📄 Output: automationexercise-e2e-pom/test-summary/ai-analysis.json"
    echo ""
    
    # Pretty print results
    python3 << 'PYTHON'
import json

with open('../automationexercise-e2e-pom/test-summary/ai-analysis.json', 'r') as f:
    data = json.load(f)

print("=" * 60)
print("📊 AI ANALYSIS RESULTS (Statistical Mode)")
print("=" * 60)

# Basic info
print(f"\n🤖 Analyzer: {data.get('analyzer', 'Unknown')}")
print(f"📅 Timestamp: {data.get('timestamp', 'Unknown')}")

# Test metrics
metrics = data.get('test_metrics', {})
print(f"\n📈 TEST METRICS:")
print(f"  Total Tests: {metrics.get('total_test_cases', 0)}")
print(f"  Passed: {metrics.get('passed_tests', 0)} ✅")
print(f"  Failed: {metrics.get('failed_tests', 0)} ❌")
print(f"  Pass Rate: {metrics.get('pass_rate', 0)}%")

# AI Analysis
ai = data.get('ai_analysis', {})
print(f"\n🎯 QUALITY ASSESSMENT:")
print(f"  Status: {ai.get('quality_status', 'Unknown')}")

risk = ai.get('risk_assessment', {})
print(f"  Risk Level: {risk.get('level', 'Unknown')}")
print(f"  Deployment Ready: {'✅ Yes' if risk.get('deployment_ready') else '❌ No'}")

# Recommendations
recs = ai.get('recommendations', [])
if recs:
    print(f"\n💡 RECOMMENDATIONS:")
    for i, rec in enumerate(recs[:3], 1):
        print(f"  {i}. {rec}")
else:
    print(f"\n💡 No specific recommendations")

# Statistical analysis
stats = data.get('statistical_analysis', {})
if stats:
    print(f"\n📊 STATISTICAL ANALYSIS:")
    print(f"  Failure Rate: {stats.get('failure_rate', 0)}%")
    print(f"  Reliability Score: {stats.get('reliability_score', 0)}")
    print(f"  Failure Impact: {stats.get('failure_impact', 'Unknown')}")

# Action items
actions = data.get('action_items', [])
if actions:
    print(f"\n✅ ACTION ITEMS ({len(actions)}):")
    for action in actions[:3]:
        print(f"  • [{action.get('priority', 'N/A')}] {action.get('action', 'N/A')}")

print("\n" + "=" * 60)
print("✅ Local test successful!")
print("=" * 60)
PYTHON

    echo ""
    echo "📋 Next Steps:"
    echo "1. ✅ Statistical analysis works locally!"
    echo "2. 🔑 For full AI analysis, you need GITHUB_TOKEN"
    echo "3. 🚀 Or just run in GitHub Actions (token automatic there)"
    echo ""
    echo "📚 Read: ../GITHUB-COPILOT-SETUP.md for GitHub deployment"
    
else
    echo "❌ No output file generated"
    exit 1
fi
