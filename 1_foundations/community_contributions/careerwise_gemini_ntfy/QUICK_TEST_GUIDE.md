# 🧪 Quick Test Guide for CareerWise

Your CareerWise chatbot is deployed and ready to test! Here are quick ways to test and visualize it.

---

## ✅ Your Deployment Status

**🌐 Live URL:** https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app

**📚 API Docs:** https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/docs

---

## 🔍 Step 1: Check API Quota Status

If you're getting rate limit errors, check your Gemini API quota:

1. **Visit:** https://ai.dev/rate-limit
2. **Or:** https://makersuite.google.com/app/apikey
3. **Check:** Your current usage and limits

**Note:** Free tier limits:
- 60 requests per minute
- 1,500 requests per day
- If exceeded, wait a few minutes and try again

---

## 🌐 Step 2: Test via API Documentation (Easiest)

### Open the Interactive API Docs:

1. **Open in browser:**
   ```
   https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/docs
   ```

2. **You'll see:** Interactive Swagger UI with all endpoints

3. **Test the chat endpoint:**
   - Click on `POST /chat`
   - Click "Try it out"
   - Enter a message: `"Hello, tell me about yourself"`
   - Click "Execute"
   - See the response below!

**This is the fastest way to test!**

---

## 💬 Step 3: Visual Chat Interface

I've created a beautiful test page for you!

### Option A: Open the HTML file

```bash
# In your terminal:
cd /Users/jglover/jgdynamite/projects/agentic_ai/1_foundations/community_contributions/careerwise_gemini_ntfy

# Open in default browser:
open test_chatbot.html

# Or double-click test_chatbot.html in Finder
```

### Option B: Serve locally (if needed)

```bash
# Simple Python server (if browser blocks local file)
python3 -m http.server 8000

# Then open: http://localhost:8000/test_chatbot.html
```

**What you'll see:**
- Beautiful chat interface
- Real-time typing indicators
- Message history
- Connection status
- Professional design

---

## 🖥️ Step 4: Test via Command Line

### Test with curl:

```bash
curl -X POST https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello, tell me about yourself",
    "history": []
  }'
```

**Expected response:**
```json
{
  "response": "Hello! I'm Mahesh Dindur, and I have experience in..."
}
```

### Test with different questions:

```bash
# Ask about skills
curl -X POST https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What are your technical skills?", "history": []}'

# Ask about experience
curl -X POST https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What projects have you worked on?", "history": []}'
```

---

## 🔑 Step 5: Update API Key (If Needed)

If you need to update your Gemini API key:

### Quick Update Script:

```bash
cd /Users/jglover/jgdynamite/projects/agentic_ai/1_foundations/community_contributions/careerwise_gemini_ntfy

./update-api-key.sh
```

### Manual Update:

```bash
# Update your .env file first
nano .env  # Edit GOOGLE_API_KEY

# Then update Cloud Run
gcloud run services update careerwise-chatbot \
  --region us-central1 \
  --update-env-vars="GOOGLE_API_KEY=your-new-key-here" \
  --project your-project-id
```

### Get a New API Key:

1. Go to: https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the new key
5. Update using the script above

---

## 📊 Step 6: Monitor Logs

### View real-time logs:

```bash
gcloud run services logs tail careerwise-chatbot \
  --region us-central1
```

### View recent logs:

```bash
gcloud run services logs read careerwise-chatbot \
  --region us-central1 \
  --limit 50
```

**Look for:**
- ✅ Successful requests
- ❌ Error messages
- ⚠️ Rate limit warnings

---

## 🐛 Troubleshooting

### Issue: "429 Rate Limit Exceeded"

**Solution:**
- Wait 1-5 minutes for quota to reset
- Check quota at: https://ai.dev/rate-limit
- Get a new API key if needed
- Use the update script: `./update-api-key.sh`

### Issue: "Internal Server Error"

**Solution:**
1. Check logs: `gcloud run services logs read careerwise-chatbot --region us-central1 --limit 20`
2. Verify API key is set correctly
3. Check that environment variables are set

### Issue: "API key not valid"

**Solution:**
1. Verify your API key at: https://makersuite.google.com/app/apikey
2. Make sure you copied the full key
3. Update using the script: `./update-api-key.sh`

### Issue: HTML test page doesn't work

**Solution:**
- Check browser console for errors (F12)
- Verify the API URL is correct in the HTML file
- Make sure API is accessible: test `/docs` endpoint first

---

## ✅ Success Checklist

- [ ] API docs page loads: https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/docs
- [ ] Can see Swagger UI interface
- [ ] Test endpoint works (via docs or curl)
- [ ] HTML test page opens and connects
- [ ] Can send messages and receive responses
- [ ] No rate limit errors
- [ ] Logs show successful requests

---

## 🎯 Next Steps

Once testing is successful:

1. **Embed in your portfolio** - Use the widget code
2. **Customize responses** - Update `me/` folder content
3. **Monitor usage** - Check logs and costs regularly
4. **Share it** - Show off your AI chatbot!

---

## 🔗 Quick Links

- **API Docs:** https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/docs
- **Gemini API Keys:** https://makersuite.google.com/app/apikey
- **Quota Status:** https://ai.dev/rate-limit
- **GCP Console:** https://console.cloud.google.com/run

---

**Your CareerWise chatbot is live and ready to use! 🚀**
