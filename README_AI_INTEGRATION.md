# AIA Project - AI Backend Integration

This document explains how to use the integrated AI backend system with the Flutter app.

## Overview

The AIA project now includes a sophisticated multi-agent AI backend that integrates seamlessly with the beautiful Flutter animations. The system provides:

- **Multi-Agent AI System**: Different specialized AI agents for various tasks
- **Beautiful UI Integration**: AI chat interface with animated orb and fog effects
- **Seamless Transitions**: From cinematic intro to AI chat experience

## Architecture

### Backend (Python)
- **Location**: `backend_ai/`
- **Framework**: FastAPI with SOLID principles
- **Features**: 
  - Agent orchestrator for routing requests
  - Multiple specialized AI agents
  - RESTful API endpoints
  - Session management

### Frontend (Flutter)
- **Enhanced AI Chat Screen**: Beautiful chat interface with animations
- **AI Service**: HTTP client for backend communication
- **Cinematic Flow**: Intro sequence → AI chat transition

## Setup Instructions

### 1. Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend_ai
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key:
   # OPENAI_API_KEY=your_openai_api_key_here
   ```

4. **Start the server**:
   ```bash
   python main.py --mode api
   ```
   
   The server will be available at: `http://localhost:8000`
   API Documentation: `http://localhost:8000/docs`

### 2. Flutter Setup

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

## Usage Flow

1. **Cinematic Intro**: App starts with beautiful AIA text animation and forest background
2. **Zoom Transition**: Dramatic zoom with fog effects
3. **Orb Reveal**: Animated orb appears with particle effects
4. **AI Chat**: Automatic transition to AI chat interface
5. **Interactive Chat**: Chat with AI agents through beautiful interface

## API Endpoints

### Main Chat Endpoint
```
POST /chat
{
  "message": "Your message here",
  "session_id": "optional_session_id",
  "user_id": "optional_user_id"
}
```

### Get Available Agents
```
GET /agents
```

### Health Check
```
GET /health
```

### Direct Agent Chat
```
POST /agents/{agent_id}/chat
```

## Features

### AI Backend Features
- **Intelligent Routing**: Automatically selects the best agent for each request
- **Session Management**: Maintains conversation context
- **Error Handling**: Graceful error handling and recovery
- **Logging**: Comprehensive logging for debugging

### Flutter Features
- **Connection Status**: Real-time server connection indicator
- **Animated Orb**: Responsive orb that reacts to AI activity
- **Fog Effects**: Beautiful background fog animations
- **Message Bubbles**: Smooth animated message appearance
- **Typing Indicators**: Loading states during AI processing

## Customization

### Adding New AI Agents
1. Create agent class in `backend_ai/src/agents/`
2. Register in `backend_ai/src/factory/agent_factory.py`
3. Agent will be automatically available via API

### Modifying UI
- **Colors**: Update color schemes in `enhanced_ai_chat_screen.dart`
- **Animations**: Modify animation parameters in orb and fog components
- **Layout**: Customize chat bubble styles and layouts

## Troubleshooting

### Backend Issues
- **Port conflicts**: Change `API_PORT` in `.env` file
- **API key errors**: Ensure valid OpenAI API key in `.env`
- **Dependencies**: Run `pip install -r requirements.txt`

### Flutter Issues
- **Connection errors**: Ensure backend server is running on localhost:8000
- **Animation issues**: Check asset files are properly included
- **Build errors**: Run `flutter clean && flutter pub get`

## Development

### Backend Development
```bash
# Run in CLI mode for testing
python main.py --mode cli

# Run with auto-reload
uvicorn src.api.main:app --reload --host 0.0.0.0 --port 8000
```

### Flutter Development
```bash
# Hot reload during development
flutter run

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

## Next Steps

1. **Add Voice Integration**: Implement speech-to-text and text-to-speech
2. **Enhanced Agents**: Add more specialized AI agents
3. **Cloud Deployment**: Deploy backend to cloud services
4. **Advanced Animations**: Add more interactive animations
5. **User Profiles**: Implement user authentication and profiles

## Support

For issues or questions:
1. Check the API documentation at `http://localhost:8000/docs`
2. Review logs in `backend_ai/logs/`
3. Test individual components in isolation
4. Ensure all dependencies are properly installed

---

**Note**: This integration demonstrates a complete AI-powered application with beautiful animations and robust backend architecture. The system is designed to be extensible and maintainable following SOLID principles.
