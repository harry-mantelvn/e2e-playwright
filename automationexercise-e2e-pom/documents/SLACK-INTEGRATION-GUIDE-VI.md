# Hướng Dẫn Tích Hợp Slack - Cách An Toàn

## ⚠️ LƯU Ý BẢO MẬT QUAN TRỌNG

**KHÔNG BAO GIỜ chia sẻ hoặc commit các thông tin sau:**
- ❌ OAuth tokens (`xoxe.xoxp-...`)
- ❌ Refresh tokens (`xoxe-1-My...`)
- ❌ API keys, passwords
- ❌ Webhook URLs thực

**LÀM GÌ NẾU BẠN VỪA LỘ TOKEN:**
1. Thu hồi token ngay tại https://api.slack.com/apps
2. Xóa token khỏi mọi nơi đã chia sẻ
3. Tạo token mới
4. Lưu vào GitHub Secrets hoặc biến môi trường

---

## 🎯 Giải Pháp Được Khuyến Nghị: Slack Incoming Webhooks

### Tại Sao Dùng Webhooks Thay Vì OAuth Tokens?

| Tiêu chí | Webhooks | OAuth Tokens |
|----------|----------|--------------|
| **Độ phức tạp** | Đơn giản | Phức tạp |
| **Bảo mật** | Cao (chỉ gửi tin nhắn) | Thấp hơn (nhiều quyền) |
| **Quản lý** | Dễ | Khó (cần refresh) |
| **Use case** | Notifications | Full API access |

### Bước 1: Tạo Slack Incoming Webhook

1. **Truy cập**: https://api.slack.com/apps
2. **Create New App** → "From scratch"
3. Nhập tên app và chọn workspace
4. Vào **"Incoming Webhooks"**
5. Bật **"Activate Incoming Webhooks"**
6. Nhấn **"Add New Webhook to Workspace"**
7. Chọn channel muốn nhận thông báo
8. Copy Webhook URL (dạng: `https://hooks.slack.com/services/T.../B.../...`)

### Bước 2: Lưu Webhook URL An Toàn

#### Option A: GitHub Secrets (Khuyến nghị cho CI/CD)
```bash
# Không chạy lệnh này! Làm qua GitHub UI
# 1. Vào repository → Settings → Secrets and variables → Actions
# 2. Nhấn "New repository secret"
# 3. Name: SLACK_WEBHOOK_URL
# 4. Value: your-webhook-url
# 5. Add secret
```

#### Option B: File .env (Cho local development)
```bash
# Tạo file .env (đã có trong .gitignore)
echo "SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL" >> .env

# QUAN TRỌNG: Kiểm tra .env không bị commit
git status  # .env KHÔNG được xuất hiện ở đây
```

#### Option C: Export biến môi trường tạm thời
```bash
# Chỉ tồn tại trong session hiện tại
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

---

## 📦 Cài Đặt Dependencies

```bash
cd automationexercise-e2e-pom
npm install axios
```

---

## 🚀 Cách Sử Dụng Slack Helper

### 1. Import Helper

```typescript
import { slackHelper, sendSlackTestReport } from './helper/slack-helper';
```

### 2. Gửi Tin Nhắn Đơn Giản

```typescript
await slackHelper.sendSimpleMessage('Hello from E2E Tests! 👋');
```

### 3. Gửi Test Report Với Format Đẹp

```typescript
const metrics = {
  totalTests: 10,
  passedTests: 9,
  failedTests: 1,
  passRate: 90,
  duration: '5m 30s',
  environment: 'test',
  testScope: 'smoke'
};

const pipelineUrl = 'https://github.com/user/repo/actions/runs/123';

await sendSlackTestReport(metrics, pipelineUrl);
```

### 4. Gửi Thông Báo Lỗi

```typescript
await slackHelper.sendErrorNotification(
  'Database connection failed',
  'Test: smoke-auth.spec.ts, Environment: test'
);
```

### 5. Gửi Custom Message

```typescript
await slackHelper.sendCustomMessage({
  text: 'Deployment Complete',
  blocks: [
    {
      type: 'header',
      text: {
        type: 'plain_text',
        text: '🚀 Production Deployment'
      }
    }
  ]
});
```

---

## 🧪 Test Integration

### Test Local
```bash
cd automationexercise-e2e-pom

# Set webhook URL (tạm thời)
export SLACK_WEBHOOK_URL="your-webhook-url"

# Test script có sẵn
npm run slack:test
```

### Test Trong Playwright Test
```typescript
import { test } from '@playwright/test';
import { slackHelper } from './helper/slack-helper';

