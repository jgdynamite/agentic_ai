#!/bin/bash
# Script to update the Gemini API key in Cloud Run

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔑 Update Gemini API Key in Cloud Run"
echo "======================================"
echo ""

# Load environment variables
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found${NC}"
    exit 1
fi

source .env

# Set defaults
GCP_PROJECT_ID=${GCP_PROJECT_ID:-""}
GCP_REGION=${GCP_REGION:-"us-central1"}
AI_PROVIDER=${AI_PROVIDER:-"gemini"}
AI_MODEL=${AI_MODEL:-"gemini-2.0-flash"}

if [ -z "$GCP_PROJECT_ID" ]; then
    read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
fi

# Get current API key from .env or prompt
CURRENT_KEY=${GOOGLE_API_KEY:-""}

echo "Current API key: ${CURRENT_KEY:0:10}...${CURRENT_KEY: -4}"
echo ""
echo "Do you want to:"
echo "1. Use the API key from .env file"
echo "2. Enter a new API key"
read -p "Enter choice (1 or 2): " choice

if [ "$choice" = "2" ]; then
    read -p "Enter your new Gemini API key: " NEW_API_KEY
    GOOGLE_API_KEY=$NEW_API_KEY
fi

if [ -z "$GOOGLE_API_KEY" ]; then
    echo -e "${RED}❌ API key is required${NC}"
    exit 1
fi

echo ""
echo "📝 Updating Cloud Run service with new API key..."
echo ""

# Prepare environment variables
ENV_VARS="AI_PROVIDER=${AI_PROVIDER},AI_MODEL=${AI_MODEL},GOOGLE_API_KEY=${GOOGLE_API_KEY}"

if [ -n "$NTFY_TOPIC" ]; then
    ENV_VARS="${ENV_VARS},NTFY_TOPIC=${NTFY_TOPIC}"
fi

# Update the service
gcloud run services update careerwise-chatbot \
    --region "$GCP_REGION" \
    --update-env-vars "$ENV_VARS" \
    --project "$GCP_PROJECT_ID" \
    --quiet

echo ""
echo -e "${GREEN}✅ API key updated successfully!${NC}"
echo ""
echo "🧪 Testing the API in 5 seconds..."
sleep 5

# Test the API
echo ""
echo "Testing API endpoint..."
RESPONSE=$(curl -s -X POST https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}' || echo "ERROR")

if [[ "$RESPONSE" == *"response"* ]]; then
    echo -e "${GREEN}✅ API is working!${NC}"
    echo ""
    echo "Response preview:"
    echo "$RESPONSE" | head -c 200
    echo "..."
else
    echo -e "${YELLOW}⚠️  API response:${NC}"
    echo "$RESPONSE"
    echo ""
    echo "Check logs if you see errors:"
    echo "gcloud run services logs read careerwise-chatbot --region $GCP_REGION --limit 20"
fi

echo ""
echo "🎉 Done! Your chatbot should be working now."
