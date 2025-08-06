"""
iFood integration tools - Full implementation with anti-detection
"""

import requests
import json
import time
import random
from typing import Dict, Any, List, Optional
import urllib.parse
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


class IFoodSession:
    """Manages iFood session with proper headers and cookies"""
    
    def __init__(self):
        self.session = requests.Session()
        self.setup_session()
        self.setup_retry_strategy()
    
    def setup_session(self):
        """Setup session with realistic browser headers"""
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"macOS"',
            'Cache-Control': 'max-age=0'
        })
    
    def setup_retry_strategy(self):
        """Setup retry strategy for failed requests"""
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)
    
    def initialize_session(self):
        """Initialize session by simulating real browser navigation"""
        try:
            # Step 1: Visit main page to establish initial session
            print("🔄 Visiting main page...")
            response = self.session.get('https://www.ifood.com.br/', timeout=10)
            if response.status_code != 200:
                print(f"⚠️ Main page returned {response.status_code}")
                return False
            
            # Step 2: Simulate clicking on location/search
            print("🔄 Simulating location selection...")
            time.sleep(random.uniform(2.0, 3.0))
            
            # Visit a specific location page that exists
            location_headers = {
                'Referer': 'https://www.ifood.com.br/',
                'Upgrade-Insecure-Requests': '1',
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'same-origin',
                'Sec-Fetch-User': '?1'
            }
            
            # Try different location URLs
            location_urls = [
                'https://www.ifood.com.br/delivery/sao-paulo-sp/vila-olimpia',
                'https://www.ifood.com.br/delivery/sao-paulo-sp',
                'https://www.ifood.com.br/delivery'
            ]
            
            location_success = False
            for location_url in location_urls:
                try:
                    response = self.session.get(location_url, headers=location_headers, timeout=10)
                    print(f"📍 Trying {location_url}: {response.status_code}")
                    if response.status_code == 200:
                        location_success = True
                        break
                    time.sleep(1)
                except:
                    continue
            
            # Step 3: Simulate search behavior
            print("🔄 Simulating search interaction...")
            time.sleep(random.uniform(1.0, 2.0))
            
            # Make a preliminary search request to establish search session
            search_headers = {
                'Referer': 'https://www.ifood.com.br/delivery/sao-paulo-sp',
                'Accept': 'application/json, text/plain, */*',
                'X-Requested-With': 'XMLHttpRequest',
                'Sec-Fetch-Dest': 'empty',
                'Sec-Fetch-Mode': 'cors',
                'Sec-Fetch-Site': 'same-site'
            }
            
            # Try a simple search to warm up the session
            warm_up_url = "https://marketplace.ifood.com.br/v2/cardstack/search/results"
            warm_up_params = {
                'alias': 'SEARCH_RESULTS_MERCHANT_TAB_GLOBAL',
                'latitude': -23.5505,
                'longitude': -46.6333,
                'channel': 'IFOOD',
                'size': 1,
                'term': 'restaurante'
            }
            
            try:
                warm_response = self.session.get(warm_up_url, params=warm_up_params, headers=search_headers, timeout=10)
                print(f"🔥 Warm-up search: {warm_response.status_code}")
            except:
                print("⚠️ Warm-up search failed, continuing...")
            
            print(f"✅ Session initialized successfully")
            print(f"🍪 Cookies: {len(self.session.cookies)} cookies set")
            
            # Print cookie names and values for debugging
            cookie_info = [(cookie.name, cookie.value[:20] + "..." if len(cookie.value) > 20 else cookie.value) for cookie in self.session.cookies]
            print(f"🍪 Cookie info: {cookie_info}")
            
            return True
            
        except Exception as e:
            print(f"❌ Failed to initialize session: {e}")
            return False
    
    def make_search_request(self, term: str, latitude: float, longitude: float, size: int = 20):
        """Make search request to iFood API"""
        
        # Add specific headers for the search request - more complete set
        search_headers = {
            'Referer': f'https://www.ifood.com.br/delivery/sao-paulo-sp?q={urllib.parse.quote(term)}',
            'Origin': 'https://www.ifood.com.br',
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json, text/plain, */*',
            'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
            'DNT': '1',
            'Sec-Fetch-Dest': 'empty',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Site': 'same-site',
            'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"macOS"'
        }
        
        url = "https://marketplace.ifood.com.br/v2/cardstack/search/results"
        params = {
            'alias': 'SEARCH_RESULTS_MERCHANT_TAB_GLOBAL',
            'latitude': latitude,
            'longitude': longitude,
            'channel': 'IFOOD',
            'size': size,
            'term': term
        }
        
        try:
            # Add random delay to avoid rate limiting
            time.sleep(random.uniform(1.0, 2.0))
            
            response = self.session.get(
                url, 
                params=params, 
                headers=search_headers,
                timeout=15
            )
            
            print(f"🌐 Request URL: {response.url}")
            print(f"📊 Response Status: {response.status_code}")
            print(f"📏 Response Length: {len(response.text)}")
            print(f"🍪 Request Cookies: {len(response.request.headers.get('Cookie', '').split(';')) if response.request.headers.get('Cookie') else 0}")
            
            if response.status_code == 200:
                try:
                    json_data = response.json()
                    print(f"📋 JSON Keys: {list(json_data.keys()) if isinstance(json_data, dict) else 'Not a dict'}")
                    return json_data
                except json.JSONDecodeError as e:
                    print(f"❌ JSON decode error: {e}")
                    print(f"📄 Raw response: {response.text[:500]}...")
                    return None
            else:
                print(f"❌ Request failed with status {response.status_code}")
                print(f"📄 Response text: {response.text[:200]}...")
                return None
                
        except Exception as e:
            print(f"❌ Request error: {e}")
            return None


def parse_ifood_response(response_data: Dict[str, Any], term: str, latitude: float, longitude: float) -> Dict[str, Any]:
    """Parse iFood API response and extract restaurant data"""
    
    if not response_data or 'sections' not in response_data:
        return {
            "success": False,
            "message": "Empty or invalid response from iFood",
            "error": "No data returned",
            "data": {
                "restaurants": [],
                "search_term": term,
                "location": {"latitude": latitude, "longitude": longitude},
                "total_results": 0
            }
        }
    
    restaurants = []
    total_results = 0
    
    try:
        # Navigate through the response structure
        for section in response_data.get('sections', []):
            if section.get('type') == 'CARDS':
                for card in section.get('cards', []):
                    if card.get('cardType') == 'MERCHANT_LIST_V2':
                        contents = card.get('data', {}).get('contents', [])
                        
                        for restaurant_data in contents:
                            if restaurant_data.get('available', False):
                                restaurant = parse_restaurant_data(restaurant_data)
                                if restaurant:
                                    restaurants.append(restaurant)
                                    total_results += 1
        
        return {
            "success": True,
            "message": f"Found {total_results} restaurants for '{term}'",
            "data": {
                "restaurants": restaurants,
                "search_term": term,
                "location": {"latitude": latitude, "longitude": longitude},
                "total_results": total_results
            }
        }
        
    except Exception as e:
        print(f"❌ Error parsing response: {e}")
        return {
            "success": False,
            "message": f"Error parsing iFood response: {str(e)}",
            "error": str(e),
            "data": {
                "restaurants": [],
                "search_term": term,
                "location": {"latitude": latitude, "longitude": longitude},
                "total_results": 0
            }
        }


def parse_restaurant_data(restaurant_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Parse individual restaurant data from iFood response"""
    
    try:
        restaurant_id = restaurant_data.get('id', '')
        name = restaurant_data.get('name', '')
        
        if not restaurant_id or not name:
            return None
        
        # Extract delivery info
        delivery_info = restaurant_data.get('deliveryInfo', {})
        delivery_fee = delivery_info.get('fee', 0)
        delivery_time_min = delivery_info.get('timeMinMinutes', 0)
        delivery_time_max = delivery_info.get('timeMaxMinutes', 0)
        
        # Format delivery fee
        if delivery_fee > 0:
            delivery_fee_formatted = f"R$ {delivery_fee/100:.2f}".replace('.', ',')
        else:
            delivery_fee_formatted = "Grátis"
        
        # Format delivery time
        if delivery_time_min > 0 and delivery_time_max > 0:
            delivery_time_formatted = f"{delivery_time_min}-{delivery_time_max} min"
        else:
            delivery_time_formatted = "Consultar"
        
        # Format distance
        distance = restaurant_data.get('distance', 0)
        distance_formatted = f"{distance:.1f} km" if distance > 0 else "N/A"
        
        # Create deep link
        action = restaurant_data.get('action', '')
        deeplink = create_ifood_deeplink_from_action(action, restaurant_id, name)
        
        restaurant = {
            "id": restaurant_id,
            "name": name,
            "image": format_image_url(restaurant_data.get('imageUrl', '')),
            "distance": distance_formatted,
            "rating": restaurant_data.get('userRating', 0),
            "category": restaurant_data.get('mainCategory', 'Restaurante'),
            "delivery_fee": delivery_fee_formatted,
            "delivery_time": delivery_time_formatted,
            "available": restaurant_data.get('available', False),
            "is_super_restaurant": restaurant_data.get('isSuperRestaurant', False),
            "is_ifood_delivery": restaurant_data.get('isIfoodDelivery', False),
            "action": action,
            "deeplink": deeplink
        }
        
        return restaurant
        
    except Exception as e:
        print(f"❌ Error parsing restaurant data: {e}")
        return None


def format_image_url(image_url: str) -> str:
    """Format iFood image URL with proper resolution"""
    if not image_url:
        return ""
    
    base_url = "https://static-images.ifood.com.br/image/upload"
    if image_url.startswith(':resolution/'):
        return f"{base_url}/t_medium{image_url[11:]}"
    elif image_url.startswith('http'):
        return image_url
    else:
        return f"{base_url}/t_medium/{image_url}"


def create_ifood_deeplink_from_action(action: str, restaurant_id: str, restaurant_name: str) -> str:
    """Create iFood mobile deeplink from action string"""
    if action and 'merchant?' in action:
        # Extract parameters from action
        try:
            params = action.split('merchant?')[1]
            # Parse parameters to extract needed data
            param_dict = {}
            for param in params.split('&'):
                if '=' in param:
                    key, value = param.split('=', 1)
                    param_dict[key] = urllib.parse.unquote(value)
            
            # Create mobile deeplink using identifier and slug
            if 'identifier' in param_dict and 'slug' in param_dict:
                identifier = param_dict['identifier']
                slug = param_dict['slug']
                # Mobile deeplink format that opens the app
                return f"ifood://restaurant/{identifier}?slug={urllib.parse.quote(slug)}"
            
            # Fallback with just identifier
            if 'identifier' in param_dict:
                identifier = param_dict['identifier']
                encoded_name = urllib.parse.quote(restaurant_name)
                return f"ifood://restaurant/{identifier}?name={encoded_name}"
                
        except Exception as e:
            print(f"⚠️ Error parsing action: {e}")
    
    # Fallback to basic mobile deeplink
    return create_ifood_mobile_deeplink(restaurant_id, restaurant_name)


def search_ifood_restaurants_with_selenium(term: str, latitude: float, longitude: float, size: int = 20) -> Dict[str, Any]:
    """
    Search restaurants on iFood using Selenium for real browser session
    """
    try:
        from selenium import webdriver
        from selenium.webdriver.chrome.service import Service
        from selenium.webdriver.chrome.options import Options
        from webdriver_manager.chrome import ChromeDriverManager
        import requests
        
        print(f"🔍 Searching iFood with Selenium for '{term}' at {latitude}, {longitude}")
        
        # Setup Chrome options
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_experimental_option("useAutomationExtension", False)
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        
        # Initialize driver
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=chrome_options)
        
        # Remove automation indicators
        driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
        
        try:
            # Visit iFood and get real cookies
            driver.get("https://www.ifood.com.br/")
            time.sleep(3)
            driver.get("https://www.ifood.com.br/delivery")
            time.sleep(2)
            
            # Get cookies and user agent
            cookies = driver.get_cookies()
            user_agent = driver.execute_script("return navigator.userAgent;")
            
            # Create requests session with real cookies
            session = requests.Session()
            for cookie in cookies:
                session.cookies.set(cookie['name'], cookie['value'])
            
            # Make API request with real browser session
            headers = {
                'User-Agent': user_agent,
                'Accept': 'application/json, text/plain, */*',
                'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
                'Accept-Encoding': 'gzip, deflate, br',
                'Referer': 'https://www.ifood.com.br/delivery',
                'Origin': 'https://www.ifood.com.br',
                'X-Requested-With': 'XMLHttpRequest',
                'Sec-Fetch-Dest': 'empty',
                'Sec-Fetch-Mode': 'cors',
                'Sec-Fetch-Site': 'same-site'
            }
            
            url = "https://marketplace.ifood.com.br/v2/cardstack/search/results"
            params = {
                'alias': 'SEARCH_RESULTS_MERCHANT_TAB_GLOBAL',
                'latitude': latitude,
                'longitude': longitude,
                'channel': 'IFOOD',
                'size': size,
                'term': term
            }
            
            response = session.get(url, params=params, headers=headers, timeout=15)
            
            if response.status_code == 200:
                response_data = response.json()
                return parse_ifood_response(response_data, term, latitude, longitude)
            else:
                return {
                    "success": False,
                    "message": f"API request failed with status {response.status_code}",
                    "error": f"HTTP {response.status_code}",
                    "data": {
                        "restaurants": [],
                        "search_term": term,
                        "location": {"latitude": latitude, "longitude": longitude},
                        "total_results": 0
                    }
                }
                
        finally:
            driver.quit()
            
    except ImportError:
        print("⚠️ Selenium not available, falling back to requests-only method")
        return search_ifood_restaurants_fallback(term, latitude, longitude, size)
    except Exception as e:
        print(f"❌ Selenium method failed: {e}")
        return search_ifood_restaurants_fallback(term, latitude, longitude, size)


