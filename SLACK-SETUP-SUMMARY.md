# ⚠️ CẢNH BÁO BẢO MẬT & GIẢI PHÁP

## 🚨 Vấn Đề: Token Bị Lộ

Bạn đã chia sẻ công khai:
- Slack OAuth token: `xoxe.xoxp-1-Mi0y...`
- Slack refresh token: `xoxe-1-My0xLTI3MDM4...`

### ⚡ HÀNH ĐỘNG KHẨN CẤP (LÀM NGAY!)

```bash
# 1. Thu hồi token ngay lập tức
# Truy cập: https://api.slack.com/apps
# → Chọn app của bạn
# → OAuth & Permissions
# → Revoke tokens
# → Hoặc xóa và tạo lại app

# 2. Xóa token khỏi mọi nơi đã chia sẻ
# 3. KHÔNG BAO GIỜ commit tokens vào Git
```

---

## ✅ GIẢI PHÁP: Slack Integration Helper

Tôi đã tạo một hệ thống tích hợp Slack **AN TOÀN** sử dụng **Incoming Webhooks** thay vì OAuth tokens.

### Tại Sao Webhooks Tốt Hơn?
- ✅ Đơn giản hơn nhiều
- ✅ An toàn hơn (chỉ gửi tin nhắn)
- ✅ Không cần quản lý refresh tokens
- ✅ Đủ cho notifications (không cần full API access)

---

## 📦 Những Gì Đã Tạo

### 1. **Slack Helper (TypeScript)** ✨
📁 `helper/slack-helper.ts`

Features:
- ✅ Send simple messages
- ✅ Send rich formatted test reports
- ✅ Send error notifications
- ✅ Send custom Block Kit messages
- ✅ Auto-detect if Slack is configured
- ✅ Graceful error handling

### 2. **Example Usage** 📚
📁 `helper/slack-helper.example.ts`

Ví dụ đầy đủ cách sử dụng mọi tính năng.

### 3. **CLI Tool** 🛠️
📁 `slack-cli.js`

Sử dụng qua command line:
```bash
# Send message
npm run slack:cli "Test completed! ✅"

# Send test report
npm run slack:report
```

### 4. **Bash Script** (Đã có)
📁 `scripts/send-slack-notification.sh`

Đã được cập nhật với Slack Block Kit format.

### 5. **Documentation (Vietnamese)** 📖
📁 `documents/SLACK-INTEGRATION-GUIDE-VI.md`

Hướng dẫn đầy đủ bằng tiếng Việt về:
- Cách tạo Incoming Webhook
- Cách lưu webhook URL an toàn
- Cách sử dụng helper
- Examples và best practices
- Troubleshooting

---

## 🚀 CÁCH SỬ DỤNG

### Bước 1: Tạo Slack Incoming Webhook

```
1. Vào: https://api.slack.com/apps
2. Create New App → From scratch
3. Nhập tên app, chọn workspace
4. Vào "Incoming Webhooks" → Activate
5. "Add New Webhook to Workspace"
6. Chọn channel
7. Copy Webhook URL
```

### Bước 2: Lưu Webhook URL An Toàn

#### Cho GitHub Actions:
```
1. Vào repo → Settings → Secrets → Actions
2. New repository secret
3. Name: SLACK_WEBHOOK_URL
4. Value: your-webhook-url
5. Add secret
```

#### Cho Local Development:
```bash
# Tạo file .env (đã có trong .gitignore)
echo "SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL" >> .env
```

### Bước 3: Install Dependencies

```bash
cd automationexercise-e2e-pom
npm install axios
```

### Bước 4: Sử Dụng

#### TypeScript (trong tests):
```typescript
import { slackHelper, sendSlackTestReport } from './helper/slack-helper';

// Simple message
await slackHelper.sendSimpleMessage('Hello Slack! 👋');

// Test report
await sendSlackTestReport({
  totalTests: 10,
  passedTests: 9,
  failedTests: 1,
  passRate: 90,
  environment: 'test',
  testScope: 'smoke'
}, 'https://github.com/.../runs/123');
```

