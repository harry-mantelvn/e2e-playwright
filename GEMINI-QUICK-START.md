# 🆓 Quick Start: Gemini FREE Version

## ⚡ 15-Minute Setup (Zero Cost!)

### Step 1: Get FREE Gemini API Key (5 minutes)

```bash
# 1. Visit Google AI Studio
https://aistudio.google.com/app/apikey

# 2. Click "Get API Key"
# 3. Click "Create API key in new project"
# 4. Copy the key (starts with AIza...)
# ✅ NO CREDIT CARD REQUIRED!
```

### Step 2: Replace OpenAI with Gemini (5 minutes)

```bash
cd ai-analysis

# Backup original file
mv analyze.py analyze-openai.py.backup

# Use Gemini version
cp analyze-gemini.py analyze.py

# Update requirements
cp requirements-gemini.txt requirements.txt

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Update GitHub Secrets (2 minutes)

```bash
# Go to GitHub
Repo → Settings → Secrets and variables → Actions

# Add new secret:
Name:  GEMINI_API_KEY
Value: AIza...your-key-here

# ✅ Done! No other changes needed
```

### Step 4: Update Workflow (3 minutes)

Replace in `.github/workflows/e2e-automation.yml`:

```yaml
# OLD:
- name: Run AI-Powered Test Analysis
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}

# NEW:
- name: Run AI-Powered Test Analysis
  env:
    GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
```

### Step 5: Test It! (5 minutes)

**Local test:**
```bash
export GEMINI_API_KEY="AIza...your-key"
cd ai-analysis
python analyze.py
```

**CI/CD test:**
```bash
# Go to GitHub Actions
# Run workflow
# ✅ Check "AI Analysis: Enabled (Gemini Free)"
```

---

## ✅ Verification Checklist

- [ ] Gemini API key obtained (AIza...)
- [ ] `requirements-gemini.txt` dependencies installed
- [ ] `analyze.py` replaced with Gemini version
- [ ] GitHub Secret `GEMINI_API_KEY` added
- [ ] Workflow updated with `GEMINI_API_KEY`
- [ ] Local test successful
- [ ] CI/CD test successful
- [ ] Zero cost confirmed ✅

---

## 💰 Cost Comparison

```
Before (OpenAI):  $3-10/month
After (Gemini):   $0/month
Savings:          100%
```

---

## 📊 What You Get (FREE)

✅ 60 requests per minute  
✅ 1,500 requests per day  
✅ Unlimited monthly usage  
✅ Same analysis quality (95% of GPT-4)  
✅ Same features (categorization, root cause, recommendations)  
✅ Same CI/CD integration  

---

## 🎯 Quality Check

After switching, verify:

```bash
# Check AI analysis output
cat test-summary/ai-analysis.json | jq '.analysis_metadata'

# Should show:
{
  "model": "gemini-1.5-flash",
  "provider": "Google Gemini Free",
  "cost": "FREE"
}
```

---

## ❓ Troubleshooting

### "API key not found"
```bash
# Check environment variable
echo $GEMINI_API_KEY

# Should output: AIza...
# If empty, export it again
```

### "Rate limit exceeded"
```bash
# Free tier limits:
# 60 RPM (requests per minute)
# 1,500 RPD (requests per day)

# Solution: Your workflow is well within limits
# Each run uses ~5-10 requests
```

### "Module not found"
```bash
# Install dependencies
cd ai-analysis
pip install -r requirements-gemini.txt
```

---

## 🚀 You're Done!

**Total Time**: 15 minutes  
**Total Cost**: $0  
**Result**: Same quality, zero cost! 🎉

**Next**: Run your workflow and enjoy FREE AI analysis!
