#!/bin/bash

# Quick test script for AI analysis
set -e

cd "$(dirname "$0")"

echo "🚀 Quick AI Analysis Test"
echo "========================"
echo ""

# Check if we're in the right directory
if [ ! -f "analyze-github.py" ]; then
    echo "❌ Error: Must run from ai-analysis directory"
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found"
    exit 1
fi

echo "✅ Python 3: $(python3 --version)"
echo ""

# Install requests if needed
echo "📦 Checking dependencies..."
python3 -c "import requests" 2>/dev/null || {
    echo "Installing requests..."
    pip3 install --user requests || pip3 install --break-system-packages requests
}
echo "✅ Dependencies OK"
echo ""

# Check for test data
if [ ! -f "../automationexercise-e2e-pom/test-summary/metrics.json" ]; then
    echo "⚠️  No test data found. Creating sample..."
    mkdir -p ../automationexercise-e2e-pom/test-summary
    cat > ../automationexercise-e2e-pom/test-summary/metrics.json << 'EOF'
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
  "run_number": "quick-test",
  "execution_time": "45s",
  "failed_test_details": [
    {
      "name": "should login successfully",
      "file": "tests/auth/login.spec.ts",
      "error": "Timeout waiting for login button",
      "duration": 30500
    }
  ]
}
EOF
fi

echo "📊 Test data ready"
echo ""

# Run analysis
echo "🤖 Running AI Analysis..."
echo "Note: Without GITHUB_TOKEN, will use statistical analysis only"
echo ""

python3 analyze-github.py

echo ""
echo "✅ Analysis complete!"
echo ""

# Check output
if [ -f "../automationexercise-e2e-pom/test-summary/ai-analysis.json" ]; then
    echo "📄 Output file created:"
    ls -lh ../automationexercise-e2e-pom/test-summary/ai-analysis.json
    echo ""
    echo "📋 Preview:"
    python3 -c "
import json
with open('../automationexercise-e2e-pom/test-summary/ai-analysis.json') as f:
    data = json.load(f)
    print(json.dumps(data, indent=2)[:1000])
    print('...')
"
else
    echo "❌ No output file generated"
    exit 1
fi

echo ""
echo "🎉 Test successful!"
echo ""
echo "Next steps:"
echo "1. Review: automationexercise-e2e-pom/test-summary/ai-analysis.json"
echo "2. For full AI analysis, set GITHUB_TOKEN and run in GitHub Actions"
echo "3. Read: ../GITHUB-COPILOT-SETUP.md for deployment guide"
