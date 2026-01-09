# 🚀 GCP Deployment Guide for CareerWise

This guide will walk you through deploying CareerWise to Google Cloud Run step by step.

---

## 📋 Prerequisites

Before starting, you need:

1. **Google Cloud Account** (with billing enabled)
   - Sign up at: https://cloud.google.com/
   - Free tier includes $300 credit for 90 days

2. **gcloud CLI** - Google Cloud command-line tool
3. **Docker Desktop** - For building container images
4. **CareerWise running locally** - We tested this already! ✅

---

## 🔧 Step 1: Install gcloud CLI

### macOS (using Homebrew)

```bash
brew install --cask google-cloud-sdk
```

### Alternative Installation

```bash
# Download and install
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Or download manually from:
# https://cloud.google.com/sdk/docs/install
```

### Verify Installation

```bash
gcloud --version
```

You should see something like:
```
Google Cloud SDK 450.0.0
```

---

## 🔐 Step 2: Authenticate with Google Cloud

```bash
# Login to your Google account
gcloud auth login

# This will open your browser for authentication
```

---

## 🎯 Step 3: Create or Select a GCP Project

### Option A: Create a New Project

1. Go to: https://console.cloud.google.com/
2. Click "Create Project" or use the project selector
3. Enter project name: `careerwise-chatbot` (or your choice)
4. Note your **Project ID** (e.g., `careerwise-chatbot-123456`)

### Option B: Use Existing Project

1. Go to: https://console.cloud.google.com/
2. Select your project from the dropdown

### Set Your Project in gcloud

```bash
# Replace YOUR_PROJECT_ID with your actual project ID
gcloud config set project YOUR_PROJECT_ID

# Verify
gcloud config get-value project
```

---

## 💳 Step 4: Enable Billing (Required)

Cloud Run requires billing to be enabled, even for free tier usage.

1. Go to: https://console.cloud.google.com/billing
2. Link a billing account to your project
3. Or create a new billing account (credit card required)
4. **Note:** Cloud Run free tier includes:
   - 2 million requests/month
   - 360,000 GB-seconds of memory
   - 180,000 vCPU-seconds
   - This should be plenty for testing!

---

## 📝 Step 5: Update Your .env File

Make sure your `.env` file has these variables:

```bash
cd /Users/jglover/jgdynamite/projects/agentic_ai/1_foundations/community_contributions/careerwise_gemini_ntfy

# Check your .env file
cat .env
```

Your `.env` should have:
```bash
AI_PROVIDER=gemini
GOOGLE_API_KEY=your-actual-api-key-here
AI_MODEL=gemini-2.0-flash
GCP_PROJECT_ID=your-gcp-project-id
GCP_REGION=us-central1
NTFY_TOPIC=  # Optional
```

**If GCP_PROJECT_ID is missing, add it:**
```bash
# Add to .env file (replace with your actual project ID)
echo "GCP_PROJECT_ID=your-project-id" >> .env
echo "GCP_REGION=us-central1" >> .env
```

---

## 🚀 Step 6: Deploy Using the Script (Easy Way)

We've created an automated deployment script for you!

### Make sure Docker is running

```bash
# Check if Docker is running
docker info
```

If it's not running, start Docker Desktop.

### Run the deployment script

```bash
cd /Users/jglover/jgdynamite/projects/agentic_ai/1_foundations/community_contributions/careerwise_gemini_ntfy

./deploy-gcp.sh
```

The script will:
- ✅ Check prerequisites (gcloud, Docker)
- ✅ Load your environment variables
- ✅ Authenticate with GCP
- ✅ Enable required APIs
- ✅ Create Artifact Registry repository
- ✅ Build Docker image
- ✅ Push image to registry
- ✅ Deploy to Cloud Run
- ✅ Show you the live URL!

**This takes about 5-10 minutes.**

---

## 🔨 Step 7: Manual Deployment (If Script Doesn't Work)

If you prefer manual steps or the script has issues:

### 7.1 Enable Required APIs

```bash
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### 7.2 Create Artifact Registry Repository

```bash
gcloud artifacts repositories create careerwise-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="CareerWise Chatbot Repository"
```

### 7.3 Configure Docker Authentication

```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### 7.4 Build and Push Image

```bash
# Load your environment variables
source .env

# Set image name
IMAGE_NAME="us-central1-docker.pkg.dev/$GCP_PROJECT_ID/careerwise-repo/careerwise-chatbot:latest"

# Build the image
docker build -t "$IMAGE_NAME" .

# Push the image
docker push "$IMAGE_NAME"
```

### 7.5 Deploy to Cloud Run

```bash
# Deploy with environment variables
gcloud run deploy careerwise-chatbot \
  --image "$IMAGE_NAME" \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 1Gi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --set-env-vars="AI_PROVIDER=$AI_PROVIDER,AI_MODEL=$AI_MODEL,GOOGLE_API_KEY=$GOOGLE_API_KEY" \
  --timeout 300 \
  --project "$GCP_PROJECT_ID"
```

### 7.6 Get the URL

```bash
# Get your service URL
gcloud run services describe careerwise-chatbot \
  --region us-central1 \
  --format 'value(status.url)'
```

---

