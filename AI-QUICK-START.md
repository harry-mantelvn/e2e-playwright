# ✅ AI Analysis Setup - Quick Start Checklist

## 📋 30-Minute Setup Guide

Follow these steps in order to get AI-powered test analysis running in your CI/CD pipeline.

---

## Step 1: OpenAI API Setup (5 minutes)

### 1.1 Create OpenAI Account
- [ ] Go to https://platform.openai.com/
- [ ] Sign up or log in with existing account
- [ ] Verify email if needed

### 1.2 Generate API Key
- [ ] Navigate to **Settings → API Keys**
- [ ] Click **Create new secret key**
- [ ] Name it: `E2E-Test-Analysis`
- [ ] **IMPORTANT**: Copy the key immediately (starts with `sk-proj-...`)
- [ ] Save it securely (you won't see it again!)

### 1.3 Set Up Billing (REQUIRED)
- [ ] Go to **Settings → Billing**
- [ ] Click **Add payment method**
- [ ] Add credit/debit card
- [ ] Set monthly budget limit: **$10** (recommended for testing)
- [ ] Enable email alerts at **$5** usage

**⚠️ Note:** Free tier is NOT sufficient for API access. You need a paid account.

---

## Step 2: GitHub Secrets Configuration (5 minutes)

### 2.1 Add OpenAI API Key
- [ ] Go to your GitHub repository
- [ ] Navigate to: **Settings → Secrets and variables → Actions**
- [ ] Click **New repository secret**
- [ ] Enter details:
  - Name: `OPENAI_API_KEY` (exact spelling, case-sensitive)
  - Secret: [Paste your OpenAI API key from Step 1.2]
- [ ] Click **Add secret**

### 2.2 Verify Secret Created
- [ ] Check that `OPENAI_API_KEY` appears in secrets list
- [ ] ✅ Secret shows "Updated X seconds ago"

### 2.3 (Optional) Add Notification Secrets
If you want AI insights in notifications:

**For Slack:**
- [ ] Secret Name: `SLACK_WEBHOOK_URL`
- [ ] Value: Your Slack webhook URL

**For Teams:**
- [ ] Secret Name: `TEAMS_WEBHOOK_URL`
- [ ] Value: Your Teams webhook URL

**For Email:**
- [ ] Secret Name: `EMAIL_USERNAME` (your Gmail)
- [ ] Secret Name: `EMAIL_PASSWORD` (Gmail app password)

---

## Step 3: Test the Setup (10 minutes)

### 3.1 Trigger Test Run via GitHub Actions

- [ ] Go to **Actions** tab in your repository
- [ ] Click on **E2E Test Automation** workflow
- [ ] Click **Run workflow** button (right side)
- [ ] Fill in parameters:
  ```
  Environment: test
  Test Scope: smoke
  Workers: 3
  Email Recipients: [leave blank or add your email]
  ```
- [ ] Click green **Run workflow** button

### 3.2 Monitor Workflow Execution

- [ ] Click on the running workflow (top of the list)
- [ ] Watch the jobs execute:
  - ✅ **test** job runs first (runs your Playwright tests)
  - ✅ **ai-analysis** job runs after test job completes
  
### 3.3 Verify AI Analysis Results

When workflow completes:

- [ ] Click on **Summary** tab (top left)
- [ ] Scroll down to see:
  - ✅ **📊 Test Results Summary** section
  - ✅ **🤖 AI-Powered Test Analysis** section
  - [ ] Check **AI Analysis** row shows "✅ Enabled (GPT-4)"
  - [ ] Check **Health Score** shows a number (e.g., 85/100)

### 3.4 Download and Review AI Analysis

- [ ] Scroll to **Artifacts** section at bottom of Summary
- [ ] Find artifact named `ai-analysis-{run-number}`
- [ ] Click to download the ZIP file
- [ ] Extract and open `ai-analysis.json`
- [ ] Verify it contains:
  ```json
  {
    "summary": {
      "ai_enabled": true,
      "overall_health_score": 85,
      ...
    },
    "recommendations": [...],
    ...
  }
  ```

---

## Step 4: Local Testing (Optional, 5 minutes)

### 4.1 Install Python Dependencies

```bash
cd ai-analysis
pip install -r requirements.txt
```

- [ ] Command runs without errors
- [ ] All packages installed successfully

### 4.2 Test Locally

```bash
# Set your API key
export OPENAI_API_KEY="sk-proj-your-actual-key-here"

# Run tests to generate data
cd ../automationexercise-e2e-pom
npm run test:smoke:ci

# Run AI analysis
cd ../ai-analysis
python analyze.py
```

- [ ] Script runs without errors
- [ ] See output: "🤖 Starting AI-powered test analysis..."
- [ ] See output: "✅ Analysis complete!"
- [ ] Check file created: `../automationexercise-e2e-pom/test-summary/ai-analysis.json`

### 4.3 Review Local Results

```bash
# View summary
cat ../automationexercise-e2e-pom/test-summary/ai-analysis.json | jq '.summary'
```

- [ ] JSON output displays correctly
- [ ] `ai_enabled: true` is shown
- [ ] Health score is present

---

## Step 5: Validation (5 minutes)

### ✅ Final Checklist

- [ ] **OpenAI Account**: Active with billing enabled
- [ ] **API Key**: Added to GitHub secrets as `OPENAI_API_KEY`
- [ ] **Workflow Run**: Completed successfully
- [ ] **AI Job**: Ran and completed (not skipped)
- [ ] **AI Enabled**: Shows "GPT-4 Enabled" in summary
- [ ] **Artifacts**: AI analysis JSON file available for download
- [ ] **Health Score**: Displayed in workflow summary
- [ ] **No Errors**: No red errors in AI analysis job logs

### 🎯 Success Criteria

If all items above are checked, congratulations! Your AI-powered test analysis is fully operational! 🎉

You should see:
- ✅ Test health scores in every workflow run
- ✅ AI-categorized test failures
- ✅ Smart recommendations for fixing issues
- ✅ Flaky test detection
- ✅ Performance anomaly alerts

---

## Troubleshooting Common Issues

### ❌ "AI Analysis shows 'Disabled (statistical only)'"

**Cause:** OpenAI API key not found or invalid

**Fix:**
1. Check secret name is EXACTLY: `OPENAI_API_KEY` (case-sensitive)
2. Verify secret value starts with `sk-proj-` or `sk-`
3. Re-create the secret if needed (delete old one first)
4. Re-run workflow

---

### ❌ "Rate limit exceeded" or "Quota exceeded"

**Cause:** OpenAI usage limits reached

**Fix:**
1. Check usage: https://platform.openai.com/usage
2. Verify billing is set up correctly
3. Increase usage limit in OpenAI dashboard
4. Wait for quota to reset (if free trial)

---

### ❌ "AI analysis job skipped"

**Cause:** Job condition not met

**Fix:**
1. Check workflow file has `if: always()` on ai-analysis job
2. Ensure `needs: test` is present
3. Verify test job completed (even if failed)

---

### ❌ "File not found: metrics.json"

**Cause:** Test job didn't generate metrics

**Fix:**
1. Verify test job ran successfully
2. Check artifact upload step completed
3. Ensure artifact name matches in download step
4. Run `npm run metrics:generate` manually to test

---

### ❌ "Module 'openai' not found" (Local testing)

**Cause:** Python dependencies not installed

**Fix:**
```bash
cd ai-analysis
pip install --upgrade pip
pip install -r requirements.txt
```

---

## What's Next?

### 📚 Learn More
- Read full guide: `AI-SETUP-GUIDE.md`
- Understand AI insights: `AI-ANALYSIS-PROPOSAL.md`
- Configure notifications: `SETUP-GUIDE-STEP-BY-STEP.md`

### 🚀 Advanced Features
- [ ] Set up historical trend tracking
- [ ] Configure custom notification templates with AI insights
- [ ] Create dashboard for visualization
- [ ] Enable auto-quarantine for flaky tests
- [ ] Integrate with Jira for automatic ticket creation

### 💰 Cost Management
- [ ] Review OpenAI usage after 1 week
- [ ] Adjust analysis frequency if needed
- [ ] Consider GPT-3.5 for cost savings (less accurate)
- [ ] Implement conditional AI analysis (only on failures)

---

## Quick Reference

### Important URLs
- **OpenAI Dashboard**: https://platform.openai.com/
- **API Keys**: https://platform.openai.com/api-keys
- **Usage Tracking**: https://platform.openai.com/usage
- **Billing**: https://platform.openai.com/settings/organization/billing

### Cost Estimates
- **Per workflow run**: ~$0.10 USD
- **Per month (30 runs)**: ~$3.00 USD
- **Per month (100 runs)**: ~$10.00 USD

### GitHub Locations
- **Workflow File**: `.github/workflows/e2e-automation.yml`
- **AI Script**: `ai-analysis/analyze.py`
- **Dependencies**: `ai-analysis/requirements.txt`
- **Secrets**: `Repo Settings → Secrets and variables → Actions`

### Support
- **Documentation**: Check `AI-SETUP-GUIDE.md`
- **Troubleshooting**: See section above
- **Issues**: Create GitHub issue in repository

---

**Setup Time**: ~30 minutes  
**Difficulty**: ⭐⭐ Intermediate  
**Status**: ✅ Production Ready

**Need help?** Review the detailed guide in `AI-SETUP-GUIDE.md` or check workflow logs for specific error messages.
