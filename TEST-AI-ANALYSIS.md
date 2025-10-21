# 🧪 Testing AI Analysis - Complete Guide

## ✅ What's Fixed

1. ✅ **Complete `analyze-github.py`** script
2. ✅ **Dependencies** in `requirements-github.txt`
3. ✅ **Workflow** integration in `.github/workflows/e2e-automation.yml`
4. ✅ **Sample data** for testing
5. ✅ **Error handling** and fallback

---

## 🚀 Test on GitHub Actions

### Step 1: Go to Actions

```
https://github.com/harry-mantelvn/e2e-playwright/actions
```

### Step 2: Run Workflow

1. Click **"E2E Test Automation"** workflow
2. Click **"Run workflow"** dropdown
3. Configure:
   - **Branch**: `feat/ai-analyze-report`
   - **Environment**: `test`
   - **Test Scope**: `smoke`
   - **Workers**: `3`
4. Click **"Run workflow"** button

### Step 3: Wait for Results (3-5 minutes)

The workflow will:
- ✅ Install dependencies
- ✅ Run E2E tests
- ✅ **Analyze failures with AI**
- ✅ Upload results as artifacts

---

## 📊 Expected Results

### With Passing Tests:
```json
{
  "analysis_metadata": {
    "timestamp": "2025-10-21T...",
    "status": "success",
    "ai_provider": "github-copilot"
  },
  "summary": {
    "ai_enabled": true,
    "total_failures_analyzed": 0,
    "message": "All tests passed! No failures to analyze."
  },
  "recommendations": [
    "✅ All tests passing - great job!",
    "💡 Consider adding more test coverage"
  ]
}
```

### With Failing Tests:
```json
{
  "analysis_metadata": {
    "timestamp": "2025-10-21T...",
    "status": "success",
    "ai_provider": "github-copilot"
  },
  "summary": {
    "ai_enabled": true,
    "total_failures_analyzed": 2
  },
  "test_failures": [
    {
      "title": "should load home page successfully",
      "file": "tests/smoke/smoke-home.spec.ts",
      "error": "locator.click: Timeout 5000ms exceeded..."
    }
  ],
  "ai_insights": {
    "failures_analysis": [
      {
        "test_title": "should load home page successfully",
        "root_cause": "Incorrect selector - using '/productsdd' instead of '/products'",
        "recommended_fix": "Fix the selector to 'a[href=\"/products\"]'",
        "priority": "high"
      }
    ],
    "common_patterns": [
      "Selector typos causing timeouts"
    ],
    "recommendations": [
      "🔍 Review all selectors for typos",
      "⏱️  Add proper wait conditions",
      "🧪 Add selector validation tests"
    ]
  }
}
```

### Fallback (No GITHUB_TOKEN):
```json
{
  "analysis_metadata": {
    "status": "fallback",
    "message": "Using statistical analysis (AI unavailable)"
  },
  "summary": {
    "ai_enabled": false,
    "total_failures_analyzed": 2
  },
  "patterns_detected": [
    "⏱️  Multiple timeout failures detected"
  ],
  "recommendations": [
    "🔍 Review test selectors for stability",
    "⏱️  Increase timeout values if needed"
  ]
}
```

---

## 📥 Download Results

After workflow completes:

1. Scroll to **"Artifacts"** section
2. Download **"ai-analysis-results"**
3. Unzip and open `ai-analysis.json`

---

## 🧪 Test Locally (Optional)

### Test with Sample Data:
```bash
cd /Users/nam.nguyenduc/e2e-playwright/ai-analysis

# Test without AI (fallback)
python3 analyze-github.py sample-test-results.json output.json

# Check results
cat output.json | jq '.'
```

### Test with Your Test Results:
```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom

# Run tests and generate JSON
npm run test:smoke -- --reporter=json > ../ai-analysis/my-test-results.json

# Analyze
cd ../ai-analysis
python3 analyze-github.py my-test-results.json my-analysis.json

# View results
cat my-analysis.json | jq '.'
```

---

## 🔍 Verify Workflow Configuration

Check `.github/workflows/e2e-automation.yml` has this job:

```yaml
ai-analysis:
  name: AI Test Analysis
  needs: e2e-tests
  if: always()
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Download test results
      uses: actions/download-artifact@v4
      with:
        name: playwright-results
        path: test-results
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
        cache: 'pip'
        cache-dependency-path: ai-analysis/requirements-github.txt
    
    - name: Install dependencies
      run: |
        pip install -r ai-analysis/requirements-github.txt
    
    - name: Run AI analysis
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      run: |
        python ai-analysis/analyze-github.py \
          test-results/results.json \
          ai-analysis.json
    
    - name: Upload AI analysis
      uses: actions/upload-artifact@v4
      with:
        name: ai-analysis-results
        path: ai-analysis.json
```

---

## 🎯 What to Check

### ✅ Success Indicators:

1. **Setup Python** step completes ✅
2. **Install dependencies** finds `requirements-github.txt` ✅
3. **Run AI analysis** executes without errors ✅
4. **Upload AI analysis** creates artifact ✅
5. **Download artifact** contains valid JSON ✅

### ❌ Common Issues:

| Issue | Solution |
|-------|----------|
| `requirements-github.txt not found` | File not committed - run `git add ai-analysis/` |
| `analyze-github.py not found` | File not committed - check git status |
| `Invalid JSON in results.json` | Test results format issue - check Playwright reporter |
| `AI analysis failed` | Check script logs for Python errors |
| Empty `ai-analysis.json` | Script succeeded but no output - check test results input |

---

## 📞 Troubleshooting

### If analysis.json is empty:

1. **Check test results exist**:
   ```bash
   # In GitHub Actions, check logs for:
   "Loading test results from: test-results/results.json"
   ```

2. **Verify JSON format**:
   - Playwright JSON reporter must be enabled
   - Results file must have `suites` array

3. **Check script execution**:
   - Look for Python errors in workflow logs
   - Verify `GITHUB_TOKEN` is available

### If workflow fails:

1. **Check "Setup Python" step**
   - Should find `requirements-github.txt`
   - Should cache pip dependencies

2. **Check "Install dependencies" step**
   - Should install `requests>=2.31.0`

3. **Check "Run AI analysis" step**
   - Should show loading message
   - Should show analysis summary
   - Should save output file

---

## 🎉 Success!

When everything works, you'll see:

```
📊 AI ANALYSIS SUMMARY
============================================================
Status: success
AI Enabled: True
Failures Analyzed: X
✅ AI insights generated successfully!
============================================================
✅ Analysis complete! Results saved to: ai-analysis.json
```

And the artifact will contain:
- ✅ Detailed failure analysis
- ✅ Root cause identification
- ✅ Actionable recommendations
- ✅ Priority levels for fixes

---

## 🚀 Next Steps

1. **Run workflow** on GitHub Actions
2. **Download** ai-analysis-results artifact
3. **Review** AI insights
4. **Fix** failing tests based on recommendations
5. **Re-run** tests to verify fixes

Good luck! 🍀

**Start here**: https://github.com/harry-mantelvn/e2e-playwright/actions
