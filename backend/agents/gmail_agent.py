"""
Gmail Agent - Handles all email-related services using Google Tools
"""

import controlflow as cf
from typing import Dict, Any
from tools.google_tools import send_gmail_email, search_gmail_messages

class GmailAgent:
    """Agent specialized in email services via Gmail"""
    
    def __init__(self):
        self.name = "GmailAgent"
        
        # ControlFlow agent for intelligent email processing
        self.agent = cf.Agent(
            name="GmailSpecialist",
            model="openai/gpt-4o-mini",
            tools=[send_gmail_email, search_gmail_messages],
            instructions="""
            You are a specialized Gmail agent. Your capabilities are:
            1. **Send Emails**: Send emails on the user's behalf.
            2. **Search Emails**: Search for specific emails in the user's inbox.
            
            When a user asks to send an email, you must confirm the recipient, subject, and body before calling the `send_gmail_email` tool.
            When a user asks to search for emails, you must understand their query and use the `search_gmail_messages` tool.
            
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
