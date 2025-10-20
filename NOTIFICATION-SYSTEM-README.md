# 📱 NOTIFICATION SYSTEM - QUICK GUIDE

## 🎯 MỤC ĐÍCH
Hệ thống gửi thông báo tự động khi chạy E2E tests qua:
- ✅ Email (Gmail)
- ✅ Microsoft Teams
- ✅ Slack

---

## 🚀 BẮT ĐẦU NHANH

### Chọn hướng dẫn phù hợp với bạn:

#### 📘 Hướng dẫn chi tiết (Khuyến nghị cho lần đầu)
```bash
cat SETUP-GUIDE-STEP-BY-STEP.md
```
**Thời gian**: ~60-75 phút  
**Nội dung**: Hướng dẫn từng bước chi tiết với screenshots reference

#### ✅ Checklist in ra (Để theo dõi tiến độ)
```bash
cat SETUP-CHECKLIST.md
```
**Thời gian**: ~60-75 phút  
**Nội dung**: Checklist để đánh dấu từng bước đã làm

#### ⚡ Quick Start (Cho người đã biết)
```bash
cat SLACK-QUICK-START.md
```
**Thời gian**: ~15 phút  
**Nội dung**: Commands nhanh, không giải thích chi tiết

---

## 📋 PREREQUISITES

Trước khi bắt đầu, đảm bảo bạn có:
- [ ] Quyền admin GitHub repository
- [ ] Gmail account với 2-Step Verification
- [ ] Microsoft Teams hoặc Office 365 account
- [ ] Slack workspace admin access
- [ ] Node.js 18+ installed
- [ ] Git installed

---

## 🔑 SECRETS CẦN TẠO

Bạn sẽ cần tạo 4 GitHub Secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `EMAIL_USERNAME` | Gmail address | `your-email@gmail.com` |
| `EMAIL_PASSWORD` | Gmail App Password | `abcdefghijklmnop` (16 chars) |
| `TEAMS_WEBHOOK_URL` | Power Automate webhook | `https://prod-XX.eastus.logic...` |
| `SLACK_WEBHOOK_URL` | Slack Incoming Webhook | `https://hooks.slack.com/services/...` |

---

## 📚 TÀI LIỆU HƯỚNG DẪN

### Setup Guides
1. **SETUP-GUIDE-STEP-BY-STEP.md** 📘
   - Hướng dẫn đầy đủ nhất
   - Step-by-step với giải thích
   - Troubleshooting guide
   - **→ BẮT ĐẦU TẠI ĐÂY NẾU LẦN ĐẦU**

2. **SETUP-CHECKLIST.md** ✅
   - Checklist để in ra
   - Track progress từng bước
   - Phần ghi chú để lưu thông tin
   - **→ DÙNG ĐỂ THEO DÕI TIẾN ĐỘ**

### Technical Guides
3. **SLACK-INTEGRATION-GUIDE-VI.md** 🇻🇳
   - Chi tiết về Slack integration
   - Best practices
   - Code examples
   - Tiếng Việt

4. **TEAMS-NOTIFICATION-FIX.md** 🔧
   - Teams adaptive card format
   - Power Automate setup
   - Troubleshooting Teams issues

### Quick References
5. **SLACK-QUICK-START.md** ⚡
   - Quick commands
   - Fast setup (nếu đã biết)
   - CLI usage

6. **TEAMS-QUICK-COMMANDS.md** ⚡
   - Teams commands
   - Testing tips

7. **SLACK-SETUP-SUMMARY.md** 📝
   - Complete summary
   - Files structure
   - Features list

---

## 🛠️ FILES STRUCTURE

```
e2e-playwright/
├── .github/workflows/
│   └── e2e-automation.yml          # CI/CD workflow (đã tích hợp)
│
├── automationexercise-e2e-pom/
│   ├── helper/
│   │   ├── slack-helper.ts         # Slack TypeScript helper
│   │   └── slack-helper.example.ts # Usage examples
│   │
│   ├── scripts/
│   │   ├── send-teams-notification.sh    # Teams bash script
│   │   ├── send-slack-notification.sh    # Slack bash script
│   │   └── test-*-integration.sh         # Test scripts
│   │
│   ├── documents/
│   │   ├── SLACK-INTEGRATION-GUIDE-VI.md # Slack guide (Vietnamese)
│   │   └── TEAMS-NOTIFICATION-FIX.md     # Teams guide
│   │
│   └── package.json                # NPM scripts configured
│
└── Documentation/ (root)
    ├── SETUP-GUIDE-STEP-BY-STEP.md  # 📘 START HERE
    ├── SETUP-CHECKLIST.md            # ✅ Use this to track
    ├── SLACK-QUICK-START.md          # ⚡ Quick reference
    ├── TEAMS-QUICK-COMMANDS.md       # ⚡ Teams commands
    ├── SLACK-SETUP-SUMMARY.md        # 📝 Complete summary
    └── NOTIFICATION-SYSTEM-README.md # 📱 This file
```

---

## ⏱️ SETUP TIMELINE