#### CLI:
```bash
# Set webhook (tạm thời)
export SLACK_WEBHOOK_URL="your-url"

# Send message
npm run slack:cli "Tests completed! ✅"

# Send test report (từ metrics.json)
npm run slack:report
```

#### Bash Script:
```bash
export SLACK_WEBHOOK_URL="your-url"
./scripts/send-slack-notification.sh "Your message"
```

#### GitHub Actions (đã tích hợp sẵn):
```yaml
- name: Send Slack Notification
  run: |
    cd automationexercise-e2e-pom
    export SLACK_WEBHOOK_URL="${{ secrets.SLACK_WEBHOOK_URL }}"
    npm run slack:notify "Tests completed!"
```

---

## 📝 NPM Scripts Mới

```json
{
  "slack:cli": "node slack-cli.js",          // CLI tool
  "slack:report": "node slack-cli.js --report", // Send test report
  "slack:notify": "./scripts/send-slack-notification.sh", // Bash script
  "slack:test": "./scripts/test-slack-integration.sh"  // Test integration
}
```

---

## 🎨 Message Format Examples

### Simple Message
```typescript
await slackHelper.sendSimpleMessage('Hello! 👋');
```

### Rich Test Report
```typescript
await sendSlackTestReport({
  totalTests: 10,
  passedTests: 9,
  failedTests: 1,
  passRate: 90,
  duration: '5m 30s',
  environment: 'test',
  testScope: 'smoke'
}, pipelineUrl);
```

Result: Formatted card với status, metrics, và link đến pipeline.

### Error Notification
```typescript
await slackHelper.sendErrorNotification(
  'Database connection failed',
  'Test: auth.spec.ts, Env: test'
);
```

### Custom Block Kit Message
```typescript
await slackHelper.sendCustomMessage({
  text: 'Deployment Complete',
  blocks: [
    {
      type: 'header',
      text: { type: 'plain_text', text: '🚀 Deployment' }
    },
    {
      type: 'section',
      fields: [
        { type: 'mrkdwn', text: '*Env:*\nProduction' },
        { type: 'mrkdwn', text: '*Version:*\nv1.2.3' }
      ]
    }
  ]
});
```

---

## ✅ Đã Tích Hợp Vào GitHub Actions

File `.github/workflows/e2e-automation.yml` đã có step:

```yaml
- name: Send Slack Notification
  if: always()
  run: |
    cd automationexercise-e2e-pom
    export SLACK_WEBHOOK_URL="${{ secrets.SLACK_WEBHOOK_URL }}"
    # ... read metrics and send ...
    npm run slack:notify "$MESSAGE"
  continue-on-error: true
```

---

## 🔧 Files Structure

```
automationexercise-e2e-pom/
├── helper/
│   ├── slack-helper.ts                    # ✨ Main helper
│   └── slack-helper.example.ts            # 📚 Examples
├── scripts/
│   ├── send-slack-notification.sh         # 🛠️ Bash script
│   └── test-slack-integration.sh          # 🧪 Test script
├── documents/
│   └── SLACK-INTEGRATION-GUIDE-VI.md      # 📖 Guide (Vietnamese)
├── slack-cli.js                            # 🖥️ CLI tool
└── package.json                            # Updated with new scripts
```

---

## 🧪 Test Integration

```bash
cd automationexercise-e2e-pom

# Test 1: Simple CLI
export SLACK_WEBHOOK_URL="your-url"
npm run slack:cli "Test message from CLI"

# Test 2: Test report (requires metrics.json)
npm run slack:report

# Test 3: Bash script
npm run slack:notify "Test from bash script"

# Test 4: Test integration script
npm run slack:test
```

---

## 📚 Documentation

Đọc hướng dẫn chi tiết (tiếng Việt):
```bash
cat automationexercise-e2e-pom/documents/SLACK-INTEGRATION-GUIDE-VI.md
```

