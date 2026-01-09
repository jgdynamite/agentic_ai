# 🚀 Getting Started with CareerWise

Welcome! This guide will help you get CareerWise up and running from scratch.

---

## 📋 Step 0: Choose Your Path

**Option A: Quick Local Test (15 minutes)**
- Test the chatbot locally with a local AI model or Gemini
- Perfect for understanding how it works

**Option B: Full Deployment (1-2 hours)**
- Deploy to cloud platforms (GCP, AWS, Akamai)
- Production-ready setup

**Start with Option A** to get familiar, then move to Option B.

---

## 🎯 Option A: Quick Local Test

### Step 1: Prerequisites (5 min)

Install these if you don't have them:

```bash
# Check what you have
python3 --version  # Need 3.10+
docker --version   # Optional for now
git --version      # Should have this

# Install Python dependencies
pip install -r requirements.txt
```

### Step 2: Choose Your AI Provider (2 min)

**Easiest: Google Gemini (Free)**
```bash
# Get API key from: https://makersuite.google.com/app/apikey
export AI_PROVIDER=gemini
export GOOGLE_API_KEY=your-api-key-here
```

**OR: Local Model with Ollama (100% Free, Private)**
```bash
# Install Ollama: https://ollama.ai
# macOS: curl https://ollama.ai/install.sh | sh
# Then:
ollama pull llama3.2
ollama serve  # Keep this running in a terminal

# In another terminal:
export AI_PROVIDER=local
export LOCAL_AI_BASE_URL=http://localhost:11434/v1
export AI_MODEL=llama3.2
```

See [AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md) for more options.

### Step 3: Set Up Your Personal Info (3 min)

Edit the files in `me/` folder:
- `me/summary.txt` - Add your personal summary
- `me/resume_for_Virtual_Assistant.pdf` - Add your resume PDF

Or keep the defaults for testing.

### Step 4: Run Locally (1 min)

```bash
# Make sure you're in the project directory
cd 1_foundations/community_contributions/careerwise_gemini_ntfy

# Run the API
python backend_api.py
```

You should see:
```
INFO:     Started server process
INFO:     Uvicorn running on http://0.0.0.0:8080
```

### Step 5: Test It (1 min)

Open another terminal and test:

```bash
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, tell me about yourself", "history": []}'
```

You should get a response! 🎉

### Step 6: Optional - Add Notifications (3 min)

1. Install ntfy app on your phone: https://ntfy.sh
2. Create a topic (e.g., `my-career-alerts-123`)
3. Subscribe to it in the app
4. Set environment variable:
   ```bash
   export NTFY_TOPIC=my-career-alerts-123
   ```
5. Restart the API - now you'll get notifications!

---

## ☁️ Option B: Deploy to Cloud

Once you've tested locally, deploy to production.

### Step 1: Choose Your Platform

**Recommended for beginners: Google Cloud Run**
- Easiest setup
- Free tier available
- Serverless (no servers to manage)

See [DEPLOYMENT_MASTER_GUIDE.md](DEPLOYMENT_MASTER_GUIDE.md) for full instructions.

### Step 2: Quick Cloud Run Deployment

```bash
# 1. Install gcloud CLI
# macOS: brew install --cask google-cloud-sdk
# Or: https://cloud.google.com/sdk/docs/install

# 2. Authenticate
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# 3. Build and deploy
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/careerwise-chatbot
gcloud run deploy careerwise-chatbot \
  --image gcr.io/YOUR_PROJECT_ID/careerwise-chatbot \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars="AI_PROVIDER=gemini,GOOGLE_API_KEY=your-key,NTFY_TOPIC=your-topic"
```

You'll get a URL like: `https://careerwise-chatbot-xxxxx.a.run.app`

---

## 📁 Project Structure

```
careerwise_gemini_ntfy/
├── backend_api.py          # Main API code (START HERE)
├── requirements.txt       # Python dependencies
├── Dockerfile             # For containerization
├── me/                    # Your personal info
│   ├── summary.txt
│   └── resume_for_Virtual_Assistant.pdf
├── GETTING_STARTED.md     # This file
├── AI_PROVIDER_GUIDE.md   # AI provider setup
├── README.md              # Project overview
└── DEPLOYMENT_MASTER_GUIDE.md  # Full deployment guide
```

---

## 🎓 Learning Path

1. **Day 1:** Get it running locally (Option A)
2. **Day 2:** Customize with your info
3. **Day 3:** Deploy to one cloud platform
4. **Day 4:** Add to your portfolio website
5. **Week 2:** Experiment with different AI models

---

## 🆘 Common Issues

### "Module not found"
```bash
pip install -r requirements.txt
```

### "GOOGLE_API_KEY not set"
```bash
export GOOGLE_API_KEY=your-key-here
# Or add to .env file
```

### "Port 8080 already in use"
```bash
# Change port in backend_api.py or kill the process using port 8080
lsof -ti:8080 | xargs kill  # macOS/Linux
```

### "Ollama connection refused"
- Make sure `ollama serve` is running
- Check the URL matches: `http://localhost:11434/v1`

---

## ✅ Next Steps

- ✅ Got it running locally? → Try different AI models
- ✅ Working with Gemini? → Try a local model for privacy
- ✅ Happy with local? → Deploy to cloud
- ✅ Deployed? → Integrate with your website

---

## 📚 Documentation Index

- **This file** - Getting started basics
- **[AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md)** - Switch between AI providers
- **[README.md](README.md)** - Project overview and features
- **[DEPLOYMENT_MASTER_GUIDE.md](DEPLOYMENT_MASTER_GUIDE.md)** - Full cloud deployment
- **[QUICK_START.md](QUICK_START.md)** - Fast deployment guide

---

## 💡 Tips

1. **Start simple:** Get Gemini working first, then experiment
2. **Test locally:** Always test locally before deploying
3. **Use .env files:** Keep secrets out of code
4. **Read logs:** Check console output for errors
5. **Ask questions:** Check the other guides for details

---

**Ready? Start with Step 1 above!** 🚀
