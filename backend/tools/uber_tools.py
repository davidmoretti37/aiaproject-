from typing import Dict, Any, Optional, Tuple
import urllib.parse
from .geocoding_tools import geocode_address


def create_uber_deeplink(origin: str, destination: str, waypoint: str = None, product_id: str = None) -> Dict[str, Any]:
    """
    Create Uber deeplink schema with geocoded coordinates
    
    Args:
        origin: Pickup location (use "current location" for user's current position)
        destination: Drop-off location  
        waypoint: Optional stop/waypoint between origin and destination
        product_id: Optional Uber product type
    
    Returns:
        Dictionary with deeplink schema and formatted response
    """
    try:
        # Handle origin
        if origin.lower() in ["current location", "my location", "here", "where i am"]:
            origin_display = "Current Location"
            origin_lat = None
            origin_lng = None
            use_current_location = True
        else:
            # Geocode the origin address
            origin_result = geocode_address(origin)
            if not origin_result["success"]:
                return {
                    "success": False,
                    "message": f"Could not find coordinates for origin: {origin}",
                    "error": origin_result.get("error", "Geocoding failed")
                }
            
            origin_data = origin_result["data"]
            origin_display = origin_data["formatted_address"]
            origin_lat = origin_data["latitude"]
            origin_lng = origin_data["longitude"]
            use_current_location = False
        
        # Geocode the destination address
        dest_result = geocode_address(destination)
        if not dest_result["success"]:
            return {
                "success": False,
                "message": f"Could not find coordinates for destination: {destination}",
                "error": dest_result.get("error", "Geocoding failed")
            }
        
        dest_data = dest_result["data"]
        dest_display = dest_data["formatted_address"]
        dest_lat = dest_data["latitude"]
        dest_lng = dest_data["longitude"]
        
        # Handle waypoint if provided
        waypoint_data = None
        if waypoint:
            waypoint_result = geocode_address(waypoint)
            if waypoint_result["success"]:
                waypoint_data = waypoint_result["data"]
        
        # Create Uber deeplink following official documentation format
        if use_current_location:
            # Use current location for pickup (official format)
            deeplink = f"uber://riderequest?pickup=my_location&dropoff[latitude]={dest_lat}&dropoff[longitude]={dest_lng}&dropoff[nickname]={urllib.parse.quote(destination)}&dropoff[formatted_address]={urllib.parse.quote(dest_display)}"
        else:
            # Use specific pickup coordinates (official format)
            deeplink = f"uber://riderequest?pickup[latitude]={origin_lat}&pickup[longitude]={origin_lng}&pickup[nickname]={urllib.parse.quote(origin)}&pickup[formatted_address]={urllib.parse.quote(origin_display)}&dropoff[latitude]={dest_lat}&dropoff[longitude]={dest_lng}&dropoff[nickname]={urllib.parse.quote(destination)}&dropoff[formatted_address]={urllib.parse.quote(dest_display)}"
        
        # Add product ID if specified
        if product_id:
            deeplink += f"&product_id={product_id}"
        
        # Create Universal Link as alternative (recommended by Uber)
        if use_current_location:
            universal_link = f"https://m.uber.com/looking?pickup=my_location&drop[0]=%7B%22latitude%22%3A{dest_lat}%2C%22longitude%22%3A{dest_lng}%2C%22addressLine1%22%3A%22{urllib.parse.quote(destination)}%22%2C%22addressLine2%22%3A%22{urllib.parse.quote(dest_display.split(',')[-1].strip() if ',' in dest_display else '')}%22%7D"
        else:
            pickup_encoded = urllib.parse.quote(f'{{"latitude":{origin_lat},"longitude":{origin_lng},"addressLine1":"{origin}","addressLine2":"{origin_display.split(",")[-1].strip() if "," in origin_display else ""}"}}')
            dropoff_encoded = urllib.parse.quote(f'{{"latitude":{dest_lat},"longitude":{dest_lng},"addressLine1":"{destination}","addressLine2":"{dest_display.split(",")[-1].strip() if "," in dest_display else ""}"}}')
            universal_link = f"https://m.uber.com/looking?pickup={pickup_encoded}&drop[0]={dropoff_encoded}"
        
        # Prepare response data
        response_data = {
            "origin": origin_display,
            "destination": dest_display,
            "deeplink": deeplink,
            "universal_link": universal_link,
            "instructions": "Use the deeplink for native app or universal link for web compatibility",
            "coordinates": {
                "origin": {
                    "latitude": origin_lat,
                    "longitude": origin_lng
                } if not use_current_location else None,
                "destination": {
                    "latitude": dest_lat,
                    "longitude": dest_lng
                }
            }
        }
        
        # Add waypoint information if provided
        trip_description = f"trip from '{origin_display}' to '{dest_display}'"
        if waypoint and waypoint_data:
            response_data["waypoint"] = waypoint_data["formatted_address"]
            response_data["coordinates"]["waypoint"] = {
                "latitude": waypoint_data["latitude"],
                "longitude": waypoint_data["longitude"]
            }
            trip_description += f" with stop at '{waypoint_data['formatted_address']}'"
        elif waypoint:
            response_data["waypoint"] = waypoint
            trip_description += f" with stop at '{waypoint}'"
        
        return {
            "success": True,
            "message": f"Uber deeplink created for {trip_description}",
            "data": response_data,
            "schema": {
                "type": "uber_deeplink",
                "action": "open_app",
                "url": deeplink,
                "universal_link": universal_link,
                "origin": origin_display,
                "destination": dest_display,
                "waypoint": response_data.get("waypoint"),
                "coordinates": response_data["coordinates"]
            }
        }
    except Exception as e:
        return {
            "success": False,
            "message": "Failed to create Uber deeplink",
            "error": str(e)
        }


def create_uber_web_link(origin: str, destination: str) -> Dict[str, Any]:
    """
    Create Uber web link as fallback if app is not installed
    
    Args:
        origin: Pickup location
        destination: Drop-off location
    
    Returns:
        Dictionary with web link schema
    """
    try:
        # URL encode the locations
        encoded_origin = urllib.parse.quote(origin)
        encoded_destination = urllib.parse.quote(destination)
        
        # Uber web URL
        web_url = f"https://m.uber.com/ul/?action=setPickup&pickup[formatted_address]={encoded_origin}&dropoff[formatted_address]={encoded_destination}"
        
        return {
            "success": True,
            "message": f"Uber web link created for trip from '{origin}' to '{destination}'",
            "data": {
                "origin": origin,
                "destination": destination,
                "web_link": web_url,
                "instructions": "Use this link to open Uber in web browser if app is not available"
            },
            "schema": {
                "type": "uber_web_link",
                "action": "open_browser",
                "url": web_url
            }
        }
    except Exception as e:
        return {
            "success": False,
            "message": "Failed to create Uber web link",
            "error": str(e)
        }
