# CI/CD Integration Guide - Test Execution với Notifications

## 📋 Overview

Hướng dẫn này giải thích cách chạy E2E tests trên CI và gửi notifications đến Teams/Slack.

## 🎯 GitHub Actions Jobs

### 1. **Workflow Triggers**

Workflow có thể được trigger bởi:

```yaml
# Manual dispatch (khuyến khích dùng)
workflow_dispatch

# Tự động khi push
push:
  branches: [main, develop]

# Pull request
pull_request:
  branches: [main]

# Scheduled (6 AM UTC hàng ngày)
schedule:
  - cron: '0 6 * * *'
```

### 2. **Test Execution Options**

#### **Option A: Manual Trigger (Khuyến nghị)**
```bash
# Từ GitHub UI:
Actions → E2E Test Automation → Run workflow
```

**Parameters:**
- **environment**: `test` | `prerelease`
- **test_scope**: `smoke` | `regression` | `all` | `basic` | `specific`
- **workers**: Number of parallel workers (default: 3)
- **email_recipients**: Comma-separated emails (optional)

#### **Option B: Tự động trên Push/PR**
```bash
git push origin main  # Tự động chạy smoke tests
```

#### **Option C: Scheduled**
```bash
# Tự động chạy daily vào 6 AM UTC (1 PM Vietnam)
```

## 📱 Notifications Setup

### **Bước 1: Cấu hình GitHub Secrets**

Vào `Settings → Secrets and variables → Actions` và thêm:

#### **Email Notifications:**
```bash
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-password  # Google App Password
```

#### **Teams Notifications:**
```bash
TEAMS_WEBHOOK_URL=https://your-tenant.powerplatform.com/powerautomate/automations/direct/workflows/YOUR_WORKFLOW_ID/triggers/manual/paths/invoke
```

#### **Slack Notifications:**
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR_WORKSPACE_ID/YOUR_CHANNEL_ID/YOUR_TOKEN
```

### **Bước 2: Thêm Notification Steps vào Workflow**

Thêm vào file `.github/workflows/e2e-automation.yml`:

```yaml
      - name: Send Teams Notification
        if: ${{ always() && secrets.TEAMS_WEBHOOK_URL != '' }}
        run: |
          cd automationexercise-e2e-pom
          export TEAMS_WEBHOOK_URL="${{ secrets.TEAMS_WEBHOOK_URL }}"
          npm run teams:notify "✅ E2E Tests completed - Run #${{ github.run_number }}"
        continue-on-error: true

      - name: Send Slack Notification
        if: ${{ always() && secrets.SLACK_WEBHOOK_URL != '' }}
        run: |
          cd automationexercise-e2e-pom
          export SLACK_WEBHOOK_URL="${{ secrets.SLACK_WEBHOOK_URL }}"
          npm run slack:notify "✅ E2E Tests completed - Run #${{ github.run_number }}"
        continue-on-error: true
```

## 🚀 NPM Scripts cho CI

### **Test Execution Scripts**

```json
{
  "test:smoke:ci": "npm run clean && cross-env NODE_ENV=test npx playwright test tests/smoke",
  "test:regression:ci": "npm run clean && cross-env NODE_ENV=prerelease npx playwright test tests/regression",
  "test:all:ci": "npm run clean && cross-env NODE_ENV=test npx playwright test"
}
```

**Cách dùng trong CI:**
```yaml
- name: Run Tests
  run: |
    cd automationexercise-e2e-pom
    npm run test:smoke:ci
```

### **Report Generation Scripts**

```json
{
  "reports:ci": "npm run allure:generate && npm run metrics:generate && npm run email:enhanced"
}
```

**Cách dùng:**
```yaml
- name: Generate Reports
  if: always()
  run: |
    cd automationexercise-e2e-pom
    npm run reports:ci
```

### **Notification Scripts**

```json
{
  "teams:notify": "./scripts/send-teams-notification.sh",
  "slack:notify": "./scripts/send-slack-notification.sh",
  "notify:all": "./scripts/send-universal-notification.sh"
}
```

**Cách dùng:**
```yaml
- name: Send Notifications
  if: always()
  run: |
    cd automationexercise-e2e-pom
    npm run notify:all
