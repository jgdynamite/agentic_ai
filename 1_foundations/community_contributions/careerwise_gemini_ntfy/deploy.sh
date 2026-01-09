#!/bin/bash

# CareerWise Chatbot Deployment Script
# Supports: AWS, GCP, Akamai (manual steps)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="careerwise-chatbot"
IMAGE_NAME="careerwise-chatbot"
REGION="us-central1"  # Change as needed

# Check if requirements.txt exists, if not create from requirements
if [ ! -f "requirements.txt" ] && [ -f "requirements" ]; then
    echo -e "${YELLOW}Creating requirements.txt from requirements...${NC}"
    cp requirements requirements.txt
fi

# Function to build Docker image
build_image() {
    echo -e "${GREEN}Building Docker image...${NC}"
    docker build -t ${IMAGE_NAME}:latest .
    echo -e "${GREEN}✓ Image built successfully${NC}"
}

# Function to test locally
test_local() {
    echo -e "${GREEN}Testing locally...${NC}"
    docker run -d --name ${PROJECT_NAME}-test \
        -p 8080:8080 \
        -e GOOGLE_API_KEY="${GOOGLE_API_KEY}" \
        -e NTFY_TOPIC="${NTFY_TOPIC}" \
        ${IMAGE_NAME}:latest
    
    echo "Waiting for service to start..."
    sleep 5
    
    # Test endpoint
    response=$(curl -s -X POST http://localhost:8080/chat \
        -H "Content-Type: application/json" \
        -d '{"message": "Hello", "history": []}')
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Local test successful${NC}"
        echo "Response: $response"
    else
        echo -e "${RED}✗ Local test failed${NC}"
    fi
    
    # Cleanup
    docker stop ${PROJECT_NAME}-test
    docker rm ${PROJECT_NAME}-test
}

# Function to deploy to GCP Cloud Run
deploy_gcp() {
    echo -e "${GREEN}Deploying to GCP Cloud Run...${NC}"
    
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}gcloud CLI not found. Please install it first.${NC}"
        exit 1
    fi
    
    # Set project
    read -p "Enter GCP Project ID: " GCP_PROJECT
    gcloud config set project ${GCP_PROJECT}
    
    # Build and push
    echo "Building and pushing to GCR..."
    gcloud builds submit --tag gcr.io/${GCP_PROJECT}/${IMAGE_NAME}
    
    # Deploy
    echo "Deploying to Cloud Run..."
    gcloud run deploy ${PROJECT_NAME} \
        --image gcr.io/${GCP_PROJECT}/${IMAGE_NAME} \
        --platform managed \
        --region ${REGION} \
        --allow-unauthenticated \
        --port 8080 \
        --memory 1Gi \
        --cpu 1 \
        --min-instances 0 \
        --max-instances 10 \
        --set-env-vars="GOOGLE_API_KEY=${GOOGLE_API_KEY},NTFY_TOPIC=${NTFY_TOPIC}" \
        --timeout 300
    
    # Get URL
    URL=$(gcloud run services describe ${PROJECT_NAME} --region ${REGION} --format 'value(status.url)')
    echo -e "${GREEN}✓ Deployed successfully!${NC}"
    echo "URL: ${URL}"
}

# Function to deploy to AWS App Runner
deploy_aws() {
    echo -e "${GREEN}Deploying to AWS App Runner...${NC}"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}AWS CLI not found. Please install it first.${NC}"
        exit 1
    fi
    
    read -p "Enter AWS Account ID: " AWS_ACCOUNT
    read -p "Enter AWS Region (default: us-east-1): " AWS_REGION
    AWS_REGION=${AWS_REGION:-us-east-1}
    
    # Create ECR repository
    echo "Creating ECR repository..."
    aws ecr create-repository --repository-name ${IMAGE_NAME} --region ${AWS_REGION} 2>/dev/null || echo "Repository already exists"
    
    # Login to ECR
    echo "Logging in to ECR..."
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
    
    # Tag and push
    echo "Tagging and pushing image..."
    docker tag ${IMAGE_NAME}:latest ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest
    docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Go to AWS App Runner console"
    echo "2. Create new service"
    echo "3. Select ECR as source"
    echo "4. Use image: ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest"
    echo "5. Set environment variables:"
    echo "   - GOOGLE_API_KEY=${GOOGLE_API_KEY}"
    echo "   - NTFY_TOPIC=${NTFY_TOPIC}"
    echo "6. Configure: CPU 0.5, Memory 1GB, Port 8080"
}

# Function to show Akamai deployment instructions
deploy_akamai() {
    echo -e "${GREEN}Akamai Deployment Instructions:${NC}"
    echo ""
    echo "1. Push image to Docker Hub:"
    echo "   docker tag ${IMAGE_NAME}:latest your-dockerhub-username/${IMAGE_NAME}:latest"
    echo "   docker push your-dockerhub-username/${IMAGE_NAME}:latest"
    echo ""
    echo "2. In Akamai Control Center:"
    echo "   - Navigate to Cloud Compute"
    echo "   - Create new compute instance"
    echo "   - Select container deployment"
    echo "   - Use image: your-dockerhub-username/${IMAGE_NAME}:latest"
    echo "   - Configure: 1 vCPU, 2GB RAM, Port 8080"
    echo "   - Set environment variables:"
    echo "     * GOOGLE_API_KEY=${GOOGLE_API_KEY}"
    echo "     * NTFY_TOPIC=${NTFY_TOPIC}"
    echo ""
    echo "3. Configure edge hostname and SSL"
    echo "4. Note the public URL"
}

# Main menu
main() {
    echo "=========================================="
    echo "CareerWise Chatbot Deployment"
    echo "=========================================="
    echo ""
    
    # Check environment variables
    if [ -z "$GOOGLE_API_KEY" ]; then
        read -p "Enter GOOGLE_API_KEY: " GOOGLE_API_KEY
        export GOOGLE_API_KEY
    fi
    
    if [ -z "$NTFY_TOPIC" ]; then
        read -p "Enter NTFY_TOPIC (optional, press Enter to skip): " NTFY_TOPIC
        export NTFY_TOPIC
    fi
    
    echo ""
    echo "Select deployment option:"
    echo "1) Build Docker image only"
    echo "2) Build and test locally"
    echo "3) Deploy to GCP Cloud Run"
    echo "4) Deploy to AWS App Runner"
    echo "5) Show Akamai deployment instructions"
    echo "6) All of the above"
    echo ""
    read -p "Enter choice [1-6]: " choice
    
    case $choice in
        1)
            build_image
            ;;
        2)
            build_image
            test_local
            ;;
        3)
            build_image
            deploy_gcp
            ;;
        4)
            build_image
            deploy_aws
            ;;
        5)
            build_image
            deploy_akamai
            ;;
        6)
            build_image
            test_local
            echo ""
            deploy_gcp
            echo ""
            deploy_aws
            echo ""
            deploy_akamai
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

# Run main function
main

