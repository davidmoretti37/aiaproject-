"""
Calendar Agent - Handles all calendar-related services using Google Tools
"""

import controlflow as cf
from typing import Dict, Any
from tools.google_tools import create_calendar_event, list_calendar_events

class CalendarAgent:
    """Agent specialized in calendar services via Google Calendar"""
    
    def __init__(self):
        self.name = "CalendarAgent"
        
        # ControlFlow agent for intelligent calendar processing
        self.agent = cf.Agent(
            name="CalendarSpecialist",
            model="openai/gpt-4o-mini",
            tools=[create_calendar_event, list_calendar_events],
            instructions="""
            You are a specialized Google Calendar agent. Your capabilities are:
            1. **Create Events**: Schedule new events in the user's calendar.
            2. **List Events**: Retrieve and list upcoming events.
            
            When a user asks to create an event, you must confirm the title, start time, and end time before calling the `create_calendar_event` tool.
            When a user asks to see their schedule, use the `list_calendar_events` tool.
            
            You must always have an `access_token` to use any tool.
            """
        )

    async def process_message(self, message: str, access_token: str) -> Dict[str, Any]:
        """Process a message using the ControlFlow agent"""
        if not access_token:
            return {
                "message": "Authentication required. Please connect your Google account.",
                "agent_used": self.name,
                "metadata": {"type": "authentication_required"}
            }

        task = cf.Task(
            objective=message,
            agent=self.agent,
            context={"access_token": access_token}
        )
        result = await task.run()
        
        return {
            "message": result.content,
            "agent_used": self.name,
            "metadata": result.metadata
        }