Xem examples:
```bash
cat automationexercise-e2e-pom/helper/slack-helper.example.ts
```

---

## ⚡ Best Practices

### ✅ NÊN
- ✅ Dùng Incoming Webhooks cho notifications
- ✅ Lưu webhook URL trong GitHub Secrets
- ✅ Thêm `.env` vào `.gitignore`
- ✅ Check `isConfigured()` trước khi gửi
- ✅ Handle errors gracefully

### ❌ KHÔNG NÊN
- ❌ Commit OAuth tokens
- ❌ Chia sẻ tokens công khai
- ❌ Hardcode webhook URLs
- ❌ Để test fail nếu Slack lỗi

---

## 🆘 Troubleshooting

### "Slack not configured"
```bash
echo $SLACK_WEBHOOK_URL  # Check if set
export SLACK_WEBHOOK_URL="your-url"
```

### "Cannot find module 'axios'"
```bash
npm install axios
```

### "Invalid webhook URL"
- Format đúng: `https://hooks.slack.com/services/...`
- Tạo lại webhook từ Slack App

---

## 📋 Checklist

- [x] Tạo Slack Helper (TypeScript)
- [x] Tạo CLI tool
- [x] Update bash script với Block Kit format
- [x] Tạo examples
- [x] Viết documentation (Vietnamese)
- [x] Add NPM scripts
- [x] Install axios dependency
- [x] Tích hợp vào GitHub Actions workflow
- [ ] **THU HỒI TOKEN BỊ LỘ** ⚠️
- [ ] Tạo Slack Incoming Webhook
- [ ] Lưu webhook vào GitHub Secrets
- [ ] Test integration

---

## 🎯 Next Steps

### 1. THU HỒI TOKEN NGAY! (QUAN TRỌNG NHẤT)
```
https://api.slack.com/apps → Your App → OAuth & Permissions → Revoke
```

### 2. Tạo Slack Incoming Webhook
```
https://api.slack.com/apps → Create New App → Incoming Webhooks
```

### 3. Add To GitHub Secrets
```
Repo → Settings → Secrets → SLACK_WEBHOOK_URL
```

### 4. Test Locally
```bash
export SLACK_WEBHOOK_URL="your-webhook-url"
npm run slack:cli "Hello Slack!"
```

### 5. Test In GitHub Actions
```
Push changes → Actions → Run workflow → Check Slack
```

---

## 📄 Files Created/Modified

### New Files:
1. ✨ `helper/slack-helper.ts` - Main Slack integration helper
2. 📚 `helper/slack-helper.example.ts` - Usage examples
3. 🖥️ `slack-cli.js` - CLI tool
4. 📖 `documents/SLACK-INTEGRATION-GUIDE-VI.md` - Vietnamese guide
5. 📝 `SLACK-SETUP-SUMMARY.md` - This file

### Modified Files:
1. 📦 `package.json` - Added slack:cli and slack:report scripts
2. 🛠️ `scripts/send-slack-notification.sh` - Updated with Block Kit format
3. ⚙️ `.github/workflows/e2e-automation.yml` - Already integrated

### Installed:
1. 📦 `axios` - HTTP client for API calls

---

## 🌟 Summary

Bạn giờ có:
- ✅ TypeScript helper mạnh mẽ cho Slack integration
- ✅ CLI tool dễ sử dụng
- ✅ Bash scripts đã update
- ✅ Documentation đầy đủ (tiếng Việt)
- ✅ Examples chi tiết
- ✅ Tích hợp sẵn vào GitHub Actions
- ✅ **GIẢI PHÁP AN TOÀN** (Webhooks thay vì OAuth tokens)

**QUAN TRỌNG:**
🚨 Thu hồi token bị lộ NGAY!
🔐 Sử dụng Incoming Webhooks thay thế
📖 Đọc guide để setup đúng cách

---

**Date**: 17/10/2025  
**Status**: ✅ Ready to use  
**Security**: ⚠️ Revoke exposed tokens first!
