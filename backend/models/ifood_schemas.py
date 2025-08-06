from pydantic import BaseModel
from typing import Optional, Dict, Any, List


class IFoodSearchRequest(BaseModel):
    term: str
    latitude: float
    longitude: float
    size: Optional[int] = 20


class RestaurantData(BaseModel):
    id: str
    name: str
    image: str
    distance: str
    rating: Optional[float]
    category: str
    delivery_fee: str
    delivery_time: str
    available: bool
    is_super_restaurant: bool
    is_ifood_delivery: bool
    action: str
    deeplink: str


class IFoodSearchResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "message": "Found 15 restaurants for 'pizza'",
                "data": {
                    "restaurants": [
                        {
                            "id": "27dbeb58-82d3-4a2b-b97d-a50651b84050",
                            "name": "McDonald's - Vila Olimpia",
                            "image": "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/27dbeb58-82d3-4a2b-b97d-a50651b84050/201908281546_bsFd_i.jpg",
                            "distance": "0.5 km",
                            "rating": 4.5,
                            "category": "Lanches",
                            "delivery_fee": "R$ 7,99",
                            "delivery_time": "40-50 min",
                            "available": True,
                            "is_super_restaurant": False,
                            "is_ifood_delivery": True,
                            "deeplink": "ifood://restaurant/27dbeb58-82d3-4a2b-b97d-a50651b84050"
                        }
                    ],
                    "search_term": "pizza",
                    "location": {
                        "latitude": -23.5975656,
                        "longitude": -46.6910611
                    },
                    "total_results": 15
                }
            }
        }


class LocationExtraction(BaseModel):
    term: Optional[str] = None
    user_location: Optional[Dict[str, float]] = None
    confidence: float = 0.0
    needs_clarification: bool = False
    missing_fields: list = []


class IFoodDeeplinkSchema(BaseModel):
    type: str  # "ifood_restaurant" or "ifood_search"
    action: str  # "open_restaurant" or "search_results"
    restaurant_id: Optional[str] = None
    restaurant_name: Optional[str] = None
    search_term: Optional[str] = None
    url: str
    coordinates: Optional[Dict[str, Any]] = None


class IFoodAgentResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Dict[str, Any]] = None
    schema: Optional[IFoodDeeplinkSchema] = None
    error: Optional[str] = None
