#!/bin/bash

# AIA Project - Quick Start Script
# This script starts both the AI backend and Flutter app

echo "🚀 Starting AIA Project System..."
echo "=================================="

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3 and try again."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is required but not installed."
    echo "Please install Flutter and try again."
    exit 1
fi

# Function to check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        return 0
    else
        return 1
    fi
}

# Check if backend is already running
if check_port 8000; then
    echo "⚠️  Backend server is already running on port 8000"
    echo "You can skip backend setup and just run Flutter."
    read -p "Do you want to start Flutter anyway? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📱 Starting Flutter app..."
        flutter run
        exit 0
    else
        echo "Exiting..."
        exit 0
    fi
fi

# Check if .env file exists
if [ ! -f "backend_ai/.env" ]; then
    echo "⚠️  Backend .env file not found!"
    echo "Creating .env file from template..."
    
    if [ -f "backend_ai/.env.example" ]; then
        cp backend_ai/.env.example backend_ai/.env
        echo "✅ Created .env file from template"
        echo ""
        echo "🔑 IMPORTANT: You need to add your OpenAI API key!"
        echo "Edit backend_ai/.env and add your OpenAI API key:"
        echo "OPENAI_API_KEY=your_openai_api_key_here"
        echo ""
        read -p "Press Enter after you've added your API key..."
    else
        echo "❌ .env.example file not found. Please create backend_ai/.env manually."
        exit 1
    fi
fi

# Start backend server in background
echo "🔧 Starting AI Backend Server..."
cd backend_ai

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Start the backend server
echo "🚀 Starting backend server on http://localhost:8000..."
python main.py --mode api &
BACKEND_PID=$!

# Wait a moment for server to start
sleep 3

# Check if backend started successfully
if check_port 8000; then
    echo "✅ Backend server started successfully!"
    echo "📖 API Documentation: http://localhost:8000/docs"
else
    echo "❌ Failed to start backend server"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Go back to root directory
cd ..

# Start Flutter app
echo ""
echo "📱 Starting Flutter app..."
echo "The app will show a beautiful cinematic intro, then transition to AI chat."
echo ""

# Install Flutter dependencies
flutter pub get

# Run Flutter app
flutter run

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Shutting down AIA system..."
    kill $BACKEND_PID 2>/dev/null
    echo "✅ Backend server stopped"
    echo "👋 Goodbye!"
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM
