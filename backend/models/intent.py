from pydantic import BaseModel
from typing import List, Optional, Dict


class IntentModel(BaseModel):
    category: str  # "transportation", "communication", "general", etc.
    confidence: float  # 0.0 to 1.0
    keywords: List[str]  # identified keywords
    entities: Optional[Dict[str, str]] = None  # extracted entities
    
    class Config:
        schema_extra = {
            "example": {
                "category": "transportation",
                "confidence": 0.95,
                "keywords": ["uber", "ride", "trip"],
                "entities": {
                    "origin": "123 Main St",
                    "destination": "456 Oak Ave"
                }
            }
        }
