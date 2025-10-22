#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     TEST METRICS → PLAYWRIGHT JSON CONVERTER               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

cd /Users/nam.nguyenduc/e2e-playwright

# Check if metrics.json exists
if [ ! -f "automationexercise-e2e-pom/test-summary/metrics.json" ]; then
    echo "❌ metrics.json not found"
    echo "   Run tests first: ./run-tests.sh test smoke 3"
    exit 1
fi

echo "✅ Found metrics.json"
echo ""
echo "📊 Original metrics.json:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat automationexercise-e2e-pom/test-summary/metrics.json | python3 -m json.tool | head -20
echo ""

echo "🔄 Converting to Playwright format..."
python3 ai-analysis/convert-metrics.py \
  automationexercise-e2e-pom/test-summary/metrics.json \
  ai-analysis/test-converted.json

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Conversion successful!"
    echo ""
    echo "📋 Converted Playwright JSON:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ai-analysis/test-converted.json | python3 -m json.tool
    echo ""
    
    echo "🤖 Testing AI analysis with converted file..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd ai-analysis
    python3 analyze-github.py test-converted.json --fallback 2>test-convert.log 1>test-convert-output.json
    
    echo ""
    echo "📊 Analysis Results:"
    python3 -c "
import json
with open('test-convert-output.json') as f:
    data = json.load(f)
    summary = data.get('summary', data.get('executive_summary', {}))
    print(f\"Total Tests: {summary.get('total_tests', 0)}\")
    print(f\"Passed: {summary.get('passed_tests', 0)}\")
    print(f\"Failed: {summary.get('total_failures', 0)}\")
    print(f\"Pass Rate: {summary.get('pass_rate', 0):.1f}%\")
"
    echo ""
    echo "✅ Test complete! Files created:"
    echo "   - ai-analysis/test-converted.json (Playwright format)"
    echo "   - ai-analysis/test-convert-output.json (AI analysis)"
    echo "   - ai-analysis/test-convert.log (debug log)"
else
    echo ""
    echo "❌ Conversion failed"
    exit 1
fi
