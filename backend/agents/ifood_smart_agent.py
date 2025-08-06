"""
iFood Smart Agent - Specialized agent for intelligent food delivery searches
Interprets user queries and returns mobile-optimized restaurant data
"""

import re
import json
import sys
import os
from typing import Dict, Any, List, Optional

# Add the parent directory to the path to import tools
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from tools.ifood_tools import search_ifood_restaurants


class IFoodSmartAgent:
    """Smart agent that interprets natural language queries for food delivery"""
    
    def __init__(self):
        self.name = "IFoodSmartAgent"
        
        # Food type mappings for better query interpretation
        self.food_mappings = {
            # Pizza variations
            "pizza": ["pizza", "pizzaria", "pizzas", "margherita", "calabresa"],
            
            # Burger variations
            "hamburguer": ["hamburguer", "hamburger", "burger", "lanche", "sanduiche", 
                          "x-burger", "x-salada", "big mac", "whopper"],
            
            # Japanese food
            "sushi": ["sushi", "japonesa", "japones", "temaki", "sashimi", "yakisoba", 
                     "udon", "ramen", "hossomaki"],
            
            # Italian food
            "italiana": ["italiana", "italiano", "macarrao", "pasta", "lasanha", 
                        "espaguete", "nhoque", "risotto"],
            
            # Chinese food
            "chinesa": ["chinesa", "chines", "yakisoba", "frango xadrez", "rolinho primavera"],
            
            # Mexican food
            "mexicana": ["mexicana", "mexicano", "burrito", "taco", "nachos", "quesadilla"],
            
            # Brazilian food
            "brasileira": ["brasileira", "brasileiro", "feijoada", "churrasco", "picanha", 
                          "farofa", "coxinha", "pao de acucar"],
            
            # Desserts
            "doce": ["doce", "sobremesa", "açai", "acai", "sorvete", "bolo", "torta", 
                    "pudim", "brigadeiro"],
            
            # Coffee
            "cafe": ["cafe", "café", "cafeteria", "cappuccino", "expresso", "latte"],
            
            # Healthy food
            "saudavel": ["saudavel", "saudável", "vegetariana", "vegetariano", "vegana", 
                        "vegano", "salada", "fitness", "light"],
            
            # Chicken
            "frango": ["frango", "chicken", "galeto", "asa", "coxa"],
            
            # Meat
            "carne": ["carne", "beef", "bife", "picanha", "alcatra", "maminha"],
            
            # Fish
            "peixe": ["peixe", "fish", "salmao", "salmão", "bacalhau", "tilapia"],
            
            # Fast food
            "fast food": ["fast food", "lanchonete", "delivery", "rapido", "rápido"]
        }
        
        # Location mappings for major Brazilian cities
        self.location_mappings = {
            "sao paulo": {"lat": -23.5505, "lng": -46.6333, "variations": ["sp", "sampa", "são paulo"]},
            "rio de janeiro": {"lat": -22.9068, "lng": -43.1729, "variations": ["rio", "rj", "cidade maravilhosa"]},
            "belo horizonte": {"lat": -19.9167, "lng": -43.9345, "variations": ["bh", "belô"]},
            "brasilia": {"lat": -15.7942, "lng": -47.8822, "variations": ["bsb", "df", "brasília"]},
            "salvador": {"lat": -12.9714, "lng": -38.5014, "variations": ["ssa", "bahia"]},
            "fortaleza": {"lat": -3.7319, "lng": -38.5267, "variations": ["ce", "ceará"]},
            "recife": {"lat": -8.0476, "lng": -34.8770, "variations": ["pe", "pernambuco"]},
            "porto alegre": {"lat": -30.0346, "lng": -51.2177, "variations": ["poa", "rs"]}
        }
    
    def extract_food_type(self, query: str) -> str:
        """Extract food type from user query using intelligent mapping"""
        query_lower = query.lower()
        
        # Direct mapping search
        for food_type, variations in self.food_mappings.items():
            for variation in variations:
                if variation in query_lower:
                    return food_type
        
        # If no direct match, extract meaningful words
        stop_words = {
            "o", "que", "tem", "para", "comer", "onde", "posso", "pedir", 
            "quero", "gostaria", "de", "um", "uma", "algum", "alguma",
            "disponivel", "disponível", "próximo", "proximo", "perto",
            "aqui", "ai", "aí", "me", "da", "do", "na", "no", "em",
            "por", "favor", "pfv", "agora", "hoje", "delivery", "entrega"
        }
        
        words = re.findall(r'\b\w+\b', query_lower)
        meaningful_words = [word for word in words if word not in stop_words and len(word) > 2]
        
        if meaningful_words:
            return meaningful_words[0]
        
        return "restaurante"  # Default fallback
    
    def extract_location(self, query: str) -> Optional[Dict[str, float]]:
        """Extract location from user query"""
        query_lower = query.lower()
        
        # Check for city names and variations
        for city, data in self.location_mappings.items():
            if city in query_lower:
                return {"lat": data["lat"], "lng": data["lng"]}
            
            for variation in data["variations"]:
                if variation in query_lower:
                    return {"lat": data["lat"], "lng": data["lng"]}
        
        # Look for location indicators
        location_patterns = [
            r"em\s+(\w+)",
            r"no\s+(\w+)",
            r"na\s+(\w+)",
            r"de\s+(\w+)",
            r"da\s+(\w+)",
            r"do\s+(\w+)"
        ]
        
        for pattern in location_patterns:
            match = re.search(pattern, query_lower)
            if match:
                potential_city = match.group(1)
                for city, data in self.location_mappings.items():
                    if potential_city in city or potential_city in data["variations"]:
                        return {"lat": data["lat"], "lng": data["lng"]}
        
        return None  # Will use default São Paulo coordinates
    
    def format_for_mobile(self, restaurants: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Format restaurant data specifically for mobile app display"""
        mobile_restaurants = []
        
        for restaurant in restaurants:
            mobile_restaurant = {
                "id": restaurant["id"],
                "name": restaurant["name"],
                "image": restaurant["image"],
                "deeplink": restaurant["deeplink"],
                "category": restaurant["category"],
                "rating": restaurant["rating"],
                "distance": restaurant["distance"],
                "delivery_fee": restaurant["delivery_fee"],
                "delivery_time": restaurant["delivery_time"],
                "available": restaurant["available"]
            }
            mobile_restaurants.append(mobile_restaurant)
        
        return mobile_restaurants
    
    def process_query(self, query: str, latitude: Optional[float] = None, 
                     longitude: Optional[float] = None, limit: int = 10) -> Dict[str, Any]:
        """
        Process user query and return mobile-optimized restaurant data
        
        Args:
            query: User's natural language query
            latitude: User's latitude (optional)
            longitude: User's longitude (optional)
            limit: Maximum number of results
            
        Returns:
            Formatted response for mobile app
        """
        
        try:
            # Extract food type from query
            food_type = self.extract_food_type(query)
            
            # Determine location
            if latitude is None or longitude is None:
                location = self.extract_location(query)
                if location:
                    latitude = location["lat"]
                    longitude = location["lng"]
                else:
                    # Default to São Paulo (IBGE coordinates)
                    latitude = -23.5982614
                    longitude = -46.6901653
            
            print(f"🤖 Agent interpreting: '{query}' -> food_type='{food_type}', location=({latitude}, {longitude})")
            
            # Search restaurants using the iFood service
            result = search_ifood_restaurants(food_type, latitude, longitude, limit)
            
            if result["success"] and result["data"]["restaurants"]:
                # Format response for mobile
                mobile_restaurants = self.format_for_mobile(result["data"]["restaurants"])
                
                return {
                    "success": True,
                    "message": f"Encontrei {len(mobile_restaurants)} opções de {food_type} para você!",
                    "query_interpretation": {
                        "original_query": query,
                        "food_type": food_type,
                        "location": {
                            "latitude": latitude,
                            "longitude": longitude
                        }
                    },
                    "restaurants": mobile_restaurants,
                    "total_count": len(mobile_restaurants)
                }
            else:
                return {
                    "success": False,
                    "message": f"Não encontrei restaurantes de {food_type} na sua região. Que tal tentar outro tipo de comida?",
                    "query_interpretation": {
                        "original_query": query,
                        "food_type": food_type,
                        "location": {
                            "latitude": latitude,
                            "longitude": longitude
                        }
                    },
                    "restaurants": [],
                    "total_count": 0,
                    "error": result.get("error", "Nenhum resultado encontrado")
                }
                
        except Exception as e:
            return {
                "success": False,
                "message": f"Ops! Tive um problema ao buscar restaurantes: {str(e)}",
                "query_interpretation": {
                    "original_query": query,
                    "food_type": "unknown",
                    "location": {
                        "latitude": latitude or -23.5505,
                        "longitude": longitude or -46.6333
                    }
                },
                "restaurants": [],
                "total_count": 0,
                "error": str(e)
            }


# Global instance
ifood_smart_agent = IFoodSmartAgent()


def search_food_with_ai(query: str, latitude: Optional[float] = None, 
                       longitude: Optional[float] = None, limit: int = 10) -> str:
    """
    Main function for AI-powered food search
    
    Args:
        query: User's natural language query about food
        latitude: User's latitude (optional)
        longitude: User's longitude (optional)
        limit: Maximum number of results
        
    Returns:
        JSON string with mobile-optimized restaurant data
    """
    
    result = ifood_smart_agent.process_query(query, latitude, longitude, limit)
    return json.dumps(result, ensure_ascii=False, indent=2)


# Example usage and testing
if __name__ == "__main__":
    # Test queries
    test_queries = [
        "O que tem disponível para comer hamburguer?",
        "Quero pizza próximo de mim",
        "Restaurantes de comida japonesa",
        "Onde posso pedir sushi em São Paulo?",
        "Comida italiana aqui perto",
        "Açaí por favor",
        "Quero um lanche rápido",
        "Tem alguma pizzaria boa?",
        "Preciso de comida saudável",
        "Café da manhã delivery"
    ]
    
    print("🧪 Testing iFood Smart Agent")
    print("=" * 50)
    
    for i, query in enumerate(test_queries, 1):
        print(f"\n🔍 Test {i}: {query}")
        result = search_food_with_ai(query, limit=3)
        
        # Parse and display key info
        data = json.loads(result)
        print(f"✅ Success: {data['success']}")
        print(f"📝 Message: {data['message']}")
        print(f"🍽️ Food Type: {data['query_interpretation']['food_type']}")
        print(f"🏪 Restaurants Found: {data['total_count']}")
        
        if data['restaurants']:
            print("   Top Results:")
            for j, restaurant in enumerate(data['restaurants'][:2], 1):
                print(f"   {j}. {restaurant['name']} - {restaurant['category']}")
                print(f"      Rating: {restaurant['rating']} | Distance: {restaurant['distance']}")
        
        print("-" * 30)
