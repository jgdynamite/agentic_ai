#!/bin/bash
# Script to delete CareerWise GCP Cloud Run deployment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🗑️  Delete CareerWise GCP Deployment"
echo "===================================="
echo ""

# Load environment variables if .env exists
if [ -f ".env" ]; then
    source .env
fi

# Set defaults
GCP_PROJECT_ID=${GCP_PROJECT_ID:-"careerwise-chatbot"}
GCP_REGION=${GCP_REGION:-"us-central1"}
SERVICE_NAME="careerwise-chatbot"

echo "Service: $SERVICE_NAME"
echo "Region: $GCP_REGION"
echo "Project: $GCP_PROJECT_ID"
echo ""

# Confirm deletion
read -p "⚠️  Are you sure you want to delete the Cloud Run service? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deletion cancelled."
    exit 0
fi

echo ""
echo "🗑️  Deleting Cloud Run service..."

# Delete the service
gcloud run services delete "$SERVICE_NAME" \
    --region "$GCP_REGION" \
    --project "$GCP_PROJECT_ID" \
    --quiet

echo -e "${GREEN}✓ Cloud Run service deleted${NC}"

echo ""
echo "Do you also want to delete the Artifact Registry repository? (yes/no)"
read -p "This will delete the Docker images: " delete_repo

if [ "$delete_repo" = "yes" ]; then
    echo ""
    echo "🗑️  Deleting Artifact Registry repositories..."
    
    # Delete the source deploy repo (created automatically)
    gcloud artifacts repositories delete cloud-run-source-deploy \
        --location "$GCP_REGION" \
        --project "$GCP_PROJECT_ID" \
        --quiet 2>/dev/null || echo "cloud-run-source-deploy repo not found or already deleted"
    
    # Delete the custom repo
    gcloud artifacts repositories delete careerwise-repo \
        --location "$GCP_REGION" \
        --project "$GCP_PROJECT_ID" \
        --quiet 2>/dev/null || echo "careerwise-repo not found or already deleted"
    
    echo -e "${GREEN}✓ Artifact Registry repositories deleted${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Cleanup Complete!${NC}"
echo "=========================================="
echo ""
echo "Deleted:"
echo "  ✓ Cloud Run service: $SERVICE_NAME"
if [ "$delete_repo" = "yes" ]; then
    echo "  ✓ Artifact Registry repositories"
fi
echo ""
echo "Note: You may still incur charges for:"
echo "  - Storage (if images weren't deleted)"
echo "  - Any requests made before deletion"
echo "  - Check your GCP billing dashboard"
