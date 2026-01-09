#!/bin/bash

# CareerWise Chatbot - Deploy to All Platforms
# This script deploys to GCP, AWS, and prepares for Akamai

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env.deploy ]; then
    source .env.deploy
else
    echo -e "${RED}Error: .env.deploy not found${NC}"
    echo "Please create .env.deploy file first (see DEPLOYMENT_MASTER_GUIDE.md)"
    exit 1
fi

# Check required variables
check_var() {
    if [ -z "${!1}" ]; then
        echo -e "${RED}Error: $1 is not set${NC}"
        echo "Please set it in .env.deploy"
        exit 1
    fi
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CareerWise Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
check_var "GOOGLE_API_KEY"
check_var "GCP_PROJECT_ID"
check_var "AWS_ACCOUNT_ID"
check_var "AWS_REGION"

# Step 1: Build Docker image
echo -e "${GREEN}Step 1: Building Docker image...${NC}"
if [ ! -f "requirements.txt" ]; then
    echo "Creating requirements.txt..."
    cp requirements requirements.txt 2>/dev/null || touch requirements.txt
fi

docker build -t careerwise-chatbot:latest .
echo -e "${GREEN}✓ Image built${NC}"
echo ""

# Step 2: Test locally
echo -e "${GREEN}Step 2: Testing locally...${NC}"
docker run -d --name careerwise-test \
    -p 8080:8080 \
    -e GOOGLE_API_KEY="$GOOGLE_API_KEY" \
    -e NTFY_TOPIC="$NTFY_TOPIC" \
    careerwise-chatbot:latest || true

sleep 5

if curl -s -X POST http://localhost:8080/chat \
    -H "Content-Type: application/json" \
    -d '{"message": "Hello", "history": []}' > /dev/null; then
    echo -e "${GREEN}✓ Local test passed${NC}"
else
    echo -e "${YELLOW}⚠ Local test failed, but continuing...${NC}"
fi

docker stop careerwise-test 2>/dev/null || true
docker rm careerwise-test 2>/dev/null || true
echo ""

# Step 3: Deploy to GCP
echo -e "${GREEN}Step 3: Deploying to GCP Cloud Run...${NC}"
if command -v gcloud &> /dev/null; then
    # Set project
    gcloud config set project "$GCP_PROJECT_ID" --quiet
    
    # Create Artifact Registry repository
    gcloud artifacts repositories create careerwise-repo \
        --repository-format=docker \
        --location="${GCP_REGION:-us-central1}" \
        --description="CareerWise Chatbot Repository" 2>/dev/null || echo "Repository exists"
    
    # Configure Docker
    gcloud auth configure-docker "${GCP_REGION:-us-central1}-docker.pkg.dev" --quiet
    
    # Tag and push
    IMAGE_TAG="${GCP_REGION:-us-central1}-docker.pkg.dev/$GCP_PROJECT_ID/careerwise-repo/careerwise-chatbot:latest"
    docker tag careerwise-chatbot:latest "$IMAGE_TAG"
    docker push "$IMAGE_TAG"
    
    # Deploy
    gcloud run deploy careerwise-chatbot \
        --image "$IMAGE_TAG" \
        --platform managed \
        --region "${GCP_REGION:-us-central1}" \
        --allow-unauthenticated \
        --port 8080 \
        --memory 1Gi \
        --cpu 1 \
        --min-instances 0 \
        --max-instances 10 \
        --concurrency 80 \
        --set-env-vars="GOOGLE_API_KEY=$GOOGLE_API_KEY,NTFY_TOPIC=$NTFY_TOPIC" \
        --timeout 300 \
        --quiet
    
    # Get URL
    GCP_URL=$(gcloud run services describe careerwise-chatbot \
        --region "${GCP_REGION:-us-central1}" \
        --format 'value(status.url)')
    
    echo -e "${GREEN}✓ GCP deployed: $GCP_URL${NC}"
    echo "export GCP_URL=\"$GCP_URL\"" >> .env.deploy
else
    echo -e "${YELLOW}⚠ gcloud CLI not found. Skipping GCP deployment.${NC}"
fi
echo ""

# Step 4: Deploy to AWS
echo -e "${GREEN}Step 4: Deploying to AWS App Runner...${NC}"
if command -v aws &> /dev/null; then
    # Create ECR repository
    aws ecr create-repository \
        --repository-name careerwise-chatbot \
        --region "$AWS_REGION" \
        --image-scanning-configuration scanOnPush=true 2>/dev/null || echo "Repository exists"
    
    # Login to ECR
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin \
        "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
    
    # Tag and push
    AWS_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/careerwise-chatbot:latest"
    docker tag careerwise-chatbot:latest "$AWS_IMAGE"
    docker push "$AWS_IMAGE"
    
    echo -e "${YELLOW}⚠ AWS App Runner deployment requires manual steps or JSON config.${NC}"
    echo "Image pushed to: $AWS_IMAGE"
    echo ""
    echo "Next steps:"
    echo "1. Go to AWS App Runner console"
    echo "2. Create new service"
    echo "3. Use ECR image: $AWS_IMAGE"
    echo "4. Set environment variables:"
    echo "   - GOOGLE_API_KEY=$GOOGLE_API_KEY"
    echo "   - NTFY_TOPIC=$NTFY_TOPIC"
    echo "5. Configure: CPU 0.5, Memory 1GB, Port 8080"
else
    echo -e "${YELLOW}⚠ AWS CLI not found. Skipping AWS deployment.${NC}"
fi
echo ""

# Step 5: Prepare for Akamai
echo -e "${GREEN}Step 5: Preparing for Akamai deployment...${NC}"
echo "Push image to Docker Hub:"
echo ""
echo "  docker login"
echo "  docker tag careerwise-chatbot:latest your-dockerhub-username/careerwise-chatbot:latest"
echo "  docker push your-dockerhub-username/careerwise-chatbot:latest"
echo ""
echo "Then deploy via Akamai Control Center (see DEPLOYMENT_MASTER_GUIDE.md)"
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deployment Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
if [ ! -z "$GCP_URL" ]; then
    echo -e "${GREEN}✓ GCP: $GCP_URL${NC}"
fi
echo -e "${YELLOW}⚠ AWS: Manual deployment required${NC}"
echo -e "${YELLOW}⚠ Akamai: Manual deployment required${NC}"
echo ""
echo "Next steps:"
echo "1. Complete AWS and Akamai deployments"
echo "2. Update .env.deploy with all URLs"
echo "3. Run: python test_performance.py"
echo "4. Monitor costs in each platform's console"

