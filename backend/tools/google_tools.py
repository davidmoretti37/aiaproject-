"""
Google Tools - Gmail and Calendar API integration tools for ControlFlow agents
"""

import os
import base64
import email
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from googleapiclient.discovery import build
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
import json


class GoogleToolsError(Exception):
    """Custom exception for Google Tools errors"""
    pass


def create_google_credentials(access_token: str) -> Credentials:
    """Create Google credentials from access token"""
    return Credentials(token=access_token)


def send_gmail_email(
    access_token: str,
    to_email: str,
    subject: str,
    body: str,
    from_name: str = "AIA Assistant"
) -> Dict[str, Any]:
    """
    Send an email via Gmail API
    
    Args:
        access_token: Google OAuth access token
        to_email: Recipient email address
        subject: Email subject
        body: Email body content
        from_name: Sender name
        
    Returns:
        Dict with success status and message details
    """
    try:
        # Create credentials and Gmail service
        credentials = create_google_credentials(access_token)
        service = build('gmail', 'v1', credentials=credentials)
        
        # Create email message
        message = MIMEMultipart()
        message['to'] = to_email
        message['subject'] = subject
        message['from'] = from_name
        
        # Add body
        message.attach(MIMEText(body, 'plain', 'utf-8'))
        
        # Encode message
        raw_message = base64.urlsafe_b64encode(message.as_bytes()).decode('utf-8')
        
        # Send email
        result = service.users().messages().send(
            userId='me',
            body={'raw': raw_message}
        ).execute()
        
        return {
            "success": True,
            "message_id": result.get('id'),
            "message": f"Email sent successfully to {to_email}"
        }
        
    except Exception as e:
        raise GoogleToolsError(f"Failed to send email: {str(e)}")


def create_calendar_event(
    access_token: str,
    title: str,
    start_datetime: str,
    end_datetime: str,
    description: str = "",
    location: str = "",
    attendees: List[str] = None
) -> Dict[str, Any]:
    """
    Create a Google Calendar event
    
    Args:
        access_token: Google OAuth access token
        title: Event title
        start_datetime: Start datetime in ISO format
        end_datetime: End datetime in ISO format
        description: Event description
        location: Event location
        attendees: List of attendee email addresses
        
    Returns:
        Dict with success status and event details
    """
    try:
        # Create credentials and Calendar service
        credentials = create_google_credentials(access_token)
        service = build('calendar', 'v3', credentials=credentials)
        
        # Prepare event data
        event_data = {
            'summary': title,
            'description': description,
            'start': {
                'dateTime': start_datetime,
                'timeZone': 'America/Sao_Paulo',
            },
            'end': {
                'dateTime': end_datetime,
                'timeZone': 'America/Sao_Paulo',
            },
        }
        
        if location:
            event_data['location'] = location
            
        if attendees:
            event_data['attendees'] = [{'email': email} for email in attendees]
        
        # Create event
        event = service.events().insert(
            calendarId='primary',
            body=event_data
        ).execute()
        
        return {
            "success": True,
            "event_id": event.get('id'),
            "event_url": event.get('htmlLink'),
            "message": f"Event '{title}' created successfully"
        }
        
    except Exception as e:
        raise GoogleToolsError(f"Failed to create calendar event: {str(e)}")


def list_calendar_events(
    access_token: str,
    max_results: int = 10,
    time_min: str = None,
    time_max: str = None
) -> Dict[str, Any]:
    """
    List Google Calendar events
    
    Args:
        access_token: Google OAuth access token
        max_results: Maximum number of events to return
        time_min: Lower bound for event start time (ISO format)
        time_max: Upper bound for event start time (ISO format)
        
    Returns:
        Dict with events list
    """
    try:
        # Create credentials and Calendar service
        credentials = create_google_credentials(access_token)
        service = build('calendar', 'v3', credentials=credentials)
        
        # Set default time bounds if not provided
        if not time_min:
            time_min = datetime.utcnow().isoformat() + 'Z'
        if not time_max:
            time_max = (datetime.utcnow() + timedelta(days=30)).isoformat() + 'Z'
        
        # Get events
        events_result = service.events().list(
            calendarId='primary',
            timeMin=time_min,
            timeMax=time_max,
            maxResults=max_results,
            singleEvents=True,
            orderBy='startTime'
        ).execute()
        
        events = events_result.get('items', [])
        
        # Format events for response
        formatted_events = []
        for event in events:
            start = event['start'].get('dateTime', event['start'].get('date'))
            formatted_events.append({
                'id': event['id'],
                'title': event.get('summary', 'No Title'),
                'start': start,
                'description': event.get('description', ''),
                'location': event.get('location', ''),
                'url': event.get('htmlLink', '')
            })
        
        return {
            "success": True,
            "events": formatted_events,
            "count": len(formatted_events)
        }
        
    except Exception as e:
        raise GoogleToolsError(f"Failed to list calendar events: {str(e)}")


def search_gmail_messages(
    access_token: str,
    query: str,
    max_results: int = 10
) -> Dict[str, Any]:
    """
    Search Gmail messages
    
    Args:
        access_token: Google OAuth access token
        query: Gmail search query
        max_results: Maximum number of messages to return
        
    Returns:
        Dict with messages list
    """
    try:
        # Create credentials and Gmail service
        credentials = create_google_credentials(access_token)
        service = build('gmail', 'v1', credentials=credentials)
        
        # Search messages
        results = service.users().messages().list(
            userId='me',
            q=query,
            maxResults=max_results
        ).execute()
        
        messages = results.get('messages', [])
        
        # Get message details
        formatted_messages = []
        for message in messages:
            msg = service.users().messages().get(
                userId='me',
                id=message['id']
            ).execute()
            
            # Extract message details
            headers = msg['payload'].get('headers', [])
            subject = next((h['value'] for h in headers if h['name'] == 'Subject'), 'No Subject')
            sender = next((h['value'] for h in headers if h['name'] == 'From'), 'Unknown Sender')
            date = next((h['value'] for h in headers if h['name'] == 'Date'), 'Unknown Date')
            
            formatted_messages.append({
                'id': message['id'],
                'subject': subject,
                'sender': sender,
                'date': date,
                'snippet': msg.get('snippet', '')
            })
        
        return {
            "success": True,
            "messages": formatted_messages,
            "count": len(formatted_messages)
        }
        
    except Exception as e:
        raise GoogleToolsError(f"Failed to search Gmail messages: {str(e)}")
