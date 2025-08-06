"""
Ride Sharing Agent - Handles all ride sharing services (Uber, 99, Cabify, etc.)
"""

import controlflow as cf
from typing import Any, Dict, List
from models.intent import IntentModel
from tools.uber_tools import create_uber_deeplink


class RideSharingAgent:
    """Agent specialized in ride sharing services"""
    
    def __init__(self):
        self.name = "RideSharingAgent"
        
        # Available ride sharing providers
        self.providers = {
            "uber": {
                "name": "Uber",
                "deeplink_function": create_uber_deeplink,
                "available": True,
                "keywords": ["uber", "ride", "trip", "transport", "taxi", "car"]
            }
            # Future providers:
            # "99": {...},
            # "cabify": {...},
            # "lyft": {...}
        }
        
        # Default provider
        self.default_provider = "uber"
        
        # ControlFlow agent for intelligent processing
        self.agent = cf.Agent(
            name="RideSharingSpecialist",
            model="openai/gpt-4o-mini",
            instructions="""
            You are a specialized ride sharing agent with access to multiple transportation platforms.
            
            Your capabilities:
            1. **Multi-Platform Rides**: Create ride requests across different services
            2. **Smart Location Detection**: Extract origin and destination from user requests
            3. **Route Intelligence**: Handle location-based ride requests
            4. **Mobile-Optimized Deeplinks**: Return deeplinks that open ride apps
            
            Current available providers:
            - Uber: Primary ride sharing service
            
            Examples of queries you handle:
            - "Take me to the airport"
            - "I need a ride to downtown"
            - "Uber to shopping mall"
            - "Go from here to restaurant"
            - "Book a trip to the hotel"
            
            Always provide:
            - Clear ride request information
            - Mobile deeplink that opens the ride app
            - Estimated route information when possible
            
            Use the available ride sharing tools to create deeplinks and ride requests.
            """,
            tools=[create_uber_deeplink],
            interactive=True
        )
    
    def handle_request(self, user_input: str, intent: IntentModel, 
                      user_location: Dict[str, float] = None, 
                      preferred_provider: str = None) -> str:
        """
        Handle ride sharing requests
        
        Args:
            user_input: User's request
            intent: Parsed intent
            user_location: User's coordinates (optional)
            preferred_provider: Preferred ride service (optional)
            
        Returns:
            Formatted response with ride information
        """
        
        try:
            # Determine which provider to use
            provider = preferred_provider or self.default_provider
            
            if provider not in self.providers:
                provider = self.default_provider
            
            provider_info = self.providers[provider]
            
            if not provider_info["available"]:
                return self._handle_provider_unavailable(provider)
            
            # For Uber, we use the existing logic
            if provider == "uber":
                return self._handle_uber_request(user_input, user_location)
            
            # For future providers, implement their specific logic here
            else:
                return f"Provider {provider} is not yet implemented."
                
        except Exception as e:
            return self._handle_error(str(e), user_input)
    
    def _handle_uber_request(self, user_input: str, user_location: Dict[str, float] = None) -> str:
        """Handle Uber-specific ride request"""
        
        try:
            # Use ControlFlow to process the ride request
            result = cf.run(
                """
                Extract locations and create Uber deeplink. Return the complete tool result including the schema.
                
                IMPORTANT: After using the create_uber_deeplink tool, return the ENTIRE tool result as your response,
                including the 'schema' object with all the deeplink information.
                """,
                context={
                    "user_request": user_input,
                    "user_location": user_location
                },
                agents=[self.agent]
            )
            
            return self._format_ride_response(result, "Uber")
            
        except Exception as e:
            return self._handle_error(str(e), user_input)
    
    def _format_ride_response(self, result: str, provider_name: str) -> str:
        """Format the response for ride sharing results"""
        
        # The result from ControlFlow should already be formatted
        # We can add additional formatting if needed
        
        response_parts = [
            f"🚗 {provider_name} ride request created!",
            "",
            result,
            "",
            f"📱 **Mobile App Integration:**",
            f"The deeplink above will open the {provider_name} app on your mobile device with the ride pre-configured."
        ]
        
        return "\n".join(response_parts)
    
    def _handle_provider_unavailable(self, provider: str) -> str:
        """Handle case when provider is unavailable"""
        
        available_providers = [name for name, info in self.providers.items() if info["available"]]
        
        return (
            f"😅 {provider} is currently unavailable.\n\n"
            f"Available ride sharing services: {', '.join(available_providers)}\n\n"
            f"Would you like me to book a ride on {self.default_provider} instead?"
        )
    
    def _handle_error(self, error: str, user_input: str) -> str:
        """Handle errors gracefully"""
        
        return (
            f"😅 I had trouble processing your ride request.\n\n"
            f"Error: {error}\n\n"
            f"Please try again or rephrase your request. "
            f"For example: 'Take me to the airport' or 'Uber to downtown'."
        )
    
    def get_available_providers(self) -> List[Dict[str, Any]]:
        """Get list of available ride sharing providers"""
        
        return [
            {
                "name": info["name"],
                "key": key,
                "available": info["available"],
                "keywords": info["keywords"]
            }
            for key, info in self.providers.items()
        ]
    
    def create_ride_by_provider(self, origin: str, destination: str, provider: str,
                               user_location: Dict[str, float] = None) -> Dict[str, Any]:
        """Create a ride request using a specific provider"""
        
        if provider not in self.providers:
            return {
                "success": False,
                "error": f"Provider {provider} not available",
                "available_providers": list(self.providers.keys())
            }
        
        provider_info = self.providers[provider]
        
        if provider == "uber":
            # Use the Uber deeplink function
            deeplink_function = provider_info["deeplink_function"]
            
            try:
                result = deeplink_function(origin, destination)
                return {
                    "success": True,
                    "provider": provider,
                    "deeplink": result,
                    "origin": origin,
                    "destination": destination
                }
            except Exception as e:
                return {
                    "success": False,
                    "error": str(e),
                    "provider": provider
                }
        
        # For future providers
        else:
            return {
                "success": False,
                "error": f"Provider {provider} not yet implemented"
            }
