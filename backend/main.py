import sys
import os
import uvicorn
from fastapi import FastAPI, Request, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any
from dotenv import load_dotenv

load_dotenv()

# Add the current directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Load settings and orchestrator
from config.settings import get_settings
from core.orchestrator import AIAOrchestrator

# Initialize
settings = get_settings()
aia_orchestrator = AIAOrchestrator()

app = FastAPI(
    title="AIA - Intelligent Personal Assistant API",
    description="API for the AIA personal assistant, powered by ControlFlow.",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Pydantic models for request/response bodies
class ChatMessage(BaseModel):
    message: str
    user_id: Optional[str] = None
    location: Optional[Dict[str, float]] = None

@app.get("/", tags=["Status"])
async def root():
    """Root endpoint for health checks."""
    return {"status": "ok", "message": "AIA API is running"}

@app.get("/health", tags=["Status"])
async def health():
    """Health check endpoint for mobile app connectivity."""
    return {"status": "healthy", "service": "AIA Backend"}

@app.get("/agents", tags=["Agents"])
async def get_agents():
    """Returns a list of available agents and their capabilities."""
    return aia_orchestrator.available_agents

@app.post("/chat", tags=["Chat"])
async def chat(chat_message: ChatMessage, authorization: Optional[str] = Header(None)):
    """Processes a user's chat message and routes it to the appropriate agent."""
    google_access_token = None
    if authorization and authorization.startswith("Bearer "):
        google_access_token = authorization.split("Bearer ")[1]

    try:
        result = await aia_orchestrator.process_request(
            user_input=chat_message.message,
            user_id=chat_message.user_id,
            user_location=chat_message.location,
            google_access_token=google_access_token
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
