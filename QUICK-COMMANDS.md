# E2E Test Automation - Quick Commands

## 🎯 Cách chạy commands đúng cách:

### **Option 1: Từ thư mục chính**
```bash
# Navigate to correct directory first
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom

# Then run any npm command
npm run test:smoke
npm run teams:notify
npm run allure:generate
```

### **Option 2: Sử dụng script tiện lợi**
```bash
# From anywhere in the project
/Users/nam.nguyenduc/e2e-playwright/run-tests.sh test smoke
/Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom/scripts/index.sh teams:notify
```

### **Option 3: Alias commands (Add to ~/.zshrc)**
```bash
# Add these to your ~/.zshrc file
alias e2e-cd='cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom'
alias e2e-smoke='cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom && npm run test:smoke'
alias e2e-teams='cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom && npm run teams:enhanced'
alias e2e-reports='cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom && npm run reports:all'
```

## 🔧 Quick Setup Commands:

### **Teams Integration Test:**
```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom
export TEAMS_WEBHOOK_URL="https://your-tenant.powerplatform.com/powerautomate/automations/direct/workflows/YOUR_WORKFLOW_ID/triggers/manual/paths/invoke"
npm run teams:test
```

### **Slack Integration Test:**
```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR_WORKSPACE_ID/YOUR_CHANNEL_ID/YOUR_TOKEN"
npm run slack:test
```

### **Run Tests with Notifications:**
```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom
npm run test:smoke && npm run notify:all
```

## 📱 Available NPM Scripts:

| Command | Description |
|---------|-------------|
| `npm run test:smoke` | Run smoke tests |
| `npm run test:regression` | Run regression tests |
| `npm run test:all` | Run all tests |
| `npm run teams:notify` | Send basic Teams notification |
| `npm run teams:enhanced` | Send enhanced Teams notification |
| `npm run teams:test` | Test Teams integration |
| `npm run slack:notify` | Send basic Slack notification |
| `npm run slack:test` | Test Slack integration |
| `npm run notify:all` | Send to all platforms |
| `npm run allure:generate` | Generate Allure report |
| `npm run allure:open` | Open Allure report |
| `npm run reports:all` | Generate all reports |

## 🚨 Common Issues:

1. **ENOENT package.json error**: Make sure you're in the correct directory
2. **Permission denied**: Run `chmod +x scripts/*.sh`
3. **Webhook errors**: Check webhook URL format and environment variables
4. **Scripts not found**: Ensure all .sh files are in scripts/ directory

## 🎯 Quick Setup:

```bash
# 1. Navigate to project
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom

# 2. Install dependencies (if needed)
npm install

# 3. Set webhook URLs (optional)
export TEAMS_WEBHOOK_URL="your-teams-webhook-url"
export SLACK_WEBHOOK_URL="your-slack-webhook-url"

# 4. Test integrations
npm run teams:test
npm run slack:test

# 5. Run tests with notifications
npm run test:smoke && npm run notify:all
```

## 📚 Documentation:

- Teams setup: `documents/TEAMS-SETUP-GUIDE.md`
- Slack setup: `documents/SLACK-SETUP-GUIDE.md`
- Scripts help: `scripts/index.sh` (no args for help)

## 🔒 Security Notes:

- Never commit real webhook URLs to git
- Use environment variables for sensitive data
- Keep setup guides updated with safe placeholder examples
