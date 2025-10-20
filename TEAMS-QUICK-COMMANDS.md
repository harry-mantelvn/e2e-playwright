# Quick Commands - Teams Notification Testing

## Test Payload Format (No Sending)
```bash
cd automationexercise-e2e-pom
./scripts/test-teams-payload.sh
```

## Test Teams Notification (Requires Webhook)
```bash
cd automationexercise-e2e-pom
export TEAMS_WEBHOOK_URL="your-power-automate-webhook-url"
npm run teams:notify "Test notification from terminal"
```

## Test Slack Notification (Requires Webhook)
```bash
cd automationexercise-e2e-pom
export SLACK_WEBHOOK_URL="your-slack-webhook-url"
npm run slack:notify "Test notification from terminal"
```

## View Current Script
```bash
cat automationexercise-e2e-pom/scripts/send-teams-notification.sh
```

## Check GitHub Actions Workflow
```bash
cat .github/workflows/e2e-automation.yml | grep -A 20 "Send Teams Notification"
```

## Commit Changes
```bash
git add .
git commit -m "Fix Teams notification with adaptive card format"
git push origin feat/notifications-clean
```

## Trigger GitHub Actions Workflow
1. Go to GitHub repository
2. Click "Actions" tab
3. Select "E2E Test Automation" workflow
4. Click "Run workflow"
5. Fill in parameters and run
6. Monitor "Send Teams Notification" step

## View Documentation
```bash
cat automationexercise-e2e-pom/documents/TEAMS-NOTIFICATION-FIX.md
cat TEAMS-FIX-SUMMARY.md
```