test.afterAll(async () => {
  await slackHelper.sendSimpleMessage('✅ Test suite completed!');
});
```

### Test Trong GitHub Actions
```yaml
- name: Send Slack Notification
  run: |
    cd automationexercise-e2e-pom
    export SLACK_WEBHOOK_URL="${{ secrets.SLACK_WEBHOOK_URL }}"
    npm run slack:notify "Tests completed!"
```

---

## 📝 Script CLI (Đã Có Sẵn)

### Bash Script
```bash
./scripts/send-slack-notification.sh "Your message here"
```

### NPM Script
```bash
npm run slack:notify "Test completed successfully!"
```

---

## 🔧 Tích Hợp Với Test Report

### File: `helper/notification-helper.ts`
```typescript
import { sendSlackTestReport } from './slack-helper';
import * as fs from 'fs';

export async function sendTestResults() {
  // Read metrics from file
  const metrics = JSON.parse(
    fs.readFileSync('test-summary/metrics.json', 'utf-8')
  );

  // Send to Slack
  await sendSlackTestReport({
    totalTests: metrics.total_test_cases,
    passedTests: metrics.passed_tests,
    failedTests: metrics.failed_tests,
    passRate: metrics.pass_rate,
    duration: metrics.duration,
    environment: process.env.ENVIRONMENT || 'test',
    testScope: process.env.TEST_SCOPE || 'all'
  }, process.env.PIPELINE_URL);
}
```

---

## 🎨 Tùy Chỉnh Format Message

### Block Kit Builder
Slack cung cấp tool thiết kế message trực quan:
👉 https://app.slack.com/block-kit-builder

### Ví Dụ Rich Message
```typescript
const richMessage = {
  text: 'Test Report',
  blocks: [
    {
      type: 'header',
      text: {
        type: 'plain_text',
        text: '🧪 E2E Test Report'
      }
    },
    {
      type: 'section',
      fields: [
        { type: 'mrkdwn', text: '*Status:*\n✅ PASSED' },
        { type: 'mrkdwn', text: '*Pass Rate:*\n95%' }
      ]
    },
    {
      type: 'divider'
    },
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: '<https://github.com/...|View Pipeline>'
      }
    }
  ]
};
```

---

## ⚡ Best Practices

### ✅ NÊN LÀM
- ✅ Sử dụng Incoming Webhooks cho notifications
- ✅ Lưu webhook URL trong GitHub Secrets
- ✅ Thêm `.env` vào `.gitignore`
- ✅ Kiểm tra `slackHelper.isConfigured()` trước khi gửi
- ✅ Handle errors gracefully (không fail test nếu Slack lỗi)
- ✅ Sử dụng `continue-on-error: true` trong GitHub Actions

### ❌ KHÔNG NÊN
- ❌ Commit OAuth tokens vào code
- ❌ Chia sẻ tokens công khai
- ❌ Hardcode webhook URLs trong code
- ❌ Để test fail nếu Slack không available
- ❌ Spam Slack với quá nhiều notifications

---

## 🔍 Troubleshooting

### Lỗi: "Slack not configured"
```bash
# Kiểm tra biến môi trường
echo $SLACK_WEBHOOK_URL

# Nếu trống, set lại
export SLACK_WEBHOOK_URL="your-url"
```

### Lỗi: "Cannot find module 'axios'"
```bash
cd automationexercise-e2e-pom
npm install axios
```

### Lỗi: "Invalid webhook URL"
- Kiểm tra URL đúng format: `https://hooks.slack.com/services/...`
- Tạo lại webhook từ Slack App settings

### Message không hiển thị trong Slack
- Kiểm tra channel permissions
- Verify app đã được add vào channel
- Test với simple message trước

---

## 📚 Tài Liệu Tham Khảo

- [Slack Incoming Webhooks](https://api.slack.com/messaging/webhooks)
- [Slack Block Kit](https://api.slack.com/block-kit)
- [Slack API Documentation](https://api.slack.com/docs)
- [Message Formatting](https://api.slack.com/reference/surfaces/formatting)

---

## 🆘 Support

Nếu cần hỗ trợ:
1. Xem file example: `helper/slack-helper.example.ts`
2. Test với script: `npm run slack:test`
3. Kiểm tra logs trong GitHub Actions
4. Verify webhook URL đã đúng format

---

**⚠️ NHẮC NHỞ CUỐI CÙNG:**
- Thu hồi NGAY token bạn vừa chia sẻ!
- Không bao giờ commit secrets vào Git
- Luôn dùng GitHub Secrets hoặc biến môi trường
- Kiểm tra `.gitignore` trước khi commit

---

**Ngày tạo**: 17/10/2025  
**Tác giả**: GitHub Copilot  
**Phiên bản**: 1.0
