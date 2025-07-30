const express = require('express');
const cors = require('cors');
const { OpenAI } = require('openai');

const app = express();
const port = 8000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize OpenAI with your API key
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || 'your-api-key-here'
});

// Store conversation sessions
const sessions = new Map();

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Chat endpoint
app.post('/chat', async (req, res) => {
  try {
    const { message, session_id, user_id } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    // Get or create session
    const sessionKey = session_id || 'default';
    if (!sessions.has(sessionKey)) {
      sessions.set(sessionKey, [
        {
          role: 'system',
          content: 'You are AIA (Artificial Intelligence Assistant), a helpful, friendly, and intelligent AI assistant. You provide clear, concise, and helpful responses to user questions and requests. Keep your responses conversational and engaging.'
        }
      ]);
    }

    const conversation = sessions.get(sessionKey);
    
    // Add user message to conversation
    conversation.push({
      role: 'user',
      content: message
    });

    // Get AI response
    const completion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: conversation,
      max_tokens: 500,
      temperature: 0.7,
    });

    const aiResponse = completion.choices[0].message.content;
    
    // Add AI response to conversation
    conversation.push({
      role: 'assistant',
      content: aiResponse
    });

    // Keep conversation history manageable (last 20 messages)
    if (conversation.length > 21) {
      conversation.splice(1, 2); // Remove oldest user/assistant pair, keep system message
    }

    res.json({
      message: aiResponse,
      session_id: sessionKey,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ 
      error: 'Failed to process message',
      details: error.message 
    });
  }
});

// Get available agents (for compatibility)
app.get('/agents', (req, res) => {
  res.json([
    {
      name: 'AIA Assistant',
      id: 'aia_assistant',
      description: 'General purpose AI assistant'
    }
  ]);
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 AIA Server running on http://0.0.0.0:${port}`);
  console.log(`📡 Health check: http://192.168.3.54:${port}/health`);
  console.log(`💬 Chat endpoint: http://192.168.3.54:${port}/chat`);
  console.log(`🤖 Using OpenAI GPT-4 model`);
  console.log(`📱 iPhone can connect to: http://192.168.3.54:${port}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down AIA Server...');
  process.exit(0);
});
