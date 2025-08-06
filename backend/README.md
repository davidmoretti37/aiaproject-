# AIA - Intelligent Personal Assistant

Backend system for AIA with single orchestrator using ControlFlow.

## Architecture

- **Dynamic Orchestrator**: Analyzes requests and delegates to appropriate specialized agents
- **Uber Agent**: Extracts locations and creates Uber deeplinks for transportation requests
- **ControlFlow Integration**: Uses ControlFlow for agent orchestration and workflows
- **Extensible**: Easy to add new specialized agents

## Project Structure

```
aia/
├── core/
│   └── orchestrator.py          # Main AIA orchestrator with dynamic delegation
├── agents/
│   └── uber_agent.py           # Uber deeplink specialist agent
├── tools/
│   └── uber_tools.py           # Uber deeplink creation tools
├── models/
│   ├── intent.py               # Intent classification models
│   └── uber_schemas.py         # Uber-specific schemas
├── config/
│   └── settings.py             # Configuration settings
├── api/
│   └── main.py                 # FastAPI application
├── main.py                     # CLI interface
└── requirements.txt
```

## Setup

1. **Install dependencies:**

   ```bash
   pip install -r requirements.txt
   ```

2. **Set up environment variables:**

   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

3. **Required environment variables:**
   - `OPENAI_API_KEY`: Your OpenAI API key (required for ControlFlow)

## Usage

### CLI Interface

```bash
python main.py
```

### API Server

```bash
# Run the FastAPI server
cd api
python main.py

# Or using uvicorn directly
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
```

### API Endpoints

#### POST /chat

Single endpoint that processes all requests through the orchestrator.

**Request:**

```json
{
  "message": "Hello, can you help me plan my day?",
  "user_id": "optional_user_id",
  "session_id": "optional_session_id"
}
```

**Response:**

```json
{
  "response": "Hello! I'd be happy to help you plan your day. What would you like to focus on today?",
  "intent_category": "general",
  "agent_used": "AIA_Orchestrator",
  "success": true
}
```

#### GET /health

Health check endpoint.

#### GET /

API information and available endpoints.

## How It Works

1. **User Input**: User sends a message via CLI or API
2. **Agent Selection**: Orchestrator analyzes request and selects appropriate agent
3. **Delegation**: Task is delegated to the selected specialized agent
4. **Processing**: Specialized agent processes the request using its tools
5. **Response**: Returns structured response with deeplinks or information

## Example Interactions

### Transportation Requests (Uber Agent)

```
User: "AIA chame um uber para mim para a rua alto noroeste 127"
AIA: Creates official Uber deeplink with formatted address:
     uber://riderequest?pickup=my_location&dropoff[latitude]=-23.5505&dropoff[longitude]=-46.6333&dropoff[nickname]=rua%20alto%20noroeste%20127&dropoff[formatted_address]=Rua%20Alto%20Noroeste%20127,%20São%20Paulo,%20SP
```

```
User: "Preciso ir ao shopping com parada no banco"
AIA: Creates deeplink with waypoint coordinates and geocoded locations
```

```
User: "Do centro para o aeroporto"
AIA: Creates deeplink with precise coordinates for both origin and destination
```

**Key Features:**

- **Official Uber Format**: Uses `uber://riderequest` format from official documentation
- **Formatted Address**: Includes `dropoff[formatted_address]` for precise location matching
- **Geocoding**: Converts addresses to precise latitude/longitude coordinates
- **Universal Links**: Provides `https://m.uber.com/looking` alternative for web compatibility
- **Multiple Formats**: Standard deeplink, universal link, and web fallback
- **Coordinate + Address**: Combines coordinates with formatted address for maximum accuracy

### General Requests

```
User: "Hello, how are you?"
AIA: "Hello! I'm doing well, thank you for asking. How can I assist you today?"
```

```
User: "Can you help me plan my day?"
AIA: "I'd be happy to help you plan your day! What are your main priorities or tasks for today?"
```

## Adding New Agents

1. Create new agent in `agents/` directory
2. Add any required tools in `tools/` directory
3. Register the agent in the orchestrator
4. Update intent classification logic

## Development

The system uses:

- **ControlFlow**: For agent orchestration and workflows
- **FastAPI**: For REST API
- **Pydantic**: For data validation and settings
- **Uvicorn**: For ASGI server

## Notes

- All prompts and instructions are written in English
- System is designed to be easily extensible with new agents
- Ready for integration with external APIs and services
