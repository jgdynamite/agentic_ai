#!/bin/bash
# CareerWise GCP Deployment Script (No Docker Required)
# This script deploys CareerWise to Google Cloud Run using Cloud Build

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🚀 CareerWise GCP Deployment Script (No Docker Required)"
echo "=========================================================="
echo ""

# Step 1: Check prerequisites
echo "📋 Checking prerequisites..."

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI is not installed${NC}"
    echo ""
    echo "Please install gcloud CLI first:"
    echo "  macOS: brew install --cask google-cloud-sdk"
    echo "  Or visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi
echo -e "${GREEN}✓ gcloud CLI found${NC}"

# Step 2: Load environment variables
echo ""
echo "📝 Loading environment variables..."

if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found${NC}"
    echo "Please create a .env file with your configuration"
    exit 1
fi

# Source .env file
set -a
source .env
set +a

# Check required variables
if [ -z "$GOOGLE_API_KEY" ] || [ "$GOOGLE_API_KEY" = "your-api-key-here" ]; then
    echo -e "${RED}❌ GOOGLE_API_KEY not set in .env file${NC}"
    echo "Please set your Gemini API key in .env file"
    exit 1
fi
echo -e "${GREEN}✓ GOOGLE_API_KEY found${NC}"

# Set defaults if not set
GCP_PROJECT_ID=${GCP_PROJECT_ID:-""}
GCP_REGION=${GCP_REGION:-"us-central1"}
AI_PROVIDER=${AI_PROVIDER:-"gemini"}
AI_MODEL=${AI_MODEL:-"gemini-2.0-flash"}

if [ -z "$GCP_PROJECT_ID" ]; then
    echo ""
    echo -e "${YELLOW}⚠ GCP_PROJECT_ID not set in .env${NC}"
    read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
    export GCP_PROJECT_ID
fi

echo -e "${GREEN}✓ Project ID: $GCP_PROJECT_ID${NC}"
echo -e "${GREEN}✓ Region: $GCP_REGION${NC}"

# Step 3: Authenticate with GCP
echo ""
echo "🔐 Checking GCP authentication..."

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "Please authenticate with GCP..."
    gcloud auth login
fi

CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")

if [ "$CURRENT_PROJECT" != "$GCP_PROJECT_ID" ]; then
    echo "Setting GCP project to: $GCP_PROJECT_ID"
    gcloud config set project "$GCP_PROJECT_ID"
fi

echo -e "${GREEN}✓ Authenticated and project set${NC}"

# Step 4: Enable required APIs
echo ""
echo "🔧 Enabling required GCP APIs..."

gcloud services enable run.googleapis.com --quiet || echo "Cloud Run API already enabled"
gcloud services enable cloudbuild.googleapis.com --quiet || echo "Cloud Build API already enabled"
gcloud services enable artifactregistry.googleapis.com --quiet || echo "Artifact Registry API already enabled"

echo -e "${GREEN}✓ Required APIs enabled${NC}"

# Step 5: Create Artifact Registry repository (if needed)
echo ""
echo "📦 Setting up Artifact Registry..."

REPO_NAME="careerwise-repo"
REPO_EXISTS=$(gcloud artifacts repositories list --location="$GCP_REGION" --format="value(name)" --filter="name~$REPO_NAME" || echo "")

if [ -z "$REPO_EXISTS" ]; then
    echo "Creating Artifact Registry repository..."
    gcloud artifacts repositories create "$REPO_NAME" \
        --repository-format=docker \
        --location="$GCP_REGION" \
        --description="CareerWise Chatbot Repository" \
        --quiet
    echo -e "${GREEN}✓ Repository created${NC}"
else
    echo -e "${GREEN}✓ Repository already exists${NC}"
fi

# Step 6: Build and deploy using Cloud Build
echo ""
echo "☁️  Building and deploying using Cloud Build..."

# Prepare environment variables for Cloud Run
ENV_VARS="AI_PROVIDER=${AI_PROVIDER},AI_MODEL=${AI_MODEL},GOOGLE_API_KEY=${GOOGLE_API_KEY}"

if [ -n "$NTFY_TOPIC" ]; then
    ENV_VARS="${ENV_VARS},NTFY_TOPIC=${NTFY_TOPIC}"
fi

# Get the current directory
PROJECT_DIR=$(pwd)

echo "Building Docker image in the cloud..."
echo "This may take 5-10 minutes..."

# Deploy using source-based deployment with Cloud Build
gcloud run deploy careerwise-chatbot \
    --source . \
    --platform managed \
    --region "$GCP_REGION" \
    --allow-unauthenticated \
    --port 8080 \
    --memory 1Gi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10 \
    --concurrency 80 \
    --set-env-vars "$ENV_VARS" \
    --timeout 300 \
    --project "$GCP_PROJECT_ID"

echo -e "${GREEN}✓ Deployment complete!${NC}"

# Step 7: Get the URL
echo ""
echo "🔗 Getting deployment URL..."

SERVICE_URL=$(gcloud run services describe careerwise-chatbot \
    --region "$GCP_REGION" \
    --format 'value(status.url)' \
    --project "$GCP_PROJECT_ID")

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Deployment Successful!${NC}"
echo "=========================================="
echo ""
echo "🌐 Your CareerWise API is live at:"
echo -e "${GREEN}$SERVICE_URL${NC}"
echo ""
echo "📚 API Documentation:"
echo -e "${GREEN}$SERVICE_URL/docs${NC}"
echo ""
echo "🧪 Test the API:"
echo "curl -X POST $SERVICE_URL/chat \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"message\": \"Hello\", \"history\": []}'"
echo ""
echo "📝 Save this URL in your .env file:"
echo "GCP_URL=$SERVICE_URL"
echo ""

# Save URL to .env if requested
read -p "Do you want to save this URL to .env? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! grep -q "GCP_URL=" .env 2>/dev/null; then
        echo "GCP_URL=$SERVICE_URL" >> .env
        echo -e "${GREEN}✓ URL saved to .env${NC}"
    else
        sed -i.bak "s|GCP_URL=.*|GCP_URL=$SERVICE_URL|" .env
        echo -e "${GREEN}✓ URL updated in .env${NC}"
    fi
fi

echo ""
echo "🎉 All done! Your CareerWise chatbot is now live in the cloud!"
echo ""
echo "ℹ️  Note: This deployment used Cloud Build (no local Docker required)"
