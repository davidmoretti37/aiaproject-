from pydantic import BaseModel
from typing import Optional, Dict, Any


class UberDeeplinkRequest(BaseModel):
    origin: str
    destination: str
    waypoint: Optional[str] = None
    product_id: Optional[str] = None


class UberDeeplinkSchema(BaseModel):
    type: str  # "uber_deeplink" or "uber_web_link"
    action: str  # "open_app" or "open_browser"
    url: str
    universal_link: Optional[str] = None
    origin: str
    destination: str
    waypoint: Optional[str] = None
    coordinates: Optional[Dict[str, Any]] = None


class UberDeeplinkResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Dict[str, Any]] = None
    schema: Optional[UberDeeplinkSchema] = None
    error: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "message": "Uber deeplink created for trip from 'Current Location' to 'rua alto noroeste'",
                "data": {
                    "origin": "Current Location",
                    "destination": "rua alto noroeste",
                    "deeplink": "uber://?action=setPickup&dropoff[formatted_address]=rua%20alto%20noroeste",
                    "instructions": "Use this deeplink to open the Uber app with pre-filled locations"
                },
                "schema": {
                    "type": "uber_deeplink",
                    "action": "open_app",
                    "url": "uber://?action=setPickup&dropoff[formatted_address]=rua%20alto%20noroeste",
                    "origin": "Current Location",
                    "destination": "rua alto noroeste",
                    "waypoint": None
                }
            }
        }


class LocationExtraction(BaseModel):
    origin: Optional[str] = None
    destination: Optional[str] = None
    confidence: float = 0.0
    needs_clarification: bool = False
    missing_fields: list = []
