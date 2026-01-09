#!/bin/bash

# Platform Setup Script
# Installs and configures CLI tools for GCP, AWS, and Akamai

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Platform Setup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "Detected OS: $MACHINE"
echo ""

# Check for Homebrew (Mac)
if [ "$MACHINE" = "Mac" ]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

# Install GCP CLI
echo -e "${GREEN}Checking GCP CLI (gcloud)...${NC}"
if ! command -v gcloud &> /dev/null; then
    echo "Installing gcloud..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install --cask google-cloud-sdk
    elif [ "$MACHINE" = "Linux" ]; then
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt-get update && sudo apt-get install google-cloud-sdk
    else
        echo "Please install gcloud manually: https://cloud.google.com/sdk/docs/install"
    fi
else
    echo "✓ gcloud already installed"
fi
echo ""

# Install AWS CLI
echo -e "${GREEN}Checking AWS CLI...${NC}"
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install awscli
    elif [ "$MACHINE" = "Linux" ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    else
        echo "Please install AWS CLI manually: https://aws.amazon.com/cli/"
    fi
else
    echo "✓ AWS CLI already installed"
fi
echo ""

# Install Docker
echo -e "${GREEN}Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Please install:"
    echo "  Mac: https://docs.docker.com/desktop/install/mac-install/"
    echo "  Linux: https://docs.docker.com/engine/install/"
else
    echo "✓ Docker already installed"
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        echo -e "${YELLOW}⚠ Docker is not running. Please start Docker Desktop.${NC}"
    else
        echo "✓ Docker is running"
    fi
fi
echo ""

# Install Python dependencies
echo -e "${GREEN}Checking Python dependencies...${NC}"
if command -v python3 &> /dev/null; then
    echo "Installing Python packages..."
    pip3 install requests --quiet || echo "pip install failed, install manually: pip install requests"
    echo "✓ Python dependencies ready"
else
    echo -e "${YELLOW}⚠ Python 3 not found${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Configure GCP: gcloud auth login"
echo "2. Configure AWS: aws configure"
echo "3. Get Akamai credentials from Control Center"
echo "4. Create .env.deploy file (see DEPLOYMENT_MASTER_GUIDE.md)"
echo "5. Run: ./deploy-all.sh"

