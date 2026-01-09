#!/bin/bash
# CareerWise Quick Start Script
# Run this script to get everything set up and running

set -e  # Exit on error

echo "🚀 CareerWise Setup Script"
echo "=========================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "backend_api.py" ]; then
    echo "❌ Error: Please run this script from the careerwise_gemini_ntfy directory"
    echo "   cd 1_foundations/community_contributions/careerwise_gemini_ntfy"
    exit 1
fi

# Step 1: Check/create virtual environment
if [ ! -d ".venv" ]; then
    echo "📦 Creating virtual environment..."
    uv venv || python3 -m venv .venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
fi

# Step 2: Activate virtual environment
echo ""
echo "🔌 Activating virtual environment..."
source .venv/bin/activate

# Step 3: Install dependencies
if [ ! -f ".venv/bin/fastapi" ]; then
    echo ""
    echo "📥 Installing dependencies..."
    uv pip install -r requirements.txt || pip install -r requirements.txt
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${GREEN}✓ Dependencies already installed${NC}"
fi

# Step 4: Check for .env file
echo ""
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠ No .env file found${NC}"
    echo ""
    echo "Creating .env file template..."
    cat > .env << 'ENVEOF'
AI_PROVIDER=gemini
GOOGLE_API_KEY=AIzaSyA63Rf5L_mxOZvg2hBbwh9Wqa2kpgfC6ss
NTFY_TOPIC=
ENVEOF
    echo -e "${GREEN}✓ .env file created${NC}"
    echo ""
    echo -e "${YELLOW}⚠ IMPORTANT: Edit .env and add your Gemini API key!${NC}"
    echo "   Get one from: https://makersuite.google.com/app/apikey"
    echo ""
    read -p "Press Enter after you've added your API key to .env, or Ctrl+C to exit..."
else
    echo -e "${GREEN}✓ .env file found${NC}"
    
    # Check if API key is set
    if grep -q "your-api-key-here" .env 2>/dev/null || ! grep -q "GOOGLE_API_KEY=" .env 2>/dev/null; then
        echo -e "${YELLOW}⚠ Please make sure GOOGLE_API_KEY is set in .env${NC}"
    fi
fi

# Step 5: Run the server
echo ""
echo "🎯 Starting CareerWise API server..."
echo "   Server will run on: http://localhost:8080"
echo "   API docs available at: http://localhost:8080/docs"
echo ""
echo -e "${GREEN}Press Ctrl+C to stop the server${NC}"
echo ""

python3 backend_api.py
