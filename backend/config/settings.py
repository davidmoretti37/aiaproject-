import os
from typing import Optional


class Settings:
    def __init__(self):
        # API Keys
        self.openai_api_key: Optional[str] = os.getenv("OPENAI_API_KEY")
        
        # ControlFlow Settings
        self.default_model: str = os.getenv("DEFAULT_MODEL", "openai/gpt-4o-mini")
        
        # API Settings
        self.api_host: str = os.getenv("API_HOST", "0.0.0.0")
        self.api_port: int = int(os.getenv("API_PORT", "8000"))
        
        # Logging
        self.log_level: str = os.getenv("LOG_LEVEL", "INFO")


def get_settings() -> Settings:
    return Settings()


# Ensure OpenAI API key is available for ControlFlow
settings = get_settings()
if settings.openai_api_key:
    os.environ["OPENAI_API_KEY"] = settings.openai_api_key