## ✅ Step 8: Test Your Deployment

Once deployed, you'll get a URL like:
```
https://careerwise-chatbot-xxxxx-uc.a.run.app
```

### Test the API

```bash
# Replace with your actual URL
curl -X POST https://careerwise-chatbot-xxxxx-uc.a.run.app/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, tell me about yourself", "history": []}'
```

### View API Documentation

Open in your browser:
```
https://careerwise-chatbot-xxxxx-uc.a.run.app/docs
```

You should see the interactive Swagger UI!

---

## 🧪 Step 9: Test End-to-End

### Test 1: Health Check

```bash
# Check if service is responding
curl https://your-app-url.a.run.app/docs
```

Should return HTML (the API docs page).

### Test 2: Chat Endpoint

```bash
curl -X POST https://your-app-url.a.run.app/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is your background?",
    "history": []
  }'
```

Should return:
```json
{
  "response": "Hello! I'm Mahesh Dindur, and I have experience in..."
}
```

### Test 3: Interactive Testing

1. Open `https://your-app-url.a.run.app/docs` in your browser
2. Click on `POST /chat`
3. Click "Try it out"
4. Enter a message: `"Hello, tell me about your skills"`
5. Click "Execute"
6. See the response below!

---

## 🐛 Troubleshooting

### Issue: "gcloud: command not found"

**Solution:**
```bash
# Install gcloud CLI (see Step 1)
brew install --cask google-cloud-sdk

# Then restart your terminal or run:
exec -l $SHELL
```

### Issue: "Docker is not running"

**Solution:**
- Open Docker Desktop
- Wait for it to fully start (whale icon in menu bar)
- Try again

### Issue: "Permission denied" or authentication errors

**Solution:**
```bash
# Re-authenticate
gcloud auth login

# Set your project again
gcloud config set project YOUR_PROJECT_ID

# Check current configuration
gcloud config list
```

### Issue: "Billing account required"

**Solution:**
1. Go to: https://console.cloud.google.com/billing
2. Link a billing account to your project
3. Free tier has generous limits for testing

### Issue: "Build failed" or Docker errors

**Solution:**
```bash
# Test Docker build locally first
docker build -t careerwise-test .

# If it works locally, check your Dockerfile
# Make sure all files are copied correctly
```

### Issue: "Service deployment failed"

**Check logs:**
```bash
gcloud run services logs read careerwise-chatbot \
  --region us-central1 \
  --limit 50
```

### Issue: "Environment variable not set"

**Solution:**
Make sure your `.env` file has all required variables:
- `GOOGLE_API_KEY` (must be set)
- `AI_PROVIDER` (defaults to "gemini")
- `AI_MODEL` (defaults to "gemini-2.0-flash")

---

## 📊 Step 10: Monitor Your Deployment

### View Logs

```bash
# Stream logs in real-time
gcloud run services logs tail careerwise-chatbot \
  --region us-central1

# View recent logs
gcloud run services logs read careerwise-chatbot \
  --region us-central1 \
  --limit 50
```

### Check Service Status

```bash
# Get service details
gcloud run services describe careerwise-chatbot \
  --region us-central1

# List all services
gcloud run services list
```

### Monitor in Console

Go to: https://console.cloud.google.com/run

You'll see:
- Service status
- Request metrics
- Logs
- Configuration

---

## 💰 Step 11: Monitor Costs

### Check Current Usage

```bash
# View billing
gcloud billing accounts list

# Check project billing
gcloud billing projects describe YOUR_PROJECT_ID
```

### View in Console

1. Go to: https://console.cloud.google.com/billing
2. Select your billing account
3. View "Cost breakdown"
4. Filter by "Cloud Run"

**Free Tier Limits:**
- 2 million requests/month
- 360,000 GB-seconds memory
- 180,000 vCPU-seconds

For testing, you should stay well within free limits!

---

## 🎯 Next Steps

Once deployed and tested:

1. **Save your URL** - Add to `.env` as `GCP_URL=https://your-app-url.a.run.app`
2. **Test thoroughly** - Try different questions
3. **Monitor logs** - Check for any errors
4. **Customize** - Update `me/` folder content
5. **Embed in portfolio** - Use the URL in your website widget

---

## 🔗 Quick Reference Commands

```bash
# Deploy
./deploy-gcp.sh

# View logs
gcloud run services logs tail careerwise-chatbot --region us-central1

# Get URL
gcloud run services describe careerwise-chatbot --region us-central1 --format 'value(status.url)'

# Update deployment (after code changes)
./deploy-gcp.sh  # Re-run the script

# Delete service (if needed)
gcloud run services delete careerwise-chatbot --region us-central1
```

---

## ✅ Success Checklist

- [ ] gcloud CLI installed
- [ ] Authenticated with Google Cloud
- [ ] Project created/selected
- [ ] Billing enabled
- [ ] Docker Desktop running
- [ ] `.env` file configured
- [ ] Deployment script run successfully
- [ ] Service deployed and accessible
- [ ] API tested and working
- [ ] Logs checked (no errors)

---

**🎉 Congratulations! Your CareerWise chatbot is now live in the cloud!**

You can now share the URL with others and embed it in your portfolio website!
