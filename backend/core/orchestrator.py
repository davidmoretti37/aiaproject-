import controlflow as cf
from typing import Optional, Dict, Any, List
from models.intent import IntentModel
from agents.ride_sharing_agent import RideSharingAgent
from agents.food_delivery_agent import FoodDeliveryAgent
from agents.gmail_agent import GmailAgent
from agents.calendar_agent import CalendarAgent
from config.settings import get_settings

# Load settings to ensure environment variables are set
settings = get_settings()


class AIAOrchestrator:
    def __init__(self):
        # Initialize specialized agents
        self.ride_sharing_agent = RideSharingAgent()
        self.food_delivery_agent = FoodDeliveryAgent()
        self.gmail_agent = GmailAgent()
        self.calendar_agent = CalendarAgent()
        
        # Registry of available agents with their capabilities
        self.available_agents = {
            "RideSharingAgent": {
                "agent": self.ride_sharing_agent,
                "description": "Handles transportation requests across multiple ride sharing platforms (Uber, 99, Cabify, etc.)",
                "keywords": ["uber", "ride", "trip", "transport", "go to", "pick me up", "take me to", "travel", "taxi", "car", "99", "cabify"],
                "capabilities": ["multi-platform rides", "location extraction", "deeplink creation", "transportation planning"]
            },
            "FoodDeliveryAgent": {
                "agent": self.food_delivery_agent,
                "description": "Searches restaurants and food options across multiple delivery platforms (iFood, Uber Eats, Rappi, etc.)",
                "keywords": ["ifood", "food", "restaurant", "pizza", "hamburguer", "sushi", "comida", "restaurante", "pedir", "delivery", "entrega", "almoço", "jantar", "lanche", "uber eats", "rappi"],
                "capabilities": ["multi-platform food search", "restaurant discovery", "mobile deeplinks", "location-based search"]
            },
            "GmailAgent": {
                "agent": self.gmail_agent,
                "description": "Manages emails via Gmail, including sending and searching for messages.",
                "keywords": ["email", "gmail", "send", "message", "mail", "inbox"],
                "capabilities": ["send email", "search emails"]
            },
            "CalendarAgent": {
                "agent": self.calendar_agent,
                "description": "Manages Google Calendar, including creating and listing events.",
                "keywords": ["calendar", "event", "schedule", "meeting", "appointment"],
                "capabilities": ["create event", "list events"]
            },
            "TravelAgent": {
                "agent": None,  # Will be integrated with AIA backend
                "description": "Professional travel agent with comprehensive flight services via Amadeus API. Handles flight search, booking reservations, seat selection, status tracking, delay predictions, and complete travel planning with real-time data for destinations worldwide.",
                "keywords": ["flight", "voo", "viagem", "travel", "airplane", "avião", "booking", "reserva", "amadeus", "airport", "aeroporto", "ticket", "passagem", "trip", "destination", "destino", "hotel", "accommodation"],
                "capabilities": ["flight search with natural language", "real flight bookings", "seat map selection", "flight status tracking", "delay prediction with ML", "airport information", "travel planning", "itinerary creation"]
            },
            "VehicleAgent": {
                "agent": None,  # Will be integrated with AIA backend
                "description": "Expert automotive assistant specializing in Brazilian vehicle information, FIPE pricing, vehicle lookup, brand and model data, market values, RENAVAM consultation, and vehicle debt checking. Provides accurate vehicle pricing and specifications using official FIPE and government data sources.",
                "keywords": ["carro", "vehicle", "car", "fipe", "preço", "price", "veiculo", "placa", "plate", "renavam", "debito", "debt", "ipva", "multa", "fine", "detran", "licenciamento", "automotive", "automotivo"],
                "capabilities": ["FIPE pricing consultation", "RENAVAM official data lookup", "automatic debt verification", "vehicle plate validation", "Brazilian vehicle information", "IPVA and fines checking", "market value assessment", "vehicle specifications"]
            },
            "ReminderAgent": {
                "agent": None,  # Will be integrated with AIA backend
                "description": "Specialized agent for creating and managing reminders for important dates and events. Supports flexible time configurations and provides clear confirmation messages.",
                "keywords": ["reminder", "lembrete", "remind", "lembrar", "alert", "alerta", "notification", "notificação", "schedule", "agendar", "time", "tempo", "date", "data"],
                "capabilities": ["create reminders", "list active reminders", "cancel reminders", "flexible time settings (days/minutes/seconds)", "clear confirmations"]
            },
            "WhatsAppAgent": {
                "agent": None,  # Will be integrated with AIA backend
                "description": "WhatsApp automation specialist for messaging, group management, and advanced communication features. Supports complete WhatsApp API integration including session management, media sharing, and group operations.",
                "keywords": ["whatsapp", "message", "mensagem", "chat", "grupo", "group", "automation", "automação", "send", "enviar", "contact", "contato", "media", "mídia", "status"],
                "capabilities": ["WhatsApp session management", "send messages and media", "group creation and management", "contact verification", "location sharing", "message reactions", "presence status", "QR code authentication", "phone pairing"]
            }
        }
        
        # Single orchestrator agent
        self.orchestrator = cf.Agent(
            name="AIA_Orchestrator",
            model="openai/gpt-4o-mini",
            instructions=f"""
            You are AIA, an intelligent personal assistant. Your responsibilities:
            1. Analyze user requests and understand their intent
            2. Select the most appropriate specialized agent to handle the request
            3. Delegate the task to the chosen agent
            4. Provide clear, helpful responses to users
            
            Available specialized agents:
            {self._format_agent_descriptions()}
            
            Your decision process:
            1. Analyze the user's request
            2. Identify which agent is best suited for the task
            3. Choose the agent that matches the request intent
            4. If no specialized agent matches, handle the request yourself
            
            Always be helpful, professional, and choose the most appropriate agent for each task.
            """,
            interactive=True
        )
    
    def _get_agent_info_for_selection(self) -> str:
        """Formats agent information for the selection prompt."""
        agent_info = []
        for agent_name, info in self.available_agents.items():
            agent_info.append(
                f"- Agent: {agent_name}\n"
                f"  Description: {info['description']}\n"
                f"  Keywords: {', '.join(info['keywords'])}"
            )
        return "\n".join(agent_info)

    def _format_agent_descriptions(self) -> str:
        """Format agent descriptions for the orchestrator's instructions"""
        descriptions = []
        for agent_name, info in self.available_agents.items():
            descriptions.append(f"- {agent_name}: {info['description']}")
        return "\n            ".join(descriptions)
    
    @cf.flow
    async def process_request(self, user_input: str, user_id: Optional[str] = None, 
                             user_location: Optional[Dict[str, float]] = None, 
                             google_access_token: Optional[str] = None) -> Dict[str, Any]:
        """Main flow to process user requests with optional location"""
        
        # Step 1: Classify intent and select appropriate agent
        agent_selection = cf.run(
            f"""
            Analyze the user's request and determine which agent should handle it.
            
            Available agents and their capabilities:
            {self._get_agent_info_for_selection()}
            
            Based on the user's request, decide:
            1. Which agent is most suitable for this task
            2. What category this request falls into
            3. Return the agent name that should handle this request
            
            If no specialized agent is suitable, return "AIA_Orchestrator" to handle it yourself.
            """,
            context={
                "user_request": user_input,
                "available_agents": list(self.available_agents.keys()),
                "user_location": user_location
            },
            result_type=str,  # Returns the agent name
            agents=[self.orchestrator]
        )
        
        # Step 2: Delegate to the selected agent
        if agent_selection in self.available_agents:
            # Delegate to specialized agent
            selected_agent_info = self.available_agents[agent_selection]
            selected_agent = selected_agent_info["agent"]
            
            # Delegate to the appropriate agent and get the result
            if agent_selection in ["GmailAgent", "CalendarAgent"]:
                # For Google agents, call the process_message method directly
                result = await selected_agent.process_message(user_input, google_access_token)
            else:
                # For other agents, run a standard ControlFlow task
                agent_task = cf.Task(
                    objective=user_input,
                    context={"user_location": user_location, "user_id": user_id},
                    agent=selected_agent.agent
                )
                task_result = await agent_task.run()
                # Structure the result to be consistent with other agents
                result = {
                    "response": task_result.content,
                    "agent_used": agent_selection,
                    "intent_category": agent_selection,
                    "success": True,
                    "metadata": task_result.metadata,
                }
            
            # Ensure the final dictionary has all the necessary keys for ChatResponse
            final_result = {
                "response": result.get("message") or result.get("response", ""),
                "agent_used": result.get("agent_used", "Unknown"),
                "intent_category": result.get("intent_category", "Unknown"),
                "success": result.get("success", False),
                "data": result.get("metadata"),
            }
            return final_result
        else:
            # Handle with orchestrator directly
            response = cf.run(
                """
                Provide a helpful response to the user's request. 
                Be informative, friendly, and conversational.
                Try to be as useful as possible within your capabilities.
                """,
                context={
                    "user_request": user_input,
                    "user_id": user_id,
                    "user_location": user_location
                },
                agents=[self.orchestrator]
            )
            
            return {
                "response": response,
                "intent_category": "general",
                "agent_used": "AIA_Orchestrator",
                "success": True
            }
    
    def _get_agent_info_for_selection(self) -> str:
        """Get formatted agent information for selection process"""
        info_lines = []
        for agent_name, info in self.available_agents.items():
            keywords_str = ", ".join(info["keywords"])
            info_lines.append(f"- {agent_name}: {info['description']} (Keywords: {keywords_str})")
        return "\n            ".join(info_lines)


# Global instance
aia_orchestrator = AIAOrchestrator()
