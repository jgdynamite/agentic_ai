# CareerWise Deployment Master Guide
## Complete Step-by-Step Deployment to Akamai, AWS, and GCP

This is your complete guide to deploying CareerWise to all three platforms, setting up monitoring, and collecting data for comparison.

---

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Google Cloud Platform Account** (with billing enabled)
- [ ] **AWS Account** (with billing enabled)
- [ ] **Akamai Account** (with Cloud Compute access)
- [ ] **Docker** installed locally
- [ ] **Git** installed
- [ ] **Python 3.10+** installed
- [ ] **AI Provider Setup:**
  - [ ] **Google Gemini API Key** (default, free tier available)
  - [ ] **OR** Local AI server (Ollama, LM Studio, etc.)
  - [ ] **OR** Akamai Inference Cloud credentials
- [ ] **Command-line tools:**
  - [ ] `gcloud` CLI (GCP)
  - [ ] `aws` CLI (AWS)
  - [ ] `docker` CLI

---

## 🤖 AI Provider Options

CareerWise supports multiple AI providers! You can use:
- **Google Gemini** (default) - Free tier available
- **Locally Hosted Models** - Ollama, LM Studio, vLLM, etc. (100% private, no API costs)
- **Akamai Inference Cloud** - Edge-optimized AI inference

See **[AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md)** for detailed setup instructions for each provider.

---

## 🔐 Step 1: Platform Authentication Setup

### 1.1 Google Cloud Platform (GCP)

#### Install gcloud CLI

**macOS:**
```bash
# Download and install
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Or use Homebrew
brew install --cask google-cloud-sdk
```

**Linux:**
```bash
# Add Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install
sudo apt-get update && sudo apt-get install google-cloud-sdk
```

**Windows:**
Download from: https://cloud.google.com/sdk/docs/install

#### Authenticate and Setup

```bash
# Login
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Verify
gcloud config list
```

**Save your credentials:**
```bash
# Your project ID
export GCP_PROJECT_ID="your-project-id"

# Verify billing is enabled
gcloud billing projects describe $GCP_PROJECT_ID
```

---

### 1.2 AWS

#### Install AWS CLI

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
Download from: https://aws.amazon.com/cli/

#### Configure AWS CLI

```bash
# Configure credentials
aws configure

# You'll be prompted for:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)

# Verify
aws sts get-caller-identity

# Set environment variable
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

**Get your AWS Account ID:**
```bash
aws sts get-caller-identity --query Account --output text
```

**Save your credentials:**
```bash
# Your account ID
export AWS_ACCOUNT_ID="your-account-id"
export AWS_REGION="us-east-1"
```

---

### 1.3 Akamai

#### Access Akamai Control Center

1. **Get Akamai Account:**
   - If you don't have one, contact Akamai sales or use trial
   - URL: https://control.akamai.com

2. **Get API Credentials:**
   - Log in to Akamai Control Center
   - Go to: **Identity & Access Management** → **API Clients**
   - Create new API client
   - Save:
     - Client Token
     - Client Secret
     - Access Token
     - Host (e.g., `akab-xxxxx.luna.akamaiapis.net`)

3. **Install Akamai CLI (Optional):**

```bash
# Install via npm
npm install -g @akamai/cli

# Or download from: https://developer.akamai.com/tools
```

**Save your credentials:**
```bash
# Create .akamai directory
mkdir -p ~/.akamai

# Save credentials (you'll get these from Control Center)
export AKAMAI_CLIENT_TOKEN="your-client-token"
export AKAMAI_CLIENT_SECRET="your-client-secret"
export AKAMAI_ACCESS_TOKEN="your-access-token"
export AKAMAI_HOST="akab-xxxxx.luna.akamaiapis.net"
```

---

## 🔧 Step 2: Environment Setup

### 2.1 Create Environment File

Create `.env.deploy` in the CareerWise directory:

```bash
cd 1_foundations/community_contributions/careerwise_gemini_ntfy

cat > .env.deploy << EOF
# Application Configuration
# AI Provider: gemini (default), local, or akamai
AI_PROVIDER=gemini
AI_MODEL=gemini-2.0-flash

# For Gemini (default)
GOOGLE_API_KEY=your-gemini-api-key-here

# For Local Models (Ollama, LM Studio, etc.)
# LOCAL_AI_BASE_URL=http://localhost:11434/v1
# AI_MODEL=llama3.2

# For Akamai Inference Cloud
# AKAMAI_INFERENCE_API_KEY=your-akamai-api-key
# AKAMAI_INFERENCE_BASE_URL=https://your-endpoint.akamai.com/v1

NTFY_TOPIC=your-ntfy-topic-optional

