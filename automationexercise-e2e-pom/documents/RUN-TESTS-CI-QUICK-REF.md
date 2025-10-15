# 🚀 Run Tests & Notifications trên CI - Quick Reference

## ✅ TL;DR - Jobs bạn nên run:

### **1. Run Tests + All Notifications (Khuyến nghị nhất):**

```yaml
# Workflow: E2E Test Automation
# Trigger: Manual (workflow_dispatch)

Steps:
1. Run tests (smoke/regression/all)
2. Generate reports (Allure + Metrics + Email)
3. Send Teams notification ✅
4. Send Slack notification ✅
5. Send Email report ✅
6. Upload artifacts
```

**Cách thực hiện:**
```bash
# Từ GitHub UI:
Actions → E2E Test Automation → Run workflow
- Environment: test
- Test Scope: smoke  # hoặc regression/all
- Workers: 3
- Email Recipients: your-email@example.com

# Hoặc dùng GitHub CLI:
gh workflow run e2e-automation.yml \
  -f environment=test \
  -f test_scope=smoke \
  -f workers=3 \
  -f email_recipients="your-email@example.com"
```

### **2. Quick Smoke Tests (Push/PR tự động):**

```yaml
# Tự động trigger khi:
- Push to main/develop
- Pull Request to main

# Chạy:
- Smoke tests only
- Generate reports
- NO email (optional notifications)
```

### **3. Scheduled Nightly Tests:**

```yaml
# Tự động chạy daily lúc 6 AM UTC (1 PM Vietnam)

# Chạy:
- Smoke tests
- Generate reports
- Send notifications if configured
```

## 📋 NPM Scripts cho từng Scenario:

### **Scenario 1: Local Development**

```bash
cd automationexercise-e2e-pom

# Run tests
npm run test:smoke          # With report generation
npm run test:smoke:ci       # Without report generation (faster)

# Generate reports
npm run reports:all         # All reports

# Send notifications
npm run teams:test          # Test Teams integration
npm run slack:test          # Test Slack integration
npm run notify:all          # Send to all platforms
```

### **Scenario 2: CI/CD Pipeline**

```yaml
# In GitHub Actions workflow:

- name: Run Tests
  run: |
    cd automationexercise-e2e-pom
    npm run test:smoke:ci              # Fast, no reports yet

- name: Generate Reports
  if: always()
  run: |
    cd automationexercise-e2e-pom
    npm run reports:ci                  # Generate all reports

- name: Send Notifications  
  if: always()
  run: |
    cd automationexercise-e2e-pom
    export TEAMS_WEBHOOK_URL="${{ secrets.TEAMS_WEBHOOK_URL }}"
    export SLACK_WEBHOOK_URL="${{ secrets.SLACK_WEBHOOK_URL }}"
    npm run notify:all                  # Send to all platforms
```

### **Scenario 3: Manual Quick Test**

```bash
# Run from project root
./run-tests.sh test smoke 3

# Or with notification
cd automationexercise-e2e-pom
npm run test:smoke && npm run notify:all
```

## 🔧 Configuration Required:

### **GitHub Secrets (Required for notifications):**

```bash
# Navigate to:
Settings → Secrets and variables → Actions → New repository secret

# Add these:
TEAMS_WEBHOOK_URL         # Your Teams Power Automate webhook
SLACK_WEBHOOK_URL         # Your Slack incoming webhook  
EMAIL_USERNAME            # Gmail address
EMAIL_PASSWORD            # Gmail app password
```

### **Local Environment (For local testing):**

```bash
# Add to ~/.zshrc or ~/.bashrc:
export TEAMS_WEBHOOK_URL="your-teams-webhook-url"
export SLACK_WEBHOOK_URL="your-slack-webhook-url"

# Then reload:
source ~/.zshrc
```

## 📊 Complete Flow Diagram:

```
┌─────────────────────┐
│  Trigger Test Run   │
│  (Manual/Auto/Cron) │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Setup & Install   │
│  - Node.js          │
│  - Dependencies     │
│  - Playwright       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│    Run Tests        │
│  - Smoke            │
│  - Regression       │
│  - All              │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Generate Reports   │
│  - Allure           │
│  - Metrics          │
│  - Email HTML       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Send Notifications  │
│  - Teams (if conf)  │
│  - Slack (if conf)  │
│  - Email (if recip) │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Upload Artifacts   │
│  - Reports          │
│  - Test Results     │
│  - Allure Report    │
└─────────────────────┘
```

## 🎯 Recommendations by Use Case:

### **1. Daily Development:**
```bash
# Local run with quick feedback
npm run test:smoke
npm run teams:notify "Dev tests completed"
```

### **2. Pre-commit Validation:**
```bash
# Run smoke tests before committing
npm run test:smoke:ci
```

### **3. Pull Request:**
```yaml
# Automatically triggered
# No action needed - just create PR
```

### **4. Release Candidate:**
```bash
# Manual workflow dispatch
Environment: prerelease
Test Scope: regression
Workers: 5
Email Recipients: team@example.com, qa@example.com
```

### **5. Production Deployment:**
```bash
# Manual workflow dispatch
Environment: test
Test Scope: all
Workers: 3
Email Recipients: team@example.com, stakeholders@example.com
```

## 🚨 Important Notes:

1. **Always use `:ci` suffix scripts in CI** for faster execution:
   - `test:smoke:ci` instead of `test:smoke`
   - `test:regression:ci` instead of `test:regression`

2. **Notifications are optional** - tests run even if webhooks not configured

3. **Use `continue-on-error: true`** for notification steps to not fail the pipeline

4. **Email notifications require recipients** - only sent when email_recipients input is provided

5. **Check artifacts** for detailed reports even if notifications fail

## 📚 Related Documentation:

- [CI/CD Integration Guide](./CI-CD-INTEGRATION-GUIDE.md) - Detailed setup
- [Teams Setup Guide](./TEAMS-SETUP-GUIDE.md) - Teams webhook configuration
- [Slack Setup Guide](./SLACK-SETUP-GUIDE.md) - Slack webhook configuration
- [Quick Commands](../../QUICK-COMMANDS.md) - Daily usage commands

## ✅ Quick Start:

```bash
# 1. Configure secrets in GitHub
Settings → Secrets → Add TEAMS_WEBHOOK_URL, SLACK_WEBHOOK_URL

# 2. Test locally first
cd automationexercise-e2e-pom
npm run teams:test
npm run slack:test

# 3. Run workflow from GitHub Actions
Actions → E2E Test Automation → Run workflow

# 4. Check notifications in Teams/Slack channels

# 5. Download artifacts for detailed reports
```

---

**Pro Tip:** Để test notification format mà không chạy tests:
```bash
export TEAMS_WEBHOOK_URL="your-url"
npm run teams:notify "🧪 Test message"
```
