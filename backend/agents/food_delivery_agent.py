"""
Food Delivery Agent - Handles all food delivery services (iFood, Uber Eats, Rappi, etc.)
"""

import controlflow as cf
from typing import Any, Dict, List
from models.intent import IntentModel
from tools.ifood_tools import search_ifood_restaurants


class FoodDeliveryAgent:
    """Agent specialized in food delivery services"""
    
    def __init__(self):
        self.name = "FoodDeliveryAgent"
        
        # Available food delivery providers
        self.providers = {
            "ifood": {
                "name": "iFood",
                "search_function": search_ifood_restaurants,
                "available": True,
                "keywords": ["ifood", "comida", "restaurante", "delivery", "entrega"]
            }
            # Future providers:
            # "uber_eats": {...},
            # "rappi": {...},
            # "99food": {...}
        }
        
        # Default provider
        self.default_provider = "ifood"
        
        # ControlFlow agent for intelligent processing
        self.agent = cf.Agent(
            name="FoodDeliverySpecialist",
            model="openai/gpt-4o-mini",
            instructions="""
            You are a specialized food delivery agent with access to multiple food delivery platforms.
            
            Your capabilities:
            1. **Multi-Platform Search**: Search across different food delivery services
            2. **Smart Food Detection**: Understand what type of food the user wants
            3. **Location Intelligence**: Handle location-based searches
            4. **Mobile-Optimized Results**: Return data perfect for mobile apps
            
            Current available providers:
            - iFood: Primary food delivery service in Brazil
            
            Examples of queries you handle:
            - "I want pizza nearby"
            - "Find hamburger restaurants"
            - "What's available for sushi delivery?"
            - "Show me Italian restaurants"
            - "Healthy food options"
            
            Always provide:
            - Restaurant name, image, and mobile deeplink
            - Rating, distance, delivery info
            - Clear, helpful responses about food options
            
            Use the available food delivery tools to search and return mobile-ready data.
            """,
            tools=[search_ifood_restaurants],
            interactive=True
        )
    
    def handle_request(self, user_input: str, intent: IntentModel, 
                      user_location: Dict[str, float] = None, 
                      preferred_provider: str = None) -> str:
        """
        Handle food delivery requests
        
        Args:
            user_input: User's request
            intent: Parsed intent
            user_location: User's coordinates (optional)
            preferred_provider: Preferred delivery service (optional)
            
        Returns:
            Formatted response with restaurant options
        """
        
        try:
            # Determine which provider to use
            provider = preferred_provider or self.default_provider
            
            if provider not in self.providers:
                provider = self.default_provider
            
            provider_info = self.providers[provider]
            
            if not provider_info["available"]:
                return self._handle_provider_unavailable(provider)
            
            # Extract location coordinates
            latitude = None
            longitude = None
            
            if user_location:
                latitude = user_location.get("latitude")
                longitude = user_location.get("longitude")
                print(f"🌍 Using provided user location: {latitude}, {longitude}")
            else:
                print("📍 No user location provided, using provider's default location detection")
            
            # Use the provider's search function
            search_function = provider_info["search_function"]
            
            # For iFood, we use the smart agent approach
            if provider == "ifood":
                return self._handle_ifood_search(user_input, latitude, longitude)
            
            # For future providers, implement their specific logic here
            else:
                return f"Provider {provider} is not yet implemented."
                
        except Exception as e:
            return self._handle_error(str(e), user_input)
    
    def _handle_ifood_search(self, user_input: str, latitude: float = None, 
                           longitude: float = None) -> str:
        """Handle iFood-specific search using the smart agent"""
        
        # Import the smart agent
        from agents.ifood_smart_agent import ifood_smart_agent
        
        try:
            # Use the smart agent to process the query with increased limit
            result = ifood_smart_agent.process_query(
                query=user_input,
                latitude=latitude,
                longitude=longitude,
                limit=50  # Increased from 10 to 50 to get more restaurants
            )
            
            if result["success"] and result["restaurants"]:
                return self._format_food_delivery_response(result, "iFood")
            else:
                return self._handle_no_results(result, "iFood")
                
        except Exception as e:
            return self._handle_error(str(e), user_input)
    
    def _format_food_delivery_response(self, result: Dict[str, Any], provider_name: str) -> str:
        """Format the response for food delivery results"""
        
        restaurants = result["restaurants"]
        total_count = result["total_count"]
        food_type = result["query_interpretation"]["food_type"]
        
        # Create a conversational response
        response_parts = [
            f"🍽️ Found {total_count} {food_type} options on {provider_name}!",
            f"\nHere are the top restaurants:",
        ]
        
        # Add top restaurants
        for i, restaurant in enumerate(restaurants[:5], 1):
            response_parts.append(
                f"\n{i}. **{restaurant['name']}**"
                f"\n   ⭐ {restaurant['rating']} | 📍 {restaurant['distance']} | 💰 {restaurant['delivery_fee']}"
                f"\n   ⏱️ {restaurant['delivery_time']} | 🏷️ {restaurant['category']}"
                f"\n   📱 [Open in {provider_name}]({restaurant['deeplink']})"
            )
        
        if total_count > 5:
            response_parts.append(f"\n... and {total_count - 5} more options available!")
        
        # Add mobile app data - return ALL restaurants, not just 3
        response_parts.append(f"\n\n📱 **Mobile App Data:**")
        response_parts.append(f"```json")
        response_parts.append(f"{{")
        response_parts.append(f"  \"success\": true,")
        response_parts.append(f"  \"provider\": \"{provider_name.lower()}\",")
        response_parts.append(f"  \"total_count\": {total_count},")
        response_parts.append(f"  \"food_type\": \"{food_type}\",")
        response_parts.append(f"  \"restaurants\": [")
        
        # Return ALL restaurants instead of limiting to 3
        for i, restaurant in enumerate(restaurants):
            comma = "," if i < len(restaurants) - 1 else ""
            response_parts.append(f"    {{")
            response_parts.append(f"      \"id\": \"{restaurant['id']}\",")
            response_parts.append(f"      \"name\": \"{restaurant['name']}\",")
            response_parts.append(f"      \"image\": \"{restaurant['image']}\",")
            response_parts.append(f"      \"deeplink\": \"{restaurant['deeplink']}\",")
            response_parts.append(f"      \"rating\": {restaurant['rating']},")
            response_parts.append(f"      \"distance\": \"{restaurant['distance']}\",")
            response_parts.append(f"      \"delivery_fee\": \"{restaurant['delivery_fee']}\"")
            response_parts.append(f"    }}{comma}")
        
        response_parts.append(f"  ]")
        response_parts.append(f"}}")
        response_parts.append(f"```")
        
        return "\n".join(response_parts)
    
    def _handle_no_results(self, result: Dict[str, Any], provider_name: str) -> str:
        """Handle case when no restaurants are found"""
        
        food_type = result.get("query_interpretation", {}).get("food_type", "food")
        
        return (
            f"😔 No {food_type} restaurants found on {provider_name} in your area.\n\n"
            f"Try:\n"
            f"• A different type of cuisine\n"
            f"• Expanding your search area\n"
            f"• Checking if restaurants are open now\n\n"
            f"What other type of food would you like? 🍕🍔🍣"
        )
    
    def _handle_provider_unavailable(self, provider: str) -> str:
        """Handle case when provider is unavailable"""
        
        available_providers = [name for name, info in self.providers.items() if info["available"]]
        
        return (
            f"😅 {provider} is currently unavailable.\n\n"
            f"Available food delivery services: {', '.join(available_providers)}\n\n"
            f"Would you like me to search on {self.default_provider} instead?"
        )
    
    def _handle_error(self, error: str, user_input: str) -> str:
        """Handle errors gracefully"""
        
        return (
            f"😅 I had trouble processing your food delivery request.\n\n"
            f"Error: {error}\n\n"
            f"Please try again or rephrase your request. "
            f"For example: 'I want pizza' or 'Find hamburger restaurants'."
        )
    
    def get_available_providers(self) -> List[Dict[str, Any]]:
        """Get list of available food delivery providers"""
        
        return [
            {
                "name": info["name"],
                "key": key,
                "available": info["available"],
                "keywords": info["keywords"]
            }
            for key, info in self.providers.items()
        ]
    
    def search_by_provider(self, query: str, provider: str, latitude: float = None, 
                          longitude: float = None) -> Dict[str, Any]:
        """Search using a specific provider"""
        
        if provider not in self.providers:
            return {
                "success": False,
                "error": f"Provider {provider} not available",
                "available_providers": list(self.providers.keys())
            }
        
        provider_info = self.providers[provider]
        search_function = provider_info["search_function"]
        
        # Use default coordinates if not provided
        if latitude is None or longitude is None:
            # São Paulo IBGE coordinates
            latitude = -23.5982614
            longitude = -46.6901653
        
        return search_function(query, latitude, longitude)
