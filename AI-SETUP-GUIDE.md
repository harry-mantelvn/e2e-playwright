# 🚀 AI-Powered Test Analysis - Complete Setup Guide

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Configuration Steps](#configuration-steps)
4. [Testing the Setup](#testing-the-setup)
5. [Understanding AI Insights](#understanding-ai-insights)
6. [Troubleshooting](#troubleshooting)
7. [Cost Optimization](#cost-optimization)

---

## Prerequisites

### Required
- ✅ GitHub repository with Actions enabled
- ✅ OpenAI API account (for GPT-4 access)
- ✅ Python 3.11+ (for local testing)

### Optional (for Enhanced Notifications)
- Slack workspace (for Slack notifications)
- Microsoft Teams webhook (for Teams notifications)
- Gmail/SMTP account (for email notifications)

---

## Quick Start

### Step 1: Get OpenAI API Key

1. **Create OpenAI Account**
   - Go to https://platform.openai.com/
   - Sign up or log in
   - Navigate to **API Keys** section

2. **Generate API Key**
   ```
   Settings → API Keys → Create new secret key
   ```
   - Name it: `E2E-Test-Analysis`
   - Copy the key (you won't see it again!)
   - Example format: `sk-proj-xxxxx...`

3. **Check Billing**
   - Go to **Settings → Billing**
   - Add payment method
   - Set usage limits (recommended: $10/month for testing)

### Step 2: Add OpenAI API Key to GitHub Secrets

1. **Navigate to Repository Settings**
   ```
   Your Repo → Settings → Secrets and variables → Actions
   ```

2. **Create New Secret**
   - Click "New repository secret"
   - Name: `OPENAI_API_KEY`
   - Value: Your OpenAI API key (paste the `sk-proj-...` key)
   - Click "Add secret"

3. **Verify Secret Created**
   - You should see `OPENAI_API_KEY` in the list
   - You cannot view the value (GitHub hides it for security)

### Step 3: Install Python Dependencies (for local testing)

```bash
cd ai-analysis
pip install -r requirements.txt
```

**Dependencies:**
- `openai>=1.3.0` - OpenAI API client
- `scikit-learn>=1.3.0` - ML algorithms for pattern detection
- `scipy>=1.11.0` - Statistical analysis
- `numpy>=1.24.0` - Numerical computations

### Step 4: Run Your First AI Analysis

**Option A: Via GitHub Actions (Recommended)**

1. Go to your repository
2. Click **Actions** tab
3. Select **E2E Test Automation** workflow
4. Click **Run workflow** button
5. Fill in parameters:
   - Environment: `test`
   - Test Scope: `smoke`
   - Workers: `3`
6. Click **Run workflow**

**Wait for completion**, then check:
- ✅ Test job completes
- ✅ AI Analysis job runs automatically
- ✅ AI insights appear in GitHub Step Summary
- ✅ Artifacts include `ai-analysis-{run-number}.json`

**Option B: Local Testing**

```bash
# 1. Run tests first to generate metrics
cd automationexercise-e2e-pom
npm run test:smoke:ci

# 2. Set OpenAI API key
export OPENAI_API_KEY="sk-proj-your-key-here"

# 3. Run AI analysis
cd ../ai-analysis
python analyze.py

# 4. Check output
cat ../automationexercise-e2e-pom/test-summary/ai-analysis.json
```

---

## Configuration Steps

### 1. Configure AI Analysis Settings

Create `ai-analysis/config.json` (optional, for customization):

```json
{
  "ai_model": "gpt-4-turbo-preview",
  "temperature": 0.3,
  "max_tokens": 2000,
  "analysis_options": {
    "enable_failure_categorization": true,
    "enable_root_cause_analysis": true,
    "enable_flaky_detection": true,
    "enable_performance_analysis": true,
    "max_failures_to_analyze": 20
  },
  "thresholds": {
    "flakiness_score_threshold": 0.6,
    "performance_deviation_threshold": 50,
    "minimum_historical_runs": 5
  }
}
```

### 2. Set Up Additional GitHub Secrets (Optional)

For enhanced notifications with AI insights:

```bash
# Slack
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Teams
TEAMS_WEBHOOK_URL=https://outlook.office.com/webhook/YOUR/WEBHOOK/URL

# Email
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-specific-password
```

**How to add:**
```
Repo → Settings → Secrets and variables → Actions → New repository secret
```

### 3. Configure Notification Templates with AI Insights

The workflow already includes AI insights in notifications. To customize:

**Edit `.github/workflows/e2e-automation.yml`:**

```yaml
- name: Send Enhanced Notification with AI
  run: |
    # Load AI insights
    AI_HEALTH_SCORE=$(jq -r '.summary.overall_health_score' test-summary/ai-analysis.json)
    AI_RECOMMENDATIONS=$(jq -r '.recommendations[0].title' test-summary/ai-analysis.json)
    
    # Include in notification message
    MESSAGE="Test Health: ${AI_HEALTH_SCORE}/100\nAI Recommendation: ${AI_RECOMMENDATIONS}"
    
    # Send to Teams/Slack/Email
    npm run teams:notify "$MESSAGE"
```

---

## Testing the Setup

### ✅ Verification Checklist

Run this checklist after setup:

#### 1. **Test OpenAI API Key**

```bash
cd ai-analysis

# Create test script
cat > test-openai.py << 'EOF'
import os
from openai import OpenAI

api_key = os.getenv('OPENAI_API_KEY')
if not api_key:
    print("❌ OPENAI_API_KEY not set")
    exit(1)

try:
    client = OpenAI(api_key=api_key)
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": "Say 'API key works!'"}],
        max_tokens=10
    )
    print("✅ OpenAI API key is valid!")
    print(f"Response: {response.choices[0].message.content}")
except Exception as e:
    print(f"❌ Error: {e}")
EOF

# Run test
export OPENAI_API_KEY="your-key-here"
python test-openai.py
```

**Expected Output:**
```
✅ OpenAI API key is valid!
Response: API key works!
```

#### 2. **Test AI Analysis Locally**

```bash
# Generate sample test data
cd automationexercise-e2e-pom
npm run test:smoke:ci

# Run AI analysis
cd ../ai-analysis
export OPENAI_API_KEY="your-key-here"
python analyze.py

# Verify output
if [ -f "../automationexercise-e2e-pom/test-summary/ai-analysis.json" ]; then
  echo "✅ AI analysis successful!"
  cat ../automationexercise-e2e-pom/test-summary/ai-analysis.json | jq '.summary'
else
  echo "❌ AI analysis failed"
fi
```

#### 3. **Test GitHub Actions Integration**

1. Push a commit to trigger workflow
2. Check Actions tab
3. Verify:
   - ✅ Test job runs
   - ✅ AI Analysis job runs after test job
   - ✅ AI insights appear in step summary
   - ✅ Artifact `ai-analysis-{run-number}.json` uploaded
   - ✅ PR comment posted (if PR event)

#### 4. **Verify AI Insights Quality**

Check `ai-analysis.json` for:

```bash
# Health score present
jq '.summary.overall_health_score' ai-analysis.json
# Should output: 85 (or similar)

# AI recommendations present
jq '.recommendations | length' ai-analysis.json
# Should output: > 0

# Failure categorization (if failures exist)
jq '.failure_categorization | length' ai-analysis.json

# Flaky test detection
jq '.flaky_tests | length' ai-analysis.json
```

---

## Understanding AI Insights

### AI Analysis Output Structure

```json
{
  "analysis_metadata": {
    "timestamp": "2024-01-20T10:30:00Z",
    "model": "gpt-4",
    "version": "1.0.0"
  },
  "summary": {
    "overall_health_score": 85,        // 0-100 score
    "trend": "STABLE",                 // EXCELLENT | STABLE | DEGRADING | CRITICAL
    "total_failures_analyzed": 5,
    "flaky_tests_detected": 2,
    "performance_anomalies": 1,
    "ai_enabled": true
  },
  "failure_categorization": [
    {
      "test_name": "test-login",
      "category": "INFRASTRUCTURE",     // Categories: FLAKY, INFRASTRUCTURE, CODE_BUG, TEST_BUG, ENVIRONMENT
      "confidence": 85,                 // 0-100
      "reasoning": "Timeout errors suggest network issues",
      "suggested_action": "Check network stability and increase timeout"
    }
  ],
  "root_cause_analysis": [
    {
      "error_type": "SELECTOR",
      "affected_tests": ["test-cart", "test-checkout"],
      "count": 2,
      "analysis": "GPT-4 analysis of root cause...",
      "priority": "HIGH"
    }
  ],
  "flaky_tests": [
    {
      "test_name": "test-search",
      "flakiness_score": 0.68,          // 0-1 (higher = more flaky)
      "pass_rate": 65.0,                // Percentage
      "recommendation": "QUARANTINE",   // MONITOR | QUARANTINE
      "stability_trend": "DEGRADING"    // IMPROVING | STABLE | DEGRADING
    }
  ],
  "performance_anomalies": [
    {
      "test_name": "test-product-page",
      "duration_ms": 15200,
      "baseline_ms": 4500,
      "deviation_percent": 237.8,
      "severity": "HIGH"
    }
  ],
  "recommendations": [
    {
      "type": "ACTION",                 // ACTION | MONITORING | INVESTIGATION
      "priority": 1,
      "title": "Fix selector issues",
      "description": "2 tests failing due to outdated selectors",
      "impact": "HIGH",
      "actionable_steps": [
        "Update selectors in cart.page.ts",
        "Verify changes on staging"
      ]
    }
  ]
}
```

### Interpreting Health Scores

| Score Range | Status | Action Required |
|------------|--------|-----------------|
| 90-100 | 🟢 Excellent | Continue monitoring |
| 75-89 | 🟡 Good | Minor improvements needed |
| 60-74 | 🟠 Fair | Investigation required |
| 0-59 | 🔴 Critical | Immediate action needed |

### Failure Categories Explained

| Category | Meaning | Typical Cause |
|----------|---------|---------------|
| **FLAKY** | Intermittent failures | Timing issues, race conditions |
| **INFRASTRUCTURE** | Environment/network issues | Timeouts, connection errors |
| **CODE_BUG** | Actual application bug | Regression in code |
| **TEST_BUG** | Test code issue | Wrong assertion, outdated selector |
| **ENVIRONMENT** | Config/setup issue | Missing env vars, wrong config |

---

## Troubleshooting

### Common Issues

#### ❌ "OpenAI API key not found"

**Problem:** AI analysis runs but shows "AI disabled - statistical only"

**Solution:**
```bash
# 1. Verify secret exists in GitHub
Repo → Settings → Secrets → Check for OPENAI_API_KEY

# 2. Verify secret name is exact (case-sensitive)
# Must be: OPENAI_API_KEY
# Not: OPENAI_KEY or openai_api_key

# 3. Re-create secret if needed
# Delete and create new one
```

#### ❌ "Rate limit exceeded"

**Problem:** OpenAI API returns 429 error

**Solution:**
```bash
# 1. Check usage limits
# Go to: https://platform.openai.com/usage

# 2. Reduce analysis frequency
# Edit ai-analysis/analyze.py
# Change: max_failures_to_analyze from 20 to 5

# 3. Implement request throttling
# Add delay between API calls
```

#### ❌ "AI analysis file not found"

**Problem:** PR comment or summary step fails

**Solution:**
```bash
# 1. Check if test job generated metrics
# Verify test-summary/metrics.json exists

# 2. Check artifact upload/download
# Ensure artifact names match exactly

# 3. Add fallback handling
# AI analysis already has error handling,
# but verify workflow continues on error
```

#### ❌ "Module 'openai' not found"

**Problem:** Local testing fails with import error

**Solution:**
```bash
# 1. Install dependencies
cd ai-analysis
pip install -r requirements.txt

# 2. Verify Python version
python --version  # Should be 3.11+

# 3. Use virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### ❌ "Invalid API key format"

**Problem:** OpenAI rejects API key

**Solution:**
```bash
# 1. Verify key format
# Should start with: sk-proj-...
# Old format: sk-...

# 2. Generate new key
# Old keys may be deprecated
# Create new one at: https://platform.openai.com/api-keys

# 3. Check for spaces
# Ensure no leading/trailing spaces in secret
```

### Debug Mode

Enable detailed logging:

```bash
# Edit ai-analysis/analyze.py
# Add at top of main():
import logging
logging.basicConfig(level=logging.DEBUG)

# Or run with verbose flag
python analyze.py --verbose
```

---

## Cost Optimization

### Estimated Costs

**OpenAI GPT-4 Turbo Pricing** (as of 2024):
- Input: ~$0.01 per 1K tokens
- Output: ~$0.03 per 1K tokens

**Typical Usage:**
- Per test run: ~10K tokens total
- Cost per run: ~$0.10
- Monthly (30 runs): ~$3.00

### Cost Reduction Strategies

#### 1. **Limit Analysis Scope**

```python
# In analyze.py, reduce max failures analyzed
for failure in failed_tests[:5]:  # Instead of [:20]
```

#### 2. **Use GPT-3.5 Turbo (Cheaper)**

```python
# Change model in analyze.py
model="gpt-3.5-turbo"  # Instead of "gpt-4"
# Cost: ~$0.01 per run (10x cheaper)
# Trade-off: Slightly less accurate
```

#### 3. **Conditional AI Analysis**

Only run AI on failures:

```yaml
# In workflow
- name: Run AI Analysis
  if: needs.test.outputs.failed_tests > 0  # Only if failures
```

#### 4. **Batch Analysis**

Analyze failures in batches instead of per-test:

```python
# Send all failures in one prompt
prompt = f"Analyze these {len(failures)} test failures..."
```

#### 5. **Use Statistical Analysis Only**

Disable AI for routine runs:

```bash
# Don't set OPENAI_API_KEY
# Analysis will use statistical methods only (free)
```

#### 6. **Set Budget Limits**

In OpenAI dashboard:
```
Settings → Billing → Usage limits → Set $5/month limit
```

---

## Advanced Configuration

### Custom ML Models

Replace OpenAI with local models (Llama 2, Mistral):

```python
# ai-analysis/local-llm.py
from transformers import AutoModelForCausalLM

model = AutoModelForCausalLM.from_pretrained("mistralai/Mistral-7B-v0.1")
# Use local inference (no API costs)
```

### Historical Trend Analysis

Enable multi-run comparisons:

```bash
# Workflow stores historical data automatically
# Access in ai-analysis/data/historical/
```

### Custom Notification Templates

Integrate AI insights into custom notifications:

```bash
# scripts/send-ai-enhanced-notification.sh
AI_INSIGHTS=$(cat test-summary/ai-analysis.json | jq -r '.recommendations[0].title')
curl -X POST $SLACK_WEBHOOK -d "{\"text\": \"AI Says: $AI_INSIGHTS\"}"
```

---

## Next Steps

### ✅ Setup Complete Checklist

- [ ] OpenAI API key added to GitHub secrets
- [ ] Test run completed successfully
- [ ] AI analysis job runs in workflow
- [ ] AI insights visible in GitHub summary
- [ ] Artifacts uploaded correctly
- [ ] (Optional) Notifications configured
- [ ] Cost limits set in OpenAI dashboard

### 🚀 Enhancements

**Phase 2 Ideas:**
1. Dashboard for visualizing AI insights over time
2. Auto-create Jira tickets for failures
3. Predictive failure analysis
4. Test self-healing (auto-fix selectors)
5. Cross-repo pattern detection

**Need Help?**
- Check [Troubleshooting](#troubleshooting) section
- Review GitHub Actions logs
- Contact: [your-team-email]

---

**Last Updated**: January 2024  
**Version**: 1.0.0  
**Maintained by**: QA Automation Team
