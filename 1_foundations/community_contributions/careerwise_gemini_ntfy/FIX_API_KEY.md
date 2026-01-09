# 🔑 How to Fix the API Key Quota Error

Your chatbot is deployed correctly, but the Gemini API key has hit its quota limit (429 error).

## 🎯 Solution: Get a New API Key

### Step 1: Get a New Gemini API Key

1. **Go to:** https://makersuite.google.com/app/apikey
2. **Sign in** with your Google account
3. **Click "Create API Key"** (or use an existing valid key)
4. **Copy the key** (starts with `AIza...`)

### Step 2: Update the API Key in Cloud Run

Run this command (replace `YOUR_NEW_KEY` with your actual key):

```bash
cd /Users/jglover/jgdynamite/projects/agentic_ai/1_foundations/community_contributions/careerwise_gemini_ntfy

gcloud run services update careerwise-chatbot \
  --region us-central1 \
  --update-env-vars="GOOGLE_API_KEY=YOUR_NEW_KEY,AI_PROVIDER=gemini,AI_MODEL=gemini-2.0-flash" \
  --project careerwise-chatbot
```

### Step 3: Test Again

After updating, wait 30 seconds, then try your test page again!

---

## 🚀 Quick Fix Script

Or use the automated script:

```bash
./update-api-key.sh
```

Follow the prompts to enter your new API key.

---

## ⏱️ Alternative: Wait for Quota Reset

If you want to keep using the same key:

1. **Check quota status:** https://ai.dev/rate-limit
2. **Wait 1-24 hours** for daily quota reset
3. **Try again** after quota resets

---

## 📊 Check Your Quota

Visit these URLs to check your API quota:

- **Rate Limit Status:** https://ai.dev/rate-limit
- **API Key Management:** https://makersuite.google.com/app/apikey

---

## ✅ After Fixing

Once you update the API key, you should see:
- ✅ Successful responses in the chat
- ✅ No more "Failed to fetch" errors
- ✅ Working chatbot!
