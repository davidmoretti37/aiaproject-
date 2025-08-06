from typing import Dict, Any, Optional, Tuple
import requests
import urllib.parse


def geocode_address(address: str, user_location: Optional[Tuple[float, float]] = None) -> Dict[str, Any]:
    """
    Convert address to latitude/longitude coordinates using a geocoding service
    
    Args:
        address: The address to geocode
        user_location: Optional tuple of (lat, lng) for user's current location to bias results
    
    Returns:
        Dictionary with coordinates and formatted address
    """
    try:
        # Using OpenStreetMap Nominatim API (free, no API key required)
        base_url = "https://nominatim.openstreetmap.org/search"
        
        params = {
            "q": address,
            "format": "json",
            "limit": 5,  # Get multiple results to choose the best one
            "addressdetails": 1,
            "extratags": 1
        }
        
        # If user location is provided, bias results towards that location
        if user_location:
            lat, lng = user_location
            params["viewbox"] = f"{lng-0.1},{lat-0.1},{lng+0.1},{lat+0.1}"
            params["bounded"] = 1
        
        # Add User-Agent header (required by Nominatim)
        headers = {
            "User-Agent": "AIA-Assistant/1.0"
        }
        
        response = requests.get(base_url, params=params, headers=headers, timeout=10)
        response.raise_for_status()
        
        results = response.json()
        
        if not results:
            return {
                "success": False,
                "message": f"No coordinates found for address: {address}",
                "error": "Address not found"
            }
        
        # Choose the best result (first one is usually most relevant)
        best_result = results[0]
        
        lat = float(best_result["lat"])
        lng = float(best_result["lon"])
        formatted_address = best_result.get("display_name", address)
        
        # If user location provided, calculate distance and prefer closer results
        if user_location and len(results) > 1:
            user_lat, user_lng = user_location
            best_distance = calculate_distance(lat, lng, user_lat, user_lng)
            
            for result in results[1:]:
                result_lat = float(result["lat"])
                result_lng = float(result["lon"])
                distance = calculate_distance(result_lat, result_lng, user_lat, user_lng)
                
                if distance < best_distance:
                    best_result = result
                    lat = result_lat
                    lng = result_lng
                    formatted_address = result.get("display_name", address)
                    best_distance = distance
        
        return {
            "success": True,
            "message": f"Coordinates found for: {address}",
            "data": {
                "original_address": address,
                "formatted_address": formatted_address,
                "latitude": lat,
                "longitude": lng,
                "coordinates": f"{lat},{lng}"
            }
        }
        
    except requests.RequestException as e:
        return {
            "success": False,
            "message": f"Failed to geocode address: {address}",
            "error": f"Network error: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"Failed to geocode address: {address}",
            "error": str(e)
        }


def calculate_distance(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """
    Calculate distance between two points using Haversine formula
    Returns distance in kilometers
    """
    import math
    
    # Convert to radians
    lat1_rad = math.radians(lat1)
    lng1_rad = math.radians(lng1)
    lat2_rad = math.radians(lat2)
    lng2_rad = math.radians(lng2)
    
    # Haversine formula
    dlat = lat2_rad - lat1_rad
    dlng = lng2_rad - lng1_rad
    
    a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlng/2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    # Earth's radius in kilometers
    r = 6371
    
    return c * r


def reverse_geocode(latitude: float, longitude: float) -> Dict[str, Any]:
    """
    Convert coordinates to address
    
    Args:
        latitude: Latitude coordinate
        longitude: Longitude coordinate
    
    Returns:
        Dictionary with address information
    """
    try:
        base_url = "https://nominatim.openstreetmap.org/reverse"
        
        params = {
            "lat": latitude,
            "lon": longitude,
            "format": "json",
            "addressdetails": 1
        }
        
        headers = {
            "User-Agent": "AIA-Assistant/1.0"
        }
        
        response = requests.get(base_url, params=params, headers=headers, timeout=10)
        response.raise_for_status()
        
        result = response.json()
        
        if "display_name" not in result:
            return {
                "success": False,
                "message": f"No address found for coordinates: {latitude}, {longitude}",
                "error": "Coordinates not found"
            }
        
        return {
            "success": True,
            "message": f"Address found for coordinates: {latitude}, {longitude}",
            "data": {
                "latitude": latitude,
                "longitude": longitude,
                "formatted_address": result["display_name"],
                "address_components": result.get("address", {})
            }
        }
        
    except Exception as e:
        return {
            "success": False,
            "message": f"Failed to reverse geocode coordinates: {latitude}, {longitude}",
            "error": str(e)
        }
