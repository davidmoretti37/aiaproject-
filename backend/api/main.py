import os
import sys
from dotenv import load_dotenv

# Load .env file from the root of the 'backend' directory
# This needs to be done before other modules are imported
dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path=dotenv_path)

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime

# Add the parent directory to the path so we can import from aia
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.orchestrator import aia_orchestrator

app = FastAPI(
    title="AIA - Intelligent Personal Assistant",
    description="Mobile-ready API for AIA with location-aware services",
    version="2.0.0"
)


class LocationModel(BaseModel):
    latitude: float = Field(..., description="User's latitude")
    longitude: float = Field(..., description="User's longitude")
    accuracy: Optional[float] = Field(None, description="Location accuracy in meters")


class ChatRequest(BaseModel):
    message: str
    user_id: Optional[str] = None
    session_id: Optional[str] = None
    location: Optional[LocationModel] = Field(None, description="User's current location from mobile app")


class ChatResponse(BaseModel):
    response: str
    intent_category: str
    agent_used: str
    success: bool
    data: Optional[Dict[str, Any]] = Field(None, description="Structured data for mobile app")


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Single endpoint that processes all user requests through the AIA orchestrator.
    Now supports location from mobile apps for location-aware services.
    """
    try:
        # Convert location to dict if provided by mobile app
        user_location = None
        if request.location:
            user_location = {
                "latitude": request.location.latitude,
                "longitude": request.location.longitude
            }
            print(f"📱 Mobile location received: {user_location}")
        
        # Process request through orchestrator with location
        result = await aia_orchestrator.process_request(
            user_input=request.message,
            user_id=request.user_id,
            user_location=user_location
        )
        
        # Extract structured data for mobile app if available
        structured_data = None
        response_text = result["response"]
        
        # Try to extract JSON data from response for mobile consumption
        if "```json" in response_text:
            try:
                import json
                json_start = response_text.find("```json") + 7
                json_end = response_text.find("```", json_start)
                json_str = response_text[json_start:json_end].strip()
                structured_data = json.loads(json_str)
            except Exception as e:
                print(f"⚠️ Could not parse JSON data: {e}")
        
        return ChatResponse(
            response=result["response"],
            intent_category=result["intent_category"],
            agent_used=result["agent_used"],
            success=result["success"],
            data=structured_data
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy", "service": "AIA Backend"}


@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "AIA - Intelligent Personal Assistant API",
        "version": "1.0.0",
        "endpoints": {
            "chat": "/chat - Main orchestrator endpoint",
            "health": "/health - Health check"
        }
    }


if __name__ == "__main__":
    import uvicorn
    from config.settings import get_settings
    
    settings = get_settings()
    uvicorn.run(
        "main:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=True
    )
