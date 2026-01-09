# Quick Start Guide
## Get Deployed in 30 Minutes

This is your fast-track guide to deploying CareerWise to all three platforms.

---

## 🚀 Step-by-Step (30 Minutes)

### Step 1: Install Tools (5 minutes)

```bash
# Run the setup script
./setup-platforms.sh
```

This installs:
- GCP CLI (gcloud)
- AWS CLI
- Docker
- Python dependencies

### Step 2: Get Platform Credentials (10 minutes)

#### GCP
1. Go to https://console.cloud.google.com
2. Create project (or use existing)
3. Enable billing
4. Note your Project ID

#### AWS
1. Go to https://console.aws.amazon.com
2. Get Access Key ID and Secret Access Key
3. Note your Account ID

#### Akamai
1. Go to https://control.akamai.com
2. Get API credentials (or use trial account)
3. Note your credentials

### Step 3: Create Environment File (2 minutes)

```bash
cd 1_foundations/community_contributions/careerwise_gemini_ntfy

# Copy template
cat > .env.deploy << 'EOF'
# Application
GOOGLE_API_KEY=your-gemini-api-key
NTFY_TOPIC=your-topic-optional

# GCP
GCP_PROJECT_ID=your-project-id
GCP_REGION=us-central1

# AWS
AWS_ACCOUNT_ID=your-account-id
AWS_REGION=us-east-1

# Akamai (get from Control Center)
AKAMAI_CLIENT_TOKEN=your-token
AKAMAI_CLIENT_SECRET=your-secret
AKAMAI_ACCESS_TOKEN=your-access-token
AKAMAI_HOST=akab-xxxxx.luna.akamaiapis.net
EOF

# Edit with your values
nano .env.deploy  # or use your favorite editor
```

### Step 4: Authenticate (5 minutes)

```bash
# GCP
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# AWS
aws configure
# Enter: Access Key, Secret Key, Region, Output format (json)

# Akamai
# Credentials are in .env.deploy, no CLI auth needed
```

### Step 5: Deploy (8 minutes)

```bash
# Deploy to all platforms
./deploy-all.sh
```

This will:
- ✅ Build Docker image
- ✅ Test locally
- ✅ Deploy to GCP Cloud Run (automatic)
- ✅ Push image to AWS ECR (manual App Runner setup needed)
- ✅ Prepare for Akamai (manual deployment needed)

### Step 6: Complete Manual Deployments

#### AWS App Runner
1. Go to https://console.aws.amazon.com/apprunner
2. Create service
3. Source: ECR
4. Image: `ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/careerwise-chatbot:latest`
5. Environment variables: `GOOGLE_API_KEY`, `NTFY_TOPIC`
6. CPU: 0.5, Memory: 1GB, Port: 8080

#### Akamai Cloud Compute
1. Go to https://control.akamai.com
2. Cloud Compute → Create Instance
3. Container: `your-dockerhub-username/careerwise-chatbot:latest`
4. Instance: Medium (2 vCPU, 4GB)
5. Port: 8080
6. Environment variables: `GOOGLE_API_KEY`, `NTFY_TOPIC`

### Step 7: Update URLs

```bash
# Add URLs to .env.deploy
echo "export GCP_URL=\"https://your-gcp-url.a.run.app\"" >> .env.deploy
echo "export AWS_URL=\"https://your-aws-url.us-east-1.awsapprunner.com\"" >> .env.deploy
echo "export AKAMAI_URL=\"https://your-akamai-url.edgekey.net\"" >> .env.deploy

# Load them
source .env.deploy
```

### Step 8: Test Everything

```bash
# Test all endpoints
curl -X POST $GCP_URL/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'

curl -X POST $AWS_URL/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'

curl -X POST $AKAMAI_URL/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'
```

### Step 9: Run Performance Tests

```bash
# Update test_performance.py with your URLs first
python test_performance.py
```

### Step 10: Monitor Costs

- **GCP:** https://console.cloud.google.com/billing
- **AWS:** https://console.aws.amazon.com/cost-management
- **Akamai:** https://control.akamai.com → Billing

---

## 📚 Full Documentation

- **Complete Deployment:** `DEPLOYMENT_MASTER_GUIDE.md`
- **Monitoring:** `MONITORING_AND_EVALUATION.md`
- **Cost Analysis:** `HIGH_VOLUME_COST_ANALYSIS.md`
- **Decision Framework:** `DECISION_MATRIX.md`

---

## 🆘 Troubleshooting

### Issue: gcloud not found
```bash
# Install gcloud
brew install --cask google-cloud-sdk  # Mac
# or see: https://cloud.google.com/sdk/docs/install
```

### Issue: AWS CLI not found
```bash
# Install AWS CLI
brew install awscli  # Mac
# or see: https://aws.amazon.com/cli/
```

### Issue: Docker not running
```bash
# Start Docker Desktop (Mac/Windows)
# Or: sudo systemctl start docker (Linux)
```

### Issue: Permission denied
```bash
# Make scripts executable
chmod +x *.sh
```

### Issue: Deployment fails
- Check environment variables are set
- Verify platform credentials
- Check platform console for errors
- Review logs in each platform's console

---

## ✅ Checklist

Before starting:
- [ ] All CLI tools installed
- [ ] Platform accounts created
- [ ] Billing enabled on all platforms
- [ ] Credentials obtained
- [ ] .env.deploy file created

After deployment:
- [ ] All three platforms deployed
- [ ] All endpoints tested
- [ ] URLs saved in .env.deploy
- [ ] Performance tests run
- [ ] Cost monitoring set up

---

## 🎯 Next Steps

1. **Week 1:** Collect cost and performance data daily
2. **Week 2:** Analyze trends and patterns
3. **Week 3:** Make platform decision
4. **Week 4:** Document findings and optimize

Good luck! 🚀