| Phase | Task | Time | Difficulty |
|-------|------|------|------------|
| 1 | Chuẩn bị | 5 min | ⭐ Easy |
| 2 | Email setup | 10 min | ⭐ Easy |
| 3 | Teams setup | 15 min | ⭐⭐ Medium |
| 4 | Slack setup | 10 min | ⭐ Easy |
| 5 | GitHub Secrets | 5 min | ⭐ Easy |
| 6 | Test Local | 10 min | ⭐ Easy |
| 7 | Deploy | 5 min | ⭐ Easy |
| 8 | Test CI/CD | 15 min | ⭐⭐ Medium |
| **TOTAL** | | **~75 min** | |

---

## 🧪 TESTING COMMANDS

### Local Testing
```bash
cd automationexercise-e2e-pom

# Slack
export SLACK_WEBHOOK_URL="your-url"
npm run slack:cli "Test message"

# Teams
export TEAMS_WEBHOOK_URL="your-url"
npm run teams:notify "Test message"
```

### CI/CD Testing
1. GitHub → Actions → E2E Test Automation
2. Run workflow → Fill parameters
3. Monitor execution
4. Check notifications in Teams/Slack/Email

---

## ✅ VERIFICATION CHECKLIST

Sau khi setup xong:

### Local Tests
- [ ] Dependencies installed (`npm list axios`)
- [ ] Slack notification works locally
- [ ] Teams notification works locally
- [ ] `.env` created (optional)
- [ ] `.env` in `.gitignore`

### GitHub Configuration
- [ ] 4 secrets created
- [ ] Secrets names correct (case-sensitive)
- [ ] No typos in secret values

### CI/CD Tests
- [ ] Workflow runs successfully
- [ ] Tests execute
- [ ] Reports generated
- [ ] Teams notification received
- [ ] Slack notification received
- [ ] Email received
- [ ] All metrics display correctly
- [ ] Pipeline links work

---

## 🆘 TROUBLESHOOTING

### Issue: Notifications không gửi

**Email Failed**:
```bash
# Check:
1. App Password đúng? (16 chars, no spaces)
2. 2-Step Verification enabled?
3. Secrets name: EMAIL_USERNAME, EMAIL_PASSWORD
```

**Teams Failed**:
```bash
# Check:
1. Power Automate flow đang "On"?
2. Webhook URL complete? (rất dài)
3. Adaptive card schema correct?
```

**Slack Failed**:
```bash
# Check:
1. Webhook URL format: https://hooks.slack.com/services/...
2. App chưa bị revoke?
3. Bot added to channel?
```

### Xem hướng dẫn chi tiết:
```bash
cat SETUP-GUIDE-STEP-BY-STEP.md  # Section 8: Troubleshooting
```

---

## 🎯 SUCCESS METRICS

Hệ thống hoạt động tốt khi:
- ✅ GitHub Actions workflow runs green
- ✅ Tests execute (pass/fail là bình thường)
- ✅ Teams nhận adaptive card đẹp với metrics
- ✅ Slack nhận rich message với metrics
- ✅ Email nhận HTML report professional
- ✅ Tất cả links trong notifications work
- ✅ Metrics hiển thị chính xác (pass rate, total tests, etc.)

---

## 📞 SUPPORT & RESOURCES

### Internal Documentation
- Full setup: `SETUP-GUIDE-STEP-BY-STEP.md`
- Checklist: `SETUP-CHECKLIST.md`
- Slack guide: `documents/SLACK-INTEGRATION-GUIDE-VI.md`

### External Resources
- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)
- [Power Automate](https://make.powerautomate.com/)
- [Slack API](https://api.slack.com/apps)
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

## 🚀 NEXT STEPS

### Lần đầu setup:
1. ✅ **READ**: `SETUP-GUIDE-STEP-BY-STEP.md`
2. ✅ **PRINT**: `SETUP-CHECKLIST.md`
3. ✅ **FOLLOW**: Từng bước trong guide
4. ✅ **CHECK**: Mỗi item trong checklist
5. ✅ **TEST**: Local trước, CI/CD sau
6. ✅ **VERIFY**: All notifications received

### Đã setup rồi, muốn test:
```bash
# Quick test
cd automationexercise-e2e-pom
npm run slack:cli "Test!"
npm run teams:notify "Test!"

# Full workflow test
# → GitHub Actions → Run workflow
```

### Muốn customize:
- Code examples: `helper/slack-helper.example.ts`
- Bash scripts: `scripts/send-*-notification.sh`
- Workflow: `.github/workflows/e2e-automation.yml`

---

## 🎉 SUMMARY

**Bạn có**:
- ✅ TypeScript helper cho Slack
- ✅ Bash scripts cho Teams & Slack
- ✅ CI/CD integration sẵn sàng
- ✅ Documentation đầy đủ (Vietnamese & English)
- ✅ Examples và test scripts
- ✅ Professional email templates
- ✅ Rich formatted notifications

**Chỉ cần**:
1. Setup 3 services (Email, Teams, Slack)
2. Add 4 GitHub Secrets
3. Test và verify

**Thời gian**: ~60-75 phút lần đầu, sau đó automated 100%!

---

## 📅 CHANGELOG

- **2025-10-17**: Initial release
  - Complete notification system
  - Email, Teams, Slack integration
  - Full documentation (Vietnamese)
  - CI/CD ready

---

**🎯 START HERE → `SETUP-GUIDE-STEP-BY-STEP.md`**

**Questions? Check Troubleshooting section in setup guide!**

---

**Created**: 17/10/2025  
**Version**: 1.0  
**Status**: ✅ Production Ready
