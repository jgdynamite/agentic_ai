# 🎯 START HERE

**Welcome to CareerWise!** This is your roadmap to getting started.

---

## 🚀 Quick Navigation

### I'm New - Where Do I Start?
👉 **[GETTING_STARTED.md](GETTING_STARTED.md)** - Complete beginner-friendly guide

### I Want to Use a Different AI Model
👉 **[AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md)** - Switch between Gemini, local models, or Akamai

### I Want to Deploy to the Cloud
👉 **[DEPLOYMENT_MASTER_GUIDE.md](DEPLOYMENT_MASTER_GUIDE.md)** - Full deployment instructions

### I Want to Set Up a GitHub Repo
👉 **[GITHUB_REPO_SETUP.md](GITHUB_REPO_SETUP.md)** - Organize and publish your project

---

## ⚡ 5-Minute Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Set up environment
cp .env.example .env
# Edit .env with your Gemini API key (get from https://makersuite.google.com/app/apikey)

# 3. Run locally
python backend_api.py

# 4. Test it
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'
```

**That's it!** You're running CareerWise locally. 🎉

---

## 📚 Documentation Map

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[GETTING_STARTED.md](GETTING_STARTED.md)** | Beginner guide | Start here if new |
| **[AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md)** | AI provider setup | When switching AI models |
| **[README.md](README.md)** | Project overview | Understand what this is |
| **[DEPLOYMENT_MASTER_GUIDE.md](DEPLOYMENT_MASTER_GUIDE.md)** | Cloud deployment | When ready to deploy |
| **[GITHUB_REPO_SETUP.md](GITHUB_REPO_SETUP.md)** | GitHub setup | When publishing to GitHub |
| **[QUICK_START.md](QUICK_START.md)** | Fast deployment | Quick cloud setup |

---

## 🎓 Learning Path

### Day 1: Get It Running
1. Read [GETTING_STARTED.md](GETTING_STARTED.md)
2. Run locally with Gemini
3. Test the API endpoint

### Day 2: Customize
1. Update `me/summary.txt` with your info
2. Add your resume to `me/` folder
3. Change the name in `backend_api.py` (line 233)

### Day 3: Try Different AI
1. Read [AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md)
2. Try Ollama with a local model
3. Compare responses

### Day 4: Deploy
1. Read [DEPLOYMENT_MASTER_GUIDE.md](DEPLOYMENT_MASTER_GUIDE.md)
2. Deploy to Google Cloud Run (easiest)
3. Get your public URL

### Week 2: Polish
1. Set up GitHub repo ([GITHUB_REPO_SETUP.md](GITHUB_REPO_SETUP.md))
2. Add to your portfolio
3. Share and get feedback

---

## 🆘 Need Help?

1. **Check the guides above** - Most questions are answered there
2. **Read error messages** - They usually tell you what's wrong
3. **Check logs** - Console output shows what's happening
4. **Verify environment variables** - Make sure `.env` is set up correctly

---

## ✅ Pre-Flight Checklist

Before you start, make sure you have:

- [ ] Python 3.10+ installed
- [ ] `pip` working
- [ ] Internet connection (for Gemini API)
- [ ] Text editor ready
- [ ] Terminal/command line access

**Optional but helpful:**
- [ ] Docker installed (for containerization)
- [ ] Git installed (for version control)
- [ ] A GitHub account (for publishing)

---

## 🎯 What's Next?

1. **Right now:** Open [GETTING_STARTED.md](GETTING_STARTED.md)
2. **In 15 minutes:** Have it running locally
3. **Today:** Customize it with your info
4. **This week:** Deploy it to the cloud

**Let's go!** 🚀

---

*Last updated: 2024*
