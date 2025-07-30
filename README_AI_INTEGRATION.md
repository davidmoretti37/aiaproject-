# AIA AI Integration Guide

## 🤖 Overview

This guide covers the complete AI integration setup for the AIA (Artificial Intelligence Assistant) Flutter application, including backend server configuration, mobile app integration, and deployment instructions.

## 🏗️ Architecture

```
┌─────────────────┐    HTTP/HTTPS    ┌─────────────────┐    API Calls    ┌─────────────────┐
│   Flutter App   │ ◄──────────────► │   Node.js       │ ◄─────────────► │   OpenAI API    │
│   (Mobile)      │                  │   Server        │                 │   (GPT-4)       │
└─────────────────┘                  └─────────────────┘                 └─────────────────┘
```

## 🚀 Quick Setup

### 1. Prerequisites
- **Node.js 16+** installed
- **Flutter SDK** configured
- **OpenAI API Key** (get from [OpenAI Platform](https://platform.openai.com/))

### 2. Server Setup
```bash
# Install dependencies
npm install

# Set your OpenAI API key
export OPENAI_API_KEY="your-openai-api-key-here"

# Start the server
npm start
```

### 3. Flutter Configuration
```bash
# Add dependencies to pubspec.yaml
flutter pub get

# Run the app
flutter run
```

## 📱 Mobile App Integration

### Flutter Dependencies
The following packages are required in `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0           # HTTP client for API calls
  provider: ^6.1.1       # State management
  shared_preferences: ^2.2.2  # Local storage
```

### Key Components

#### 1. AI Service (`lib/ai_service.dart`)
- Handles HTTP communication with the backend
- Manages API endpoints and request formatting
- Implements error handling and retry logic

#### 2. Enhanced AI Chat Screen (`lib/enhanced_ai_chat_screen.dart`)
- Modern chat interface with message bubbles
- Real-time typing indicators
- Smooth animations and transitions

#### 3. Real-time AI Screen (`lib/realtime_ai_screen.dart`)
- Live chat functionality
- Session management
- Message history persistence

## 🔧 Server Configuration

### Environment Variables
Create a `.env` file or set environment variables:

```bash
OPENAI_API_KEY=your_openai_api_key_here
PORT=8000
NODE_ENV=development
```

### Server Features
- **Express.js** framework for robust HTTP handling
- **CORS** enabled for cross-origin requests
- **Session management** for conversation continuity
- **Health check** endpoint for monitoring
- **Graceful shutdown** handling

### API Endpoints

#### Health Check
```http
GET /health
```
Response:
```json
{
  "status": "healthy",
  "timestamp": "2025-07-30T13:00:00.000Z"
}
```

#### Chat Interaction
```http
POST /chat
Content-Type: application/json

{
  "message": "Hello, how are you?",
  "session_id": "optional_session_id",
  "user_id": "optional_user_id"
}
```

Response:
```json
{
  "message": "Hello! I'm doing well, thank you for asking. How can I help you today?",
  "session_id": "session_123",
  "timestamp": "2025-07-30T13:00:00.000Z"
}
```

#### Available Agents
```http
GET /agents
```
Response:
```json
[
  {
    "name": "AIA Assistant",
    "id": "aia_assistant",
    "description": "General purpose AI assistant"
  }
]
```

## 🔐 Security Configuration

### API Key Management
- **Never commit API keys** to version control
- Use **environment variables** for sensitive data
- Implement **key rotation** for production

### Network Security
- **HTTPS** for production deployment
- **Rate limiting** to prevent abuse
- **Input validation** on all endpoints

### iOS Configuration
Add to `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## 🚀 Deployment

### Local Development
```bash
# Terminal 1: Start the server
npm start

# Terminal 2: Run Flutter app
flutter run
```

### Production Deployment

#### Server Deployment (Heroku Example)
```bash
# Create Heroku app
heroku create aia-server

# Set environment variables
heroku config:set OPENAI_API_KEY=your_key_here

# Deploy
git push heroku main
```

#### Mobile App Deployment
```bash
# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

## 🧪 Testing

### Server Testing
```bash
# Test health endpoint
curl http://localhost:8000/health

# Test chat endpoint
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'
```

### Flutter Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Connection Refused
- **Check server is running** on correct port
- **Verify network permissions** in iOS/Android
- **Check firewall settings**

#### 2. API Key Errors
- **Verify API key is set** correctly
- **Check OpenAI account** has sufficient credits
- **Ensure key has proper permissions**

#### 3. CORS Issues
- **Verify CORS configuration** in server
- **Check request headers** from Flutter app
- **Test with browser developer tools**

### Debug Mode
Enable debug logging in Flutter:
```dart
// In main.dart
void main() {
  debugPrint('Starting AIA app...');
  runApp(MyApp());
}
```

## 📊 Performance Optimization

### Server Optimization
- **Connection pooling** for database connections
- **Response caching** for frequent requests
- **Compression** for large responses

### Mobile Optimization
- **Request batching** to reduce network calls
- **Local caching** of responses
- **Background processing** for non-critical tasks

## 🎯 Next Steps

### Planned Enhancements
1. **Voice Integration** - Speech-to-text and text-to-speech
2. **Offline Mode** - Local AI model for basic functionality
3. **Multi-language** - Support for multiple languages
4. **Custom Models** - Fine-tuned models for specific use cases

### Advanced Features
- **WebSocket** real-time communication
- **Push notifications** for important messages
- **Analytics** and usage tracking
- **A/B testing** for UI improvements

## 📚 Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Express.js Documentation](https://expressjs.com/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

---

*For technical support, please refer to the project documentation or create an issue in the repository.*
