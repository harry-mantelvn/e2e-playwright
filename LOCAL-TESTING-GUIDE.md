# 🔑 Setup GitHub Token cho Local Testing

## 🎯 Tại sao cần GitHub Token?

Để test **full AI analysis** với GitHub Copilot locally, bạn cần GitHub Personal Access Token.

**LƯU Ý**: Trong GitHub Actions, token tự động có sẵn, KHÔNG CẦN setup này!

---

## ⚡ Quick Setup (5 phút)

### Bước 1: Tạo GitHub Personal Access Token

1. **Mở**: https://github.com/settings/tokens

2. **Click**: "Generate new token" → "Generate new token (classic)"

3. **Điền thông tin**:
   ```
   Note: E2E AI Analysis Testing
   Expiration: 7 days (cho testing)
   ```

4. **Select scopes** (chỉ cần minimal):
   ```
   ✅ repo (Full control of private repositories)
   ✅ workflow (Update GitHub Action workflows)
   ```

5. **Click**: "Generate token"

6. **Copy token** (bắt đầu với `ghp_...`)
   ⚠️ **Quan trọng**: Copy ngay, không xem lại được!

### Bước 2: Set Token trong Terminal

```bash
# Export token (chỉ trong session hiện tại)
export GITHUB_TOKEN='ghp_your_token_here'

# Verify
echo $GITHUB_TOKEN
```

### Bước 3: Run Test

```bash
cd /Users/nam.nguyenduc/e2e-playwright/ai-analysis
./test-with-token.sh
```

---

## 🔐 Security Best Practices

### ✅ DO:
- Use token với minimal scopes
- Set expiration (7 days cho testing)
- Export trong terminal session only
- Revoke sau khi test xong

### ❌ DON'T:
- Commit token vào code
- Share token với người khác
- Use token với "no expiration"
- Save trong plaintext files

---

## 🧪 Test Script với Token

Tôi đã tạo script: `test-with-token.sh`

```bash
# Set token
export GITHUB_TOKEN='ghp_your_token_here'

# Run test
cd /Users/nam.nguyenduc/e2e-playwright/ai-analysis
./test-with-token.sh
```

**Output mong đợi**:
```
🤖 Starting AI Test Analysis with GitHub Copilot...
Environment: test
AI Backend: GitHub Models (Copilot)
Model: gpt-4o
📂 Loading report from: metrics.json
📊 Test Metrics:
   - Total: 25
   - Passed: 23
   - Failed: 2
   - Pass Rate: 92%
🔍 Analyzing test results with GitHub Models AI...
✅ Analysis saved to ai-analysis.json

📋 AI Analysis Summary:
   - Quality Status: Excellent
   - Risk Level: Low
   - Deployment Ready: true
   - Action Items: 3

✅ AI Analysis Complete!
```

---

## ⚠️ Alternative: Skip Local Testing

**Recommended**: Chỉ test trên GitHub Actions!

### Tại sao?

1. ✅ `GITHUB_TOKEN` tự động có sẵn
2. ✅ Không cần setup gì
3. ✅ Giống production environment
4. ✅ An toàn hơn (no token management)

### How to Test trên GitHub Actions:

```bash
# 1. Commit & push code
git add .
git commit -m "Add GitHub Copilot AI analysis"
git push

# 2. Go to GitHub Actions
# https://github.com/YOUR_ORG/e2e-playwright/actions

# 3. Run workflow manually
# Actions → E2E Test Automation → Run workflow

# 4. Xem results trong workflow summary
```

---

## 🆚 So Sánh Options

| Method | Setup Time | AI Quality | Security | Recommended |
|--------|------------|------------|----------|-------------|
| **GitHub Actions** | 0 min | Full AI | ✅ Secure | ⭐⭐⭐⭐⭐ |
| **Local + Token** | 5 min | Full AI | ⚠️ Manual | ⭐⭐⭐ |
| **Local No Token** | 0 min | Statistical | ✅ Secure | ⭐⭐ |

---

## 🚀 Recommended Flow

### For Testing:

```bash
# Option 1: Test trên GitHub Actions (BEST)
1. Push code to GitHub
2. Run workflow manually
3. Review AI insights in summary

# Option 2: Quick local test (no AI)
cd ai-analysis
./test-local-no-token.sh  # Statistical analysis only

# Option 3: Full local test (with token)
export GITHUB_TOKEN='your_token'
./test-with-token.sh      # Full AI analysis
```

---

## 📋 Troubleshooting

### "GITHUB_TOKEN not set"

**Giải pháp**:
```bash
# Check if token is set
echo $GITHUB_TOKEN

# If empty, export it
export GITHUB_TOKEN='ghp_your_token_here'

# Verify
echo $GITHUB_TOKEN | head -c 20
# Should show: ghp_xxxxxxxxxxxx
```

### "Invalid token"

**Giải pháp**:
```bash
# Check token format
echo $GITHUB_TOKEN | head -c 4
# Should show: ghp_

# Regenerate token với đúng scopes
```

### "API rate limit exceeded"

**Giải pháp**:
```bash
# Wait 1 hour or use different token
# Or just test on GitHub Actions (no rate limit)
```

---

## ✅ Summary

### Local Testing:

**KHÔNG CẦN token** nếu chỉ test statistical analysis:
```bash
cd ai-analysis
./test-local-no-token.sh
```

**CẦN token** cho full AI analysis:
```bash
export GITHUB_TOKEN='ghp_xxx'
./test-with-token.sh
```

### Production (GitHub Actions):

**KHÔNG CẦN setup gì!** Token tự động có sẵn:
```yaml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🎯 Next Step

**Recommendation**: Skip local testing, test trực tiếp trên GitHub Actions!

```bash
# 1. Commit code
git add .
git commit -m "feat: Add GitHub Copilot AI analysis"
git push

# 2. Go to Actions tab
# 3. Run workflow
# 4. ✅ Done!
```

Đơn giản, an toàn, và giống production! 🚀