```

## 📊 Complete CI Pipeline Example

### **Recommended Job Structure:**

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      # 1. Setup
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: |
          cd automationexercise-e2e-pom
          npm ci
      
      - name: Install Playwright browsers
        run: |
          cd automationexercise-e2e-pom
          npx playwright install --with-deps
      
      # 2. Run Tests
      - name: Run smoke tests
        run: |
          cd automationexercise-e2e-pom
          npm run test:smoke:ci
        continue-on-error: true
      
      # 3. Generate Reports
      - name: Generate reports
        if: always()
        run: |
          cd automationexercise-e2e-pom
          npm run reports:ci
        continue-on-error: true
      
      # 4. Send Notifications
      - name: Send Teams notification
        if: ${{ always() && secrets.TEAMS_WEBHOOK_URL != '' }}
        run: |
          cd automationexercise-e2e-pom
          export TEAMS_WEBHOOK_URL="${{ secrets.TEAMS_WEBHOOK_URL }}"
          npm run teams:notify "Tests completed - Run #${{ github.run_number }}"
        continue-on-error: true
      
      - name: Send Slack notification
        if: ${{ always() && secrets.SLACK_WEBHOOK_URL != '' }}
        run: |
          cd automationexercise-e2e-pom
          export SLACK_WEBHOOK_URL="${{ secrets.SLACK_WEBHOOK_URL }}"
          npm run slack:notify "Tests completed - Run #${{ github.run_number }}"
        continue-on-error: true
      
      # 5. Upload Artifacts
      - name: Upload reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-reports-${{ github.run_number }}
          path: automationexercise-e2e-pom/test-reports/
```

## 🎯 Best Practices

### **1. Test Scope Selection:**

| Scenario | Test Scope | Workers |
|----------|------------|---------|
| Quick validation | `smoke` | 3 |
| Full regression | `regression` | 5 |
| Before deployment | `all` | 3 |
| PR validation | `smoke` | 2 |
| Scheduled nightly | `regression` | 5 |

### **2. Notification Strategy:**

```yaml
# Send Teams for all runs
- if: ${{ always() && secrets.TEAMS_WEBHOOK_URL != '' }}

# Send Slack only on failures
- if: ${{ failure() && secrets.SLACK_WEBHOOK_URL != '' }}

# Send email only on manual trigger with recipients
- if: ${{ always() && github.event.inputs.email_recipients != '' }}
```

### **3. Error Handling:**

```yaml
# Tests should continue even if failed
continue-on-error: true

# Reports should always run
if: always()

# Notifications are optional
continue-on-error: true
```

## 🔍 Troubleshooting

### **Issue: Notifications not sent**

**Check:**
1. Secrets are configured correctly
2. Webhook URLs are valid
3. Scripts have execute permissions
4. Environment variables are exported

**Solution:**
```yaml
- name: Debug webhook
  run: |
    echo "Teams webhook configured: ${{ secrets.TEAMS_WEBHOOK_URL != '' }}"
    echo "Slack webhook configured: ${{ secrets.SLACK_WEBHOOK_URL != '' }}"
```

### **Issue: Tests fail in CI but pass locally**

**Check:**
1. Dependencies installed: `npm ci`
2. Browsers installed: `npx playwright install --with-deps`
3. Environment variables set correctly
4. Sufficient workers for CI: use 2-3 instead of 5

### **Issue: Reports not generated**

**Check:**
1. Test results exist in `test-reports/`
2. Scripts have execute permissions
3. Dependencies installed (allure-commandline)

**Solution:**
```bash
chmod +x scripts/*.sh
npm run allure:generate
```

## 📚 Related Documentation

- [Teams Setup Guide](./TEAMS-SETUP-GUIDE.md)
- [Slack Setup Guide](./SLACK-SETUP-GUIDE.md)
- [Quick Commands](../../QUICK-COMMANDS.md)
- [Scripts README](../scripts/README.md)

## ✅ Quick Start Checklist

- [ ] Configure GitHub Secrets (TEAMS_WEBHOOK_URL, SLACK_WEBHOOK_URL)
- [ ] Update workflow file with notification steps
- [ ] Test notifications locally first
- [ ] Run manual workflow dispatch to verify
- [ ] Check notification channels for messages
- [ ] Review artifacts and reports
- [ ] Set up scheduled runs if needed