def search_ifood_restaurants_fallback(term: str, latitude: float, longitude: float, size: int = 20) -> Dict[str, Any]:
    """
    Fallback method using requests only
    """
    print(f"🔍 Searching iFood (fallback) for '{term}' at {latitude}, {longitude}")
    
    # Create session and initialize
    ifood_session = IFoodSession()
    
    if not ifood_session.initialize_session():
        return {
            "success": False,
            "message": "Failed to initialize iFood session",
            "error": "Session initialization failed",
            "data": {
                "restaurants": [],
                "search_term": term,
                "location": {"latitude": latitude, "longitude": longitude},
                "total_results": 0
            }
        }
    
    # Make search request
    response_data = ifood_session.make_search_request(term, latitude, longitude, size)
    
    if not response_data:
        return {
            "success": False,
            "message": "Failed to get data from iFood",
            "error": "Request failed or returned empty",
            "data": {
                "restaurants": [],
                "search_term": term,
                "location": {"latitude": latitude, "longitude": longitude},
                "total_results": 0
            }
        }
    
    # Parse and return results
    return parse_ifood_response(response_data, term, latitude, longitude)


def search_ifood_restaurants_v2(term: str, latitude: float, longitude: float, size: int = 20) -> Dict[str, Any]:
    """
    Search restaurants on iFood using the working CURL implementation
    Based on the functional CURL that returns real data
    """
    import uuid
    
    print(f"🔍 Searching iFood (v2) for '{term}' at {latitude}, {longitude}")
    
    try:
        # Generate unique IDs
        device_id = str(uuid.uuid4())
        session_id = str(uuid.uuid4())
        
        # Complete headers based on working CURL
        headers = {
            'accept': 'application/json, text/plain, */*',
            'accept-language': 'pt-BR,pt;q=1',
            'app_version': '9.119.1',
            'browser': 'Mac OS',
            'cache-control': 'no-cache, no-store',
            'content-type': 'application/json',
            'country': 'BR',
            'dnt': '1',
            'experiment_details': '{ "default_merchant": { "model_id": "search-rerank-endpoint", "recommendation_filter": "AVAILABLE_FOR_SCHEDULING_FIXED", "available_for_scheduling_recommended_limit": 5, "engine": "sagemaker", "backend_experiment_id": "v4", "query_rewriter_rule": "merchant-names", "second_search": true, "force_similar_search_disabled": true, "similar_search": { "open_merchants_threshold": 5, "max_similar_merchants": 5 } } }',
            'experiment_variant': 'default_merchant',
            'gps-latitude': str(latitude),
            'gps-longitude': str(longitude),
            'origin': 'https://www.ifood.com.br',
            'platform': 'Desktop',
            'priority': 'u=1, i',
            'referer': 'https://www.ifood.com.br/',
            'sec-ch-ua': '"Chromium";v="137", "Not/A)Brand";v="24"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"macOS"',
            'sec-fetch-dest': 'empty',
            'sec-fetch-mode': 'cors',
            'sec-fetch-site': 'same-site',
            'test_merchants': 'undefined',
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
            'x-client-application-key': '41a266ee-51b7-4c37-9e9d-5cd331f280d5',
            'x-device-model': 'Macintosh Chrome',
            'x-ifood-device-id': device_id,
            'x-ifood-session-id': session_id
        }
        
        # Payload for POST request
        payload = {
            "supported-headers": ["OPERATION_HEADER"],
            "supported-cards": [
                "MERCHANT_LIST",
                "CATALOG_ITEM_LIST",
                "CATALOG_ITEM_LIST_V2",
                "CATALOG_ITEM_LIST_V3",
                "FEATURED_MERCHANT_LIST",
                "CATALOG_ITEM_CAROUSEL",
                "CATALOG_ITEM_CAROUSEL_V2",
                "CATALOG_ITEM_CAROUSEL_V3",
                "BIG_BANNER_CAROUSEL",
                "IMAGE_BANNER",
                "MERCHANT_LIST_WITH_ITEMS_CAROUSEL",
                "SMALL_BANNER_CAROUSEL",
                "NEXT_CONTENT",
                "MERCHANT_CAROUSEL",
                "MERCHANT_TILE_CAROUSEL",
                "SIMPLE_MERCHANT_CAROUSEL",
                "INFO_CARD",
                "MERCHANT_LIST_V2",
                "ROUND_IMAGE_CAROUSEL",
                "BANNER_GRID",
                "MEDIUM_IMAGE_BANNER",
                "MEDIUM_BANNER_CAROUSEL",
                "RELATED_SEARCH_CAROUSEL",
                "ADS_BANNER"
            ],
            "supported-actions": [
                "catalog-item",
                "item-details",
                "merchant",
                "page",
                "card-content",
                "last-restaurants",
                "webmiddleware",
                "reorder",
                "search",
                "groceries",
                "home-tab"
            ],
            "feed-feature-name": "",
            "faster-overrides": ""
        }
        
        # URL with query parameters
        url = "https://marketplace.ifood.com.br/v2/cardstack/search/results"
        params = {
            'alias': 'SEARCH_RESULTS_MERCHANT_TAB_GLOBAL',
            'latitude': latitude,
            'longitude': longitude,
            'channel': 'IFOOD',
            'size': size,
            'term': term
        }
        
        # Make POST request
        session = requests.Session()
        response = session.post(url, params=params, headers=headers, json=payload, timeout=15)
        
        print(f"🌐 Request URL: {response.url}")
        print(f"📊 Response Status: {response.status_code}")
        print(f"📏 Response Length: {len(response.text)}")
        print(f"🔑 Device ID: {device_id}")
        print(f"🔑 Session ID: {session_id}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"📋 JSON Keys: {list(data.keys())}")
                return parse_ifood_response(data, term, latitude, longitude)
            except json.JSONDecodeError as e:
                print(f"❌ JSON decode error: {e}")
                return {
                    "success": False,
                    "message": f"Invalid JSON response: {e}",
                    "error": str(e),
                    "data": {
                        "restaurants": [],
                        "search_term": term,
                        "location": {"latitude": latitude, "longitude": longitude},
                        "total_results": 0
                    }
                }
        else:
            print(f"❌ Request failed with status {response.status_code}")
            return {
                "success": False,
                "message": f"HTTP {response.status_code}",
                "error": f"Request failed with status {response.status_code}",
                "data": {
                    "restaurants": [],
                    "search_term": term,
                    "location": {"latitude": latitude, "longitude": longitude},
                    "total_results": 0
                }
            }
            
    except Exception as e:
        print(f"❌ Request error: {e}")
        return {
            "success": False,
            "message": f"Request error: {str(e)}",
            "error": str(e),
            "data": {
                "restaurants": [],
                "search_term": term,
                "location": {"latitude": latitude, "longitude": longitude},
                "total_results": 0
            }
        }


def search_ifood_restaurants(term: str, latitude: float, longitude: float, size: int = 20) -> Dict[str, Any]:
    """
    Main search function - tries the new v2 method first, then fallbacks
    
    Args:
        term: Search term (e.g., "pizza", "hamburguer")
        latitude: User's latitude
        longitude: User's longitude
        size: Number of results to return (default: 20)
    
    Returns:
        Dictionary with restaurant data or error
    """
    
    # Try the new v2 method first (based on working CURL)
    result = search_ifood_restaurants_v2(term, latitude, longitude, size)
    
    # If v2 method returns empty results, try Selenium method
    if not result.get("success") or result.get("data", {}).get("total_results", 0) == 0:
        print("🔄 Trying Selenium method...")
        selenium_result = search_ifood_restaurants_with_selenium(term, latitude, longitude, size)
        
        # Return the better result
        if selenium_result.get("success") and selenium_result.get("data", {}).get("total_results", 0) > 0:
            return selenium_result
        
        # If Selenium also fails, try fallback
        if not selenium_result.get("success") or selenium_result.get("data", {}).get("total_results", 0) == 0:
            print("🔄 Trying fallback method...")
            fallback_result = search_ifood_restaurants_fallback(term, latitude, longitude, size)
            
            if fallback_result.get("success") and fallback_result.get("data", {}).get("total_results", 0) > 0:
                return fallback_result
    
    return result


def get_restaurant_details(restaurant_id: str) -> Dict[str, Any]:
    """
    Get detailed information about a specific restaurant
    
    Args:
        restaurant_id: Restaurant ID
    
    Returns:
        Dictionary with restaurant details or error
    """
    
    print(f"🏪 Getting details for restaurant {restaurant_id}")
    
    # Create session for restaurant details
    ifood_session = IFoodSession()
    
    if not ifood_session.initialize_session():
        return {
            "success": False,
            "message": "Failed to initialize iFood session",
            "error": "Session initialization failed",
            "data": {"id": restaurant_id, "details": None}
        }
    
    try:
        # Restaurant details endpoint (this might need adjustment based on actual iFood API)
        url = f"https://marketplace.ifood.com.br/v1/merchants/{restaurant_id}"
        
        response = ifood_session.session.get(url, timeout=10)
        
        if response.status_code == 200:
            restaurant_data = response.json()
            return {
                "success": True,
                "message": f"Restaurant details retrieved for {restaurant_id}",
                "data": {
                    "id": restaurant_id,
                    "details": restaurant_data
                }
            }
        else:
            return {
                "success": False,
                "message": f"Failed to get restaurant details: {response.status_code}",
                "error": f"HTTP {response.status_code}",
                "data": {"id": restaurant_id, "details": None}
            }
            
    except Exception as e:
        return {
            "success": False,
            "message": f"Error getting restaurant details: {str(e)}",
            "error": str(e),
            "data": {"id": restaurant_id, "details": None}
        }


def create_ifood_mobile_deeplink(restaurant_id: str, restaurant_name: str) -> str:
    """
    Create iFood mobile deeplink that opens the app
    
    Args:
        restaurant_id: Restaurant ID
        restaurant_name: Restaurant name
    
    Returns:
        iFood mobile deeplink URL
    """
    try:
        encoded_name = urllib.parse.quote(restaurant_name)
        return f"ifood://restaurant/{restaurant_id}?name={encoded_name}"
    except Exception:
        return f"ifood://restaurant/{restaurant_id}"


def create_ifood_deeplink(restaurant_id: str, restaurant_name: str, slug: str = None) -> str:
    """
    Create iFood deeplink for a restaurant
    
    Args:
        restaurant_id: Restaurant ID
        restaurant_name: Restaurant name
        slug: Restaurant slug (optional)
    
    Returns:
        iFood deeplink URL
    """
    try:
        if slug:
            # Use web URL format with slug
            return f"https://www.ifood.com.br/delivery/{slug}"
        else:
            # Fallback to app deeplink
            encoded_name = urllib.parse.quote(restaurant_name)
            return f"ifood://restaurant/{restaurant_id}?name={encoded_name}"
    except Exception:
        return f"ifood://restaurant/{restaurant_id}"
