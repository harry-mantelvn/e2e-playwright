# 🚀 HƯỚNG DẪN CÀI ĐẶT E2E TEST AUTOMATION - STEP BY STEP

## 📋 MỤC LỤC
1. [Chuẩn Bị](#1-chuẩn-bị)
2. [Setup Email Notifications](#2-setup-email-notifications)
3. [Setup Teams Notifications](#3-setup-teams-notifications)
4. [Setup Slack Notifications](#4-setup-slack-notifications)
5. [GitHub Secrets Configuration](#5-github-secrets-configuration)
6. [Test Local](#6-test-local)
7. [Deploy và Test CI/CD](#7-deploy-và-test-cicd)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. CHUẨN BỊ

### ✅ Checklist
- [ ] GitHub repository đã có code
- [ ] Git đã cài đặt
- [ ] Node.js 18+ đã cài đặt
- [ ] npm đã cài đặt
- [ ] VS Code hoặc editor khác
- [ ] Quyền admin repository (để config secrets)

### 📦 Install Dependencies
```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom

# Install tất cả dependencies
npm install

# Verify installation
npm list axios  # Phải có axios
```

---

## 2. SETUP EMAIL NOTIFICATIONS

### Bước 2.1: Tạo Gmail App Password

1. **Đăng nhập Gmail** của bạn
2. **Vào Google Account Settings**:
   - URL: https://myaccount.google.com/
3. **Bật 2-Step Verification** (nếu chưa có):
   - Security → 2-Step Verification → Get Started
   - Follow hướng dẫn để enable
4. **Tạo App Password**:
   - Security → 2-Step Verification → App passwords
   - Select app: "Mail"
   - Select device: "Other (Custom name)"
   - Nhập tên: "E2E Test Automation"
   - Click **Generate**
   - **LƯU LẠI** password 16 ký tự (format: `xxxx xxxx xxxx xxxx`)

### Bước 2.2: Lưu Email Credentials

```bash
# KHÔNG CHẠY lệnh này! Chỉ để tham khảo
# Bạn sẽ lưu vào GitHub Secrets ở bước 5
```

**Thông tin cần lưu:**
- Email username: `your-email@gmail.com`
- Email password: `app password 16 ký tự` (không có khoảng trắng)

---

## 3. SETUP TEAMS NOTIFICATIONS

### Bước 3.1: Tạo Power Automate Workflow

1. **Vào Power Automate**:
   - URL: https://make.powerautomate.com/
   - Đăng nhập với tài khoản Microsoft/Office 365

2. **Create New Flow**:
   - Click **"Create"** (menu bên trái)
   - Chọn **"Instant cloud flow"**
   - Tên flow: `E2E Test Notifications`
   - Trigger: **"When a HTTP request is received"**
   - Click **"Create"**

3. **Config HTTP Trigger**:
   - Ở step "When a HTTP request is received"
   - Click **"Use sample payload to generate schema"**
   - Paste JSON này:

```json
{
  "type": "message",
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "content": {
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "type": "AdaptiveCard",
        "version": "1.4",
        "body": [
          {
            "type": "TextBlock",
            "text": "E2E Test Automation",
            "size": "Large",
            "weight": "Bolder"
          },
          {
            "type": "TextBlock",
            "text": "Test message",
            "wrap": true
          }
        ]
      }
    }
  ]
}
```

   - Click **"Done"**

4. **Add Teams Action**:
   - Click **"+ New step"**
   - Search: **"Teams"**
   - Chọn: **"Post adaptive card in a chat or channel"**
   - Config:
     - **Post as**: Flow bot
     - **Post in**: Channel
     - **Team**: Chọn team của bạn
     - **Channel**: Chọn channel nhận thông báo
     - **Adaptive Card**: Click vào ô → chọn dynamic content → Expression
     - Paste: `triggerOutputs()?['body']?['attachments']?[0]?['content']`

5. **Save Flow**:
   - Click **"Save"** (góc trên bên phải)
   - Quay lại step "When a HTTP request is received"
   - **COPY Webhook URL** (nút copy bên cạnh URL)
   - **LƯU LẠI** URL này

### Bước 3.2: Lưu Teams Webhook URL

```bash
# KHÔNG CHẠY lệnh này! Chỉ để tham khảo
# URL format: https://prod-XX.eastus.logic.azure.com:443/workflows/GUID/triggers/manual/paths/invoke?...
```

**Lưu ý**: URL rất dài, copy toàn bộ!

---

## 4. SETUP SLACK NOTIFICATIONS

### Bước 4.1: Tạo Slack App

1. **Vào Slack API**:
   - URL: https://api.slack.com/apps
   - Click **"Create New App"**

2. **Chọn "From scratch"**:
   - App Name: `E2E Test Notifications`
   - Workspace: Chọn workspace của bạn
   - Click **"Create App"**

3. **Enable Incoming Webhooks**:
   - Ở menu bên trái, click **"Incoming Webhooks"**
   - Toggle **"Activate Incoming Webhooks"** → ON
   - Scroll xuống, click **"Add New Webhook to Workspace"**
   - Chọn **channel** nhận thông báo (ví dụ: #testing, #qa, #automation)
   - Click **"Allow"**

4. **Copy Webhook URL**:
   - Webhook URL sẽ hiển thị (format: `https://hooks.slack.com/services/T.../B.../...`)
   - Click **"Copy"** button
   - **LƯU LẠI** URL này

### Bước 4.2: Lưu Slack Webhook URL

```bash
# KHÔNG CHẠY lệnh này! Chỉ để tham khảo
# URL format: https://hooks.slack.com/services/WORKSPACE_ID/CHANNEL_ID/SECRET_TOKEN
# Replace WORKSPACE_ID, CHANNEL_ID, and SECRET_TOKEN with your actual values
```

---

## 5. GITHUB SECRETS CONFIGURATION

### Bước 5.1: Vào Repository Settings

1. **Mở repository trên GitHub**:
   - URL: `https://github.com/YOUR-USERNAME/YOUR-REPO`

2. **Vào Settings**:
   - Click tab **"Settings"** (góc trên bên phải)
   - ⚠️ Nếu không thấy Settings → bạn không có quyền admin

3. **Vào Secrets**:
   - Menu bên trái → **"Secrets and variables"**
   - Click **"Actions"**

### Bước 5.2: Thêm Secrets

Click **"New repository secret"** và thêm **TỪNG SECRET SAU**:

#### Secret 1: EMAIL_USERNAME
```
Name: EMAIL_USERNAME
Value: your-email@gmail.com

→ Click "Add secret"
```

#### Secret 2: EMAIL_PASSWORD
```
Name: EMAIL_PASSWORD
Value: your-16-digit-app-password (không có khoảng trắng)

→ Click "Add secret"
```

#### Secret 3: TEAMS_WEBHOOK_URL
```
Name: TEAMS_WEBHOOK_URL
Value: https://prod-XX.eastus.logic.azure.com:443/workflows/.../invoke?...
(paste toàn bộ URL từ Power Automate)

→ Click "Add secret"
```

#### Secret 4: SLACK_WEBHOOK_URL
```
Name: SLACK_WEBHOOK_URL
Value: https://hooks.slack.com/services/T.../B.../...
(paste toàn bộ URL từ Slack)

→ Click "Add secret"
```

### Bước 5.3: Verify Secrets

Sau khi thêm xong, bạn sẽ thấy 4 secrets:
- ✅ EMAIL_USERNAME
- ✅ EMAIL_PASSWORD
- ✅ TEAMS_WEBHOOK_URL
- ✅ SLACK_WEBHOOK_URL

**Lưu ý**: Bạn không thể xem lại value của secrets sau khi tạo!

---

## 6. TEST LOCAL

### Bước 6.1: Create .env File (Optional)

```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom

# Tạo file .env (cho local testing)
cat > .env << 'EOF'
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
TEAMS_WEBHOOK_URL=https://prod-XX.eastus.logic.azure.com/workflows/YOUR/WEBHOOK/URL
EOF

# Kiểm tra .env không bị track bởi git
git status  # .env KHÔNG được xuất hiện
```

### Bước 6.2: Test Slack Notification

```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom

# Load .env
export $(cat .env | xargs)

# Test send message
npm run slack:cli "🧪 Test from local - Hello Slack!"

# Expected output:
# ✅ Slack notification sent successfully!
```

**Kiểm tra**: Mở Slack channel → phải thấy message!

### Bước 6.3: Test Teams Notification

```bash
cd /Users/nam.nguyenduc/e2e-playwright/automationexercise-e2e-pom

# Load .env (nếu chưa load)
export $(cat .env | xargs)

# Test send message
npm run teams:notify "🧪 Test from local - Hello Teams!"

# Expected output:
# ✅ Teams notification sent successfully!
```

**Kiểm tra**: Mở Teams channel → phải thấy adaptive card!

### Bước 6.4: Test Email (Optional)

```bash
# Email khó test local vì cần SMTP
# Tốt nhất test qua GitHub Actions
```

---

## 7. DEPLOY VÀ TEST CI/CD

### Bước 7.1: Commit Changes

```bash
cd /Users/nam.nguyenduc/e2e-playwright

# Check files đã thay đổi
git status

# Stage tất cả files NGOẠI TRỪ .env
git add .

# QUAN TRỌNG: Verify .env không được add
git status | grep .env  # Phải KHÔNG có output

# Commit
git commit -m "Add complete notification system (Teams, Slack, Email)"

# Push
git push origin feat/notifications-clean
```

### Bước 7.2: Trigger Workflow Manually

1. **Vào GitHub Actions**:
   - Repository → tab **"Actions"**

2. **Chọn Workflow**:
   - Click **"E2E Test Automation"** (bên trái)

3. **Run Workflow**:
   - Click button **"Run workflow"** (bên phải)
   - Điền parameters:
     - Environment: `test`
     - Test Scope: `smoke`
     - Workers: `3`
     - Email Recipients: `your-email@gmail.com` (nếu muốn test email)
   - Click **"Run workflow"** (màu xanh)

### Bước 7.3: Monitor Workflow

1. **Xem workflow đang chạy**:
   - Click vào workflow run vừa tạo
   - Theo dõi các steps

2. **Check notification steps**:
   - Scroll xuống tìm steps:
     - ✅ Send Teams Notification
     - ✅ Send Slack Notification
     - ✅ Send Email (nếu có email_recipients)

3. **Verify logs**:
   - Click vào từng step để xem logs
   - Tìm messages:
     - `✅ Teams notification sent successfully!`
     - `✅ Slack notification sent successfully!`

### Bước 7.4: Verify Notifications

**Check Teams**:
- Mở Teams channel
- Phải thấy adaptive card với test results
- Card có: Status, Metrics, Pipeline link

**Check Slack**:
- Mở Slack channel
- Phải thấy rich message với test results
- Message có: Status, Metrics, Pipeline link

**Check Email** (nếu có):
- Mở email inbox
- Phải thấy email với subject: "E2E Test Report - test Environment - Run #XXX"
- Email có HTML report đẹp với charts và metrics

---

## 8. TROUBLESHOOTING

### ❌ Issue: Teams Notification Failed

**Triệu chứng**:
```
❌ Failed to send Teams notification
HTTP Code: 400 hoặc 404
```

**Giải pháp**:
1. Verify webhook URL đúng format
2. Check Power Automate flow đang "On" (không bị tắt)
3. Test lại với script:
```bash
export TEAMS_WEBHOOK_URL="your-url"
npm run teams:notify "Test message"
```

### ❌ Issue: Slack Notification Failed

**Triệu chứng**:
```
❌ Failed to send Slack notification
HTTP Code: 404
```

**Giải pháp**:
1. Verify webhook URL đúng (bắt đầu bằng `https://hooks.slack.com/services/`)
2. Check Slack app chưa bị xóa/revoke
3. Verify bot đã được add vào channel
4. Test lại:
```bash
export SLACK_WEBHOOK_URL="your-url"
npm run slack:cli "Test"
```

### ❌ Issue: Email Failed

**Triệu chứng**:
```
Error: Invalid login
```

**Giải pháp**:
1. Verify email và app password đúng
2. Ensure 2-Step Verification đã enable
3. Tạo lại App Password
4. Update lại GitHub Secret `EMAIL_PASSWORD`

### ❌ Issue: Secrets Not Found

**Triệu chứng**:
```
TEAMS_WEBHOOK_URL environment variable is not set
```

**Giải pháp**:
1. Check secrets đã tạo đúng tên (phân biệt hoa thường)
2. Verify repository có quyền access secrets
3. Re-run workflow (secrets cần vài phút để apply)

### ❌ Issue: Workflow Not Triggered

**Giải pháp**:
1. Check workflow file syntax (phải valid YAML)
2. Verify file nằm ở `.github/workflows/e2e-automation.yml`
3. Check GitHub Actions enabled cho repo
4. Push lại changes

---

## 9. VERIFICATION CHECKLIST

Sau khi setup xong, verify toàn bộ:

### ✅ Local Testing
- [ ] Slack notification works locally
- [ ] Teams notification works locally
- [ ] Dependencies installed (axios, etc.)
- [ ] .env file created (optional)
- [ ] .env in .gitignore

### ✅ GitHub Configuration
- [ ] All 4 secrets created correctly
- [ ] Secrets không có typo
- [ ] Repository settings accessible

### ✅ CI/CD Testing
- [ ] Workflow runs successfully
- [ ] Tests execute (pass or fail ok)
- [ ] Reports generated
- [ ] Teams notification received
- [ ] Slack notification received
- [ ] Email received (if configured)

### ✅ Notifications Quality
- [ ] Teams card có đầy đủ thông tin
- [ ] Slack message format đẹp
- [ ] Email HTML template hiển thị đúng
- [ ] All metrics displayed correctly
- [ ] Pipeline links work

---

## 10. QUICK REFERENCE

### Environment Variables
```bash
# Slack
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."

# Teams  
export TEAMS_WEBHOOK_URL="https://prod-XX.eastus.logic.azure.com/..."
```

### Test Commands
```bash
# Slack
npm run slack:cli "Test message"
npm run slack:report  # Send metrics

# Teams
npm run teams:notify "Test message"

# View help
cat documents/SLACK-INTEGRATION-GUIDE-VI.md
cat SLACK-QUICK-START.md
```

### GitHub Secrets Names (Exact)
- `EMAIL_USERNAME`
- `EMAIL_PASSWORD`
- `TEAMS_WEBHOOK_URL`
- `SLACK_WEBHOOK_URL`

---

## 📚 ADDITIONAL RESOURCES

### Documentation Files
- `SLACK-INTEGRATION-GUIDE-VI.md` - Slack setup (Vietnamese)
- `TEAMS-NOTIFICATION-FIX.md` - Teams setup details
- `SLACK-QUICK-START.md` - Quick commands
- `helper/slack-helper.example.ts` - Code examples

### Support
- Slack API: https://api.slack.com/docs
- Teams Webhooks: https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/
- Power Automate: https://make.powerautomate.com/
- Gmail App Passwords: https://support.google.com/accounts/answer/185833

---

## ✅ HOÀN THÀNH!

Nếu bạn đã làm theo tất cả các bước:
- ✅ Email notifications hoạt động
- ✅ Teams notifications hoạt động  
- ✅ Slack notifications hoạt động
- ✅ CI/CD workflow runs successfully
- ✅ All reports generated correctly

**Chúc mừng! Hệ thống của bạn đã sẵn sàng! 🎉**

---

**Ngày tạo**: 17/10/2025  
**Version**: 1.0  
**Tác giả**: GitHub Copilot