# GCP Configuration
GCP_PROJECT_ID=your-gcp-project-id
GCP_REGION=us-central1

# AWS Configuration
AWS_ACCOUNT_ID=your-aws-account-id
AWS_REGION=us-east-1

# Akamai Configuration
AKAMAI_CLIENT_TOKEN=your-akamai-client-token
AKAMAI_CLIENT_SECRET=your-akamai-client-secret
AKAMAI_ACCESS_TOKEN=your-akamai-access-token
AKAMAI_HOST=akab-xxxxx.luna.akamaiapis.net
EOF
```

**⚠️ Important:** Add `.env.deploy` to `.gitignore` to avoid committing secrets!

```bash
echo ".env.deploy" >> .gitignore
```

### 2.2 Load Environment Variables

```bash
# Source the environment file
source .env.deploy

# Or use direnv (recommended)
# Install: brew install direnv
# Then: echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

---

## 🚀 Step 3: Prepare Application

### 3.1 Fix Requirements File

```bash
cd 1_foundations/community_contributions/careerwise_gemini_ntfy

# Ensure requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    cp requirements requirements.txt
fi
```

### 3.2 Test Locally First

```bash
# Build Docker image
docker build -t careerwise-chatbot:latest .

# Test locally
docker run -d --name careerwise-test \
  -p 8080:8080 \
  -e GOOGLE_API_KEY="$GOOGLE_API_KEY" \
  -e NTFY_TOPIC="$NTFY_TOPIC" \
  careerwise-chatbot:latest

# Test endpoint
sleep 5
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'

# Cleanup
docker stop careerwise-test
docker rm careerwise-test
```

---

## ☁️ Step 4: Deploy to GCP Cloud Run

### 4.1 Build and Push Image

```bash
# Set project
gcloud config set project $GCP_PROJECT_ID

# Build and push to Artifact Registry
gcloud builds submit --tag gcr.io/$GCP_PROJECT_ID/careerwise-chatbot

# Or use Artifact Registry (newer, recommended)
gcloud artifacts repositories create careerwise-repo \
  --repository-format=docker \
  --location=$GCP_REGION \
  --description="CareerWise Chatbot Repository" || echo "Repository may already exist"

gcloud auth configure-docker $GCP_REGION-docker.pkg.dev

docker tag careerwise-chatbot:latest \
  $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/careerwise-repo/careerwise-chatbot:latest

docker push $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/careerwise-repo/careerwise-chatbot:latest
```

### 4.2 Deploy to Cloud Run

```bash
gcloud run deploy careerwise-chatbot \
  --image $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/careerwise-repo/careerwise-chatbot:latest \
  --platform managed \
  --region $GCP_REGION \
  --allow-unauthenticated \
  --port 8080 \
  --memory 1Gi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 80 \
  --set-env-vars="GOOGLE_API_KEY=$GOOGLE_API_KEY,NTFY_TOPIC=$NTFY_TOPIC" \
  --timeout 300 \
  --project $GCP_PROJECT_ID

# Get the URL
export GCP_URL=$(gcloud run services describe careerwise-chatbot \
  --region $GCP_REGION \
  --format 'value(status.url)')

echo "GCP Deployment URL: $GCP_URL"
echo "Test: curl -X POST $GCP_URL/chat -H 'Content-Type: application/json' -d '{\"message\":\"Hello\",\"history\":[]}'"
```

**Save the URL:**
```bash
echo "export GCP_URL=\"$GCP_URL\"" >> .env.deploy
```

---

## ☁️ Step 5: Deploy to AWS App Runner

### 5.1 Create ECR Repository

```bash
# Create ECR repository
aws ecr create-repository \
  --repository-name careerwise-chatbot \
  --region $AWS_REGION \
  --image-scanning-configuration scanOnPush=true || echo "Repository may already exist"

# Get login token
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

### 5.2 Build and Push Image

```bash
# Tag image
docker tag careerwise-chatbot:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careerwise-chatbot:latest

