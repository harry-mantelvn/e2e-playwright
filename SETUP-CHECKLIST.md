# ✅ SETUP CHECKLIST - E2E Test Automation

## 📝 CHECKLIST TỔNG QUAN

### PHASE 1: CHUẨN BỊ ⏱️ 5 phút
- [ ] Clone repository về máy
- [ ] `cd automationexercise-e2e-pom`
- [ ] `npm install`
- [ ] Verify `npm list axios` có kết quả

---

### PHASE 2: EMAIL SETUP ⏱️ 10 phút

#### A. Tạo Gmail App Password
- [ ] Vào https://myaccount.google.com/
- [ ] Security → 2-Step Verification (enable nếu chưa có)
- [ ] App passwords → Create new
  - App: Mail
  - Device: Other → "E2E Test Automation"
- [ ] Copy password 16 ký tự → **LƯU LẠI**

#### B. Thông tin cần lưu
```
Email: _______________________@gmail.com
App Password: ____ ____ ____ ____ (16 ký tự)
```

---

### PHASE 3: TEAMS SETUP ⏱️ 15 phút

#### A. Tạo Power Automate Flow
- [ ] Vào https://make.powerautomate.com/
- [ ] Create → Instant cloud flow
  - Name: `E2E Test Notifications`
  - Trigger: "When a HTTP request is received"

#### B. Config Trigger
- [ ] Use sample payload → paste JSON (xem guide)
- [ ] Generate schema

#### C. Add Teams Action
- [ ] New step → Search "Teams"
- [ ] "Post adaptive card in a chat or channel"
- [ ] Config:
  - Post as: Flow bot
  - Team: Chọn team
  - Channel: Chọn channel
  - Adaptive Card: `triggerOutputs()?['body']?['attachments']?[0]?['content']`

#### D. Save và Copy URL
- [ ] Save flow
- [ ] Copy webhook URL → **LƯU LẠI**

#### E. Thông tin cần lưu
```
Webhook URL: https://prod-______________________
```

---

### PHASE 4: SLACK SETUP ⏱️ 10 phút

#### A. Tạo Slack App
- [ ] Vào https://api.slack.com/apps
- [ ] Create New App → From scratch
  - Name: `E2E Test Notifications`
  - Workspace: Chọn workspace

#### B. Enable Incoming Webhooks
- [ ] Incoming Webhooks → Toggle ON
- [ ] Add New Webhook to Workspace
- [ ] Chọn channel (vd: #testing)
- [ ] Allow

#### C. Copy Webhook URL
- [ ] Copy webhook URL → **LƯU LẠI**

#### D. Thông tin cần lưu
```
Webhook URL: https://hooks.slack.com/services/_______________
```

---

### PHASE 5: GITHUB SECRETS ⏱️ 5 phút

#### Vào Repository Settings
- [ ] GitHub repo → Settings tab
- [ ] Secrets and variables → Actions
- [ ] New repository secret (làm 4 lần)

#### Tạo 4 Secrets
1. [ ] **EMAIL_USERNAME**
   ```
   Value: your-email@gmail.com
   ```

2. [ ] **EMAIL_PASSWORD**
   ```
   Value: 16-digit-app-password (không khoảng trắng)
   ```

3. [ ] **TEAMS_WEBHOOK_URL**
   ```
   Value: https://prod-XX.eastus.logic.azure.com/workflows/.../invoke?...
   ```

4. [ ] **SLACK_WEBHOOK_URL**
   ```
   Value: https://hooks.slack.com/services/T.../B.../...
   ```

#### Verify
- [ ] 4 secrets hiển thị trong danh sách
- [ ] Tên secrets đúng (phân biệt hoa thường)

---

### PHASE 6: TEST LOCAL ⏱️ 10 phút (Optional)

#### Create .env File
- [ ] `cd automationexercise-e2e-pom`
- [ ] Create `.env` với 2 webhook URLs
- [ ] Verify `.env` không bị git track

#### Test Slack
- [ ] `export $(cat .env | xargs)`
- [ ] `npm run slack:cli "Test from local"`
- [ ] Check Slack channel → thấy message

#### Test Teams
- [ ] `npm run teams:notify "Test from local"`
- [ ] Check Teams channel → thấy card

---

### PHASE 7: DEPLOY ⏱️ 5 phút

#### Commit & Push
- [ ] `git add .`
- [ ] Verify `.env` KHÔNG được add
- [ ] `git commit -m "Add notification system"`
- [ ] `git push origin your-branch`

---

### PHASE 8: TEST CI/CD ⏱️ 15 phút

#### Run Workflow
- [ ] GitHub repo → Actions tab
- [ ] "E2E Test Automation" workflow
- [ ] "Run workflow" button
- [ ] Fill parameters:
  - Environment: `test`
  - Test Scope: `smoke`
  - Workers: `3`
  - Email: `your-email@gmail.com`
- [ ] Run workflow

#### Monitor
- [ ] Click vào workflow run
- [ ] Watch steps executing
- [ ] Check "Send Teams Notification" step
- [ ] Check "Send Slack Notification" step
- [ ] Check "Send Email" step (nếu có)

#### Verify Notifications
- [ ] Open Teams → thấy adaptive card
- [ ] Open Slack → thấy rich message
- [ ] Open Email → thấy HTML report
- [ ] All links work
- [ ] All metrics display correctly

---

## 🎯 SUCCESS CRITERIA

### ✅ Hoàn thành khi:
- [ ] Workflow runs without errors
- [ ] Tests execute (pass or fail là ok)
- [ ] Teams notification received
- [ ] Slack notification received
- [ ] Email received (if configured)
- [ ] All metrics show correctly
- [ ] Pipeline links work

---

## ⏱️ TỔNG THỜI GIAN: ~60-75 phút

**Breakdown**:
- Chuẩn bị: 5 phút
- Email setup: 10 phút
- Teams setup: 15 phút
- Slack setup: 10 phút
- GitHub secrets: 5 phút
- Test local: 10 phút
- Deploy: 5 phút
- Test CI/CD: 15 phút

---

## 📋 THÔNG TIN CẦN LƯU

| Item | Value | Status |
|------|-------|--------|
| Email Username | _________________ | ⬜ |
| Email App Password | _________________ | ⬜ |
| Teams Webhook URL | _________________ | ⬜ |
| Slack Webhook URL | _________________ | ⬜ |
| GitHub Secrets Created | 4/4 | ⬜ |
| Local Tests Passed | Yes/No | ⬜ |
| CI/CD Tests Passed | Yes/No | ⬜ |

---

## 🆘 NẾU GẶP LỖI

### Slack Failed
→ Xem section "Troubleshooting" trong `SETUP-GUIDE-STEP-BY-STEP.md`

### Teams Failed
→ Check Power Automate flow status: https://make.powerautomate.com/

### Email Failed
→ Verify App Password và 2-Step Verification

### Secrets Not Found
→ Re-check tên secrets (case-sensitive!)

---

## 📚 DOCUMENTATION

- 📘 **Full Guide**: `SETUP-GUIDE-STEP-BY-STEP.md`
- 🚀 **Quick Start**: `SLACK-QUICK-START.md`
- 📖 **Slack Guide**: `documents/SLACK-INTEGRATION-GUIDE-VI.md`
- 🔧 **Teams Fix**: `TEAMS-NOTIFICATION-FIX.md`

---

## ✅ COMPLETION

**Date completed**: ____ / ____ / ________

**Tested by**: _______________________

**Notes**: 
_____________________________________________
_____________________________________________
_____________________________________________

---

**Print this checklist và check từng bước! 🎯**
