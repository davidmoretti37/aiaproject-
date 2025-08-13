"""
Reminder Agent for AIA system with Supabase database integration.
"""

import os
import controlflow as cf
from typing import Dict, Any, Optional
from datetime import datetime, timedelta
import re
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()


class ReminderAgent:
    """
    Reminder Agent that integrates with Supabase database.
    """
    
    def __init__(self):
        self.agent = cf.Agent(
            name="ReminderAgent",
            model="openai/gpt-4o-mini",
            instructions="""
            You are a specialized reminder assistant. Your responsibilities:
            
            1. Create reminders for users with specific dates and times
            2. List active reminders for users
            3. Cancel reminders when requested
            4. Parse natural language time expressions (e.g., "in 2 hours", "tomorrow at 3pm", "next Monday")
            
            When creating reminders:
            - Always confirm the reminder details with the user
            - Store reminders in the database linked to the user ID
            - Support flexible time formats and natural language
            - Provide clear confirmation messages
            
            Available functions:
            - create_reminder(user_id, event_name, reminder_datetime)
            - list_user_reminders(user_id)
            - cancel_reminder(user_id, reminder_id)
            
            Always be helpful and confirm the reminder details clearly.
            """,
            interactive=True
        )
        
        # Initialize Supabase client
        try:
            supabase_url = os.getenv('SUPABASE_URL', 'https://xkkxylouvyjdymnpxzld.supabase.co')
            supabase_key = os.getenv('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhra3h5bG91dnlqZHltbnB4emxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0Njg3MDEsImV4cCI6MjA2NzA0NDcwMX0.c5SRJPpm9VzEHh0PeNqVRamYn5BfGOtgbg9F36d2ew8')
            
            self.supabase: Client = create_client(supabase_url, supabase_key)
            self.database_available = True
            print("✅ Supabase client initialized successfully")
        except Exception as e:
            self.supabase = None
            self.database_available = False
            print(f"❌ Warning: Could not initialize Supabase client: {e}")
            print("Reminder agent will work in standalone mode")
    
    def _get_user_uuid(self, user_id: str) -> UUID:
        """Convert user_id to UUID."""
        try:
            return UUID(user_id)
        except ValueError:
            # Create deterministic UUID from string
            return UUID(hashlib.md5(user_id.encode()).hexdigest())
    
    def _parse_time_expression(self, time_expr: str, base_time: datetime = None) -> datetime:
        """
        Parse natural language time expressions into datetime objects.
        This is a simple implementation - you might want to use a more sophisticated library.
        """
        if base_time is None:
            base_time = datetime.utcnow()
        
        time_expr = time_expr.lower().strip()
        
        # Simple parsing examples
        if "in" in time_expr:
            if "hour" in time_expr:
                hours = int([word for word in time_expr.split() if word.isdigit()][0])
                return base_time + timedelta(hours=hours)
            elif "minute" in time_expr:
                minutes = int([word for word in time_expr.split() if word.isdigit()][0])
                return base_time + timedelta(minutes=minutes)
            elif "day" in time_expr:
                days = int([word for word in time_expr.split() if word.isdigit()][0])
                return base_time + timedelta(days=days)
        
        # Default: assume it's already a proper datetime or add 1 hour
        return base_time + timedelta(hours=1)
    
    @cf.task
    def create_reminder(self, user_id: str, event_name: str, time_expression: str = "in 1 hour") -> Dict[str, Any]:
        """
        Create a new reminder for a user.
        
        Args:
            user_id: The ID of the user
            event_name: What to remind the user about
            time_expression: When to remind (natural language or specific time)
        
        Returns:
            Dictionary with success status and reminder details
        """
        try:
            # Parse the time expression
            reminder_time = self._parse_time_expression(time_expression)
            
            if self.database_available and self.supabase:
                # Use Supabase storage
                print(f"🔄 Creating reminder in Supabase for user {user_id}")
                
                # Create reminder record
                data = {
                    'user_id': user_id,
                    'event_name': event_name,
                    'reminder_datetime': reminder_time.isoformat(),
                    'status': 'active',
                    'created_at': datetime.utcnow().isoformat()
                }
                
                result = self.supabase.table('reminders').insert(data).execute()
                
                if result.data:
                    reminder_id = result.data[0]['id']
                    print(f"✅ Reminder created successfully with ID: {reminder_id}")
                    
                    return {
                        "success": True,
                        "message": f"✅ Lembrete criado: '{event_name}' para {reminder_time.strftime('%d/%m/%Y às %H:%M')}",
                        "reminder_id": reminder_id,
                        "reminder_time": reminder_time.isoformat(),
                        "event_name": event_name
                    }
                else:
                    return {
                        "success": False,
                        "message": f"❌ Erro ao criar lembrete no banco de dados"
                    }
            else:
                # Fallback: just confirm the reminder (won't persist)
                print("⚠️ Database not available, using fallback mode")
                return {
                    "success": True,
                    "message": f"✅ Lembrete registrado: '{event_name}' para {reminder_time.strftime('%d/%m/%Y às %H:%M')} (não será salvo permanentemente)",
                    "reminder_time": reminder_time.isoformat(),
                    "event_name": event_name
                }
                
        except Exception as e:
            print(f"❌ Error creating reminder: {str(e)}")
            return {
                "success": False,
                "message": f"❌ Erro ao processar lembrete: {str(e)}"
            }
    
    @cf.task 
    def list_user_reminders(self, user_id: str) -> Dict[str, Any]:
        """
        List all active reminders for a user.
        
        Args:
            user_id: The ID of the user
            
        Returns:
            Dictionary with reminders list
        """
        try:
            if self.database_available and self.supabase:
                print(f"🔍 Listing reminders from Supabase for user {user_id}")
                
                # Query reminders from Supabase
                result = self.supabase.table('reminders') \
                    .select('*') \
                    .eq('user_id', user_id) \
                    .eq('status', 'active') \
                    .order('reminder_datetime', desc=False) \
                    .execute()
                
                reminders = result.data if result.data else []
                
                if not reminders:
                    return {
                        "success": True,
                        "message": "📝 Você não tem lembretes ativos.",
                        "reminders": []
                    }
                
                reminder_list = []
                message = "📝 Seus lembretes ativos:\n\n"
                
                for i, reminder in enumerate(reminders, 1):
                    reminder_time = datetime.fromisoformat(reminder['reminder_datetime'])
                    time_str = reminder_time.strftime('%d/%m/%Y às %H:%M')
                    message += f"{i}. {reminder['event_name']} - {time_str}\n"
                    reminder_list.append(reminder)
                
                print(f"✅ Found {len(reminders)} active reminders")
                
                return {
                    "success": True,
                    "message": message.strip(),
                    "reminders": reminder_list
                }
            else:
                return {
                    "success": True,
                    "message": "📝 Base de dados não disponível. Não é possível listar lembretes.",
                    "reminders": []
                }
                
        except Exception as e:
            print(f"❌ Error listing reminders: {str(e)}")
            return {
                "success": False,
                "message": f"❌ Erro ao listar lembretes: {str(e)}",
                "reminders": []
            }
    
    @cf.task
    def cancel_reminder(self, user_id: str, reminder_id: str) -> Dict[str, Any]:
        """
        Cancel a specific reminder.
        
        Args:
            user_id: The ID of the user
            reminder_id: The ID of the reminder to cancel
            
        Returns:
            Dictionary with cancellation status
        """
        try:
            if self.database_available and self.reminder_manager:
                result = self.reminder_manager.cancel_reminder(user_id, reminder_id)
                
                if result["success"]:
                    return {
                        "success": True,
                        "message": f"✅ Lembrete cancelado com sucesso!"
                    }
                else:
                    return {
                        "success": False,
                        "message": f"❌ Erro ao cancelar lembrete: {result['error']}"
                    }
            else:
                return {
                    "success": False,
                    "message": "❌ Base de dados não disponível. Não é possível cancelar lembretes."
                }
                
        except Exception as e:
            return {
                "success": False,
                "message": f"❌ Erro ao cancelar lembrete: {str(e)}"
            }

    async def process_message(self, user_input: str, user_id: str = None) -> Dict[str, Any]:
        """
        Process a reminder-related message.
        
        Args:
            user_input: The user's message
            user_id: Optional user ID
            
        Returns:
            Structured response for the orchestrator
        """
        try:
            # Use ControlFlow to handle the user input
            result = cf.run(
                f"""
                Process this reminder request from the user: "{user_input}"
                
                Determine what the user wants to do:
                1. Create a reminder - extract event name and time
                2. List their reminders 
                3. Cancel a reminder
                4. General reminder help
                
                If creating a reminder, call the create_reminder function with appropriate parameters.
                If listing reminders, call list_user_reminders.
                If cancelling, call cancel_reminder.
                
                Always provide a helpful, friendly response in Portuguese.
                """,
                context={
                    "user_input": user_input,
                    "user_id": user_id or "default_user",
                    "functions": {
                        "create_reminder": self.create_reminder,
                        "list_user_reminders": self.list_user_reminders,
                        "cancel_reminder": self.cancel_reminder
                    }
                },
                agents=[self.agent]
            )
            
            return {
                "message": result,
                "agent_used": "ReminderAgent",
                "intent_category": "reminder_management", 
                "success": True,
                "metadata": {
                    "user_id": user_id,
                    "database_available": self.database_available
                }
            }
            
        except Exception as e:
            return {
                "message": f"❌ Desculpe, ocorreu um erro ao processar seu pedido de lembrete: {str(e)}",
                "agent_used": "ReminderAgent",
                "intent_category": "reminder_management",
                "success": False,
                "metadata": {"error": str(e)}
            }