# Push image
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careerwise-chatbot:latest
```

### 5.3 Deploy to App Runner

Create `aws-apprunner-config.json`:

```json
{
  "ServiceName": "careerwise-chatbot",
  "SourceConfiguration": {
    "ImageRepository": {
      "ImageIdentifier": "ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/careerwise-chatbot:latest",
      "ImageRepositoryType": "ECR",
      "ImageConfiguration": {
        "Port": "8080",
        "RuntimeEnvironmentVariables": {
          "GOOGLE_API_KEY": "YOUR_KEY",
          "NTFY_TOPIC": "YOUR_TOPIC"
        }
      },
      "AutoDeploymentsEnabled": true
    }
  },
  "InstanceConfiguration": {
    "Cpu": "0.5 vCPU",
    "Memory": "1 GB"
  },
  "AutoScalingConfigurationArn": "",
  "HealthCheckConfiguration": {
    "Protocol": "HTTP",
    "Path": "/docs",
    "Interval": 10,
    "Timeout": 5,
    "HealthyThreshold": 1,
    "UnhealthyThreshold": 5
  }
}
```

**Deploy via CLI:**

```bash
# Create service (you'll need to replace placeholders in the JSON)
aws apprunner create-service \
  --service-name careerwise-chatbot \
  --source-configuration file://aws-apprunner-config.json \
  --instance-configuration Cpu="0.5 vCPU",Memory="1 GB" \
  --region $AWS_REGION

# Or use the deployment script (see deploy-aws.sh)
```

**Get the URL:**
```bash
# Wait for deployment (takes 5-10 minutes)
sleep 300

export AWS_URL=$(aws apprunner describe-service \
  --service-arn $(aws apprunner list-services --query "ServiceSummaryList[?ServiceName=='careerwise-chatbot'].ServiceArn" --output text) \
  --query "Service.ServiceUrl" --output text)

echo "AWS Deployment URL: $AWS_URL"
echo "export AWS_URL=\"$AWS_URL\"" >> .env.deploy
```

**Note:** App Runner deployment can also be done via AWS Console (easier for first time).

---

## 🌐 Step 6: Deploy to Akamai Cloud Compute

### 6.1 Push Image to Docker Hub (or Akamai Registry)

```bash
# Login to Docker Hub
docker login

# Tag for Docker Hub
docker tag careerwise-chatbot:latest your-dockerhub-username/careerwise-chatbot:latest

# Push
docker push your-dockerhub-username/careerwise-chatbot:latest
```

### 6.2 Deploy via Akamai Control Center

**Manual Steps (Akamai doesn't have full CLI support for Cloud Compute):**

1. **Log in to Akamai Control Center:**
   - Go to https://control.akamai.com
   - Navigate to **Cloud Compute** section

2. **Create Compute Instance:**
   - Click **Create Instance**
   - Select **Container Deployment**
   - Image: `your-dockerhub-username/careerwise-chatbot:latest`
   - Instance Type: **Medium** (2 vCPU, 4GB RAM)
   - Region: Choose closest to your users
   - Port: **8080**

3. **Configure Environment Variables:**
   - `GOOGLE_API_KEY`: Your Gemini API key
   - `NTFY_TOPIC`: Your ntfy topic (optional)

4. **Configure Edge Hostname:**
   - Create edge hostname
   - Point to your compute instance
   - Configure SSL certificate
   - Note the public URL

**Save the URL:**
```bash
export AKAMAI_URL="https://your-akamai-edge-hostname.edgekey.net"
echo "export AKAMAI_URL=\"$AKAMAI_URL\"" >> .env.deploy
```

---

## ✅ Step 7: Verify All Deployments

### 7.1 Test All Endpoints

```bash
# Load URLs
source .env.deploy

# Test GCP
echo "Testing GCP..."
curl -X POST $GCP_URL/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'

# Test AWS
echo "Testing AWS..."
curl -X POST $AWS_URL/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'

# Test Akamai
echo "Testing Akamai..."
curl -X POST $AKAMAI_URL/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'
```

### 7.2 Update Performance Test Script

Edit `test_performance.py` and update the ENDPOINTS:

```python
ENDPOINTS = {
    "Akamai": os.getenv("AKAMAI_URL", "") + "/chat",
    "AWS": os.getenv("AWS_URL", "") + "/chat",
    "GCP": os.getenv("GCP_URL", "") + "/chat"
}
```

---

## 📊 Step 8: Set Up Monitoring

### 8.1 GCP Monitoring

```bash
# Enable Cloud Monitoring API
gcloud services enable monitoring.googleapis.com

# View metrics in Console
echo "GCP Monitoring: https://console.cloud.google.com/monitoring"
```

### 8.2 AWS Monitoring

```bash
# CloudWatch is automatically enabled
echo "AWS CloudWatch: https://console.aws.amazon.com/cloudwatch"
```

### 8.3 Akamai Monitoring

```bash
# Monitoring available in Control Center
echo "Akamai Monitoring: https://control.akamai.com"
```

---

## 🎯 Next Steps

1. **Run Performance Tests:** Use `test_performance.py`
2. **Monitor Costs:** Check billing dashboards daily
3. **Collect Data:** Use the tracking templates
4. **Evaluate:** Use the comparison framework

See the other guides for detailed monitoring and evaluation steps.

