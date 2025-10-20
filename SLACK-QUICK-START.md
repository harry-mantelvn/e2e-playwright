# Slack Integration - Quick Commands

## ⚠️ FIRST: Revoke Exposed Tokens!
```
https://api.slack.com/apps → Your App → OAuth & Permissions → Revoke Tokens
```

## 🚀 Quick Setup

### 1. Create Incoming Webhook
```
https://api.slack.com/apps → Create App → Incoming Webhooks → Add to Workspace
```

### 2. Save to GitHub Secrets
```
Repo → Settings → Secrets → Actions → New Secret
Name: SLACK_WEBHOOK_URL
Value: <your-webhook-url>
```

### 3. Local Testing (Optional)
```bash
cd automationexercise-e2e-pom
echo "SLACK_WEBHOOK_URL=your-webhook-url" >> .env
npm install axios
```

## 💬 Send Messages

### CLI (Easiest)
```bash
export SLACK_WEBHOOK_URL="your-url"
npm run slack:cli "Test message! ✅"
```

### Send Test Report
```bash
npm run slack:report  # Requires test-summary/metrics.json
```

### Bash Script
```bash
npm run slack:notify "Your message"
```

### TypeScript
```typescript
import { slackHelper } from './helper/slack-helper';
await slackHelper.sendSimpleMessage('Hello! 👋');
```

## 🧪 Test Integration
```bash
npm run slack:test
```

## 📖 Full Documentation
```bash
cat documents/SLACK-INTEGRATION-GUIDE-VI.md
cat SLACK-SETUP-SUMMARY.md
```

## 🆘 Troubleshooting

**"Slack not configured"**
```bash
echo $SLACK_WEBHOOK_URL  # Should output your URL
export SLACK_WEBHOOK_URL="your-url"
```

**"Cannot find module 'axios'"**
```bash
npm install axios
```

## ✅ Verification
```bash
# 1. Check helper exists
ls helper/slack-helper.ts

# 2. Check webhook is set
echo $SLACK_WEBHOOK_URL

# 3. Test send
npm run slack:cli "Test! ✅"
```

---
**Read full guide**: `documents/SLACK-INTEGRATION-GUIDE-VI.md`
