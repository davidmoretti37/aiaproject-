#!/bin/bash

# AIA System Startup Script
# This script starts the complete AIA system including the AI server and Flutter app

echo "🚀 Starting AIA (Artificial Intelligence Assistant) System..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a port is in use
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command_exists node; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 16+ first.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}❌ npm is not installed. Please install npm first.${NC}"
    exit 1
fi

if ! command_exists flutter; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter SDK first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites are installed${NC}"

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo -e "${YELLOW}⚠️  Warning: Node.js version is $NODE_VERSION. Recommended version is 16+${NC}"
fi

# Check if OpenAI API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  Warning: OPENAI_API_KEY environment variable is not set${NC}"
    echo -e "${YELLOW}   You can set it with: export OPENAI_API_KEY='your-key-here'${NC}"
    echo -e "${YELLOW}   Or create a .env file with: OPENAI_API_KEY=your-key-here${NC}"
fi

# Check if port 8000 is available
if port_in_use 8000; then
    echo -e "${YELLOW}⚠️  Warning: Port 8000 is already in use${NC}"
    echo -e "${YELLOW}   Please stop the process using port 8000 or change the port in simple_ai_server.js${NC}"
fi

# Install Node.js dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}📦 Installing Node.js dependencies...${NC}"
    npm install
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install Node.js dependencies${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Node.js dependencies installed${NC}"
else
    echo -e "${GREEN}✅ Node.js dependencies already installed${NC}"
fi

# Install Flutter dependencies
echo -e "${BLUE}📱 Installing Flutter dependencies...${NC}"
flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install Flutter dependencies${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter dependencies installed${NC}"

# Start the AI server in background
echo -e "${BLUE}🤖 Starting AI Server...${NC}"
npm start &
SERVER_PID=$!

# Wait a moment for server to start
sleep 3

# Check if server started successfully
if ! port_in_use 8000; then
    echo -e "${RED}❌ Failed to start AI server on port 8000${NC}"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

echo -e "${GREEN}✅ AI Server started successfully on port 8000${NC}"
echo -e "${GREEN}   Server PID: $SERVER_PID${NC}"

# Test server health
echo -e "${BLUE}🔍 Testing server health...${NC}"
HEALTH_CHECK=$(curl -s http://localhost:8000/health 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Server health check passed${NC}"
    echo -e "${GREEN}   Response: $HEALTH_CHECK${NC}"
else
    echo -e "${YELLOW}⚠️  Server health check failed, but server might still be starting...${NC}"
fi

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down AIA system...${NC}"
    if [ ! -z "$SERVER_PID" ]; then
        echo -e "${BLUE}   Stopping AI server (PID: $SERVER_PID)...${NC}"
        kill $SERVER_PID 2>/dev/null
        wait $SERVER_PID 2>/dev/null
    fi
    echo -e "${GREEN}✅ AIA system shutdown complete${NC}"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start Flutter app
echo -e "${BLUE}📱 Starting Flutter app...${NC}"
echo -e "${YELLOW}   Note: This will open the Flutter app. Use Ctrl+C to stop both server and app.${NC}"
echo -e "${YELLOW}   Server logs will be shown in the background.${NC}"
echo ""
echo -e "${GREEN}🎉 AIA System is now running!${NC}"
echo -e "${GREEN}   - AI Server: http://localhost:8000${NC}"
echo -e "${GREEN}   - Health Check: http://localhost:8000/health${NC}"
echo -e "${GREEN}   - Flutter App: Starting...${NC}"
echo ""

# Start Flutter app (this will block until app is closed)
flutter run

# If we reach here, Flutter app was closed
cleanup
