"""Configuration for Analytics Worker"""

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """Application settings"""
    
    # Kafka Configuration
    kafka_bootstrap_servers: str = "localhost:9093"
    kafka_consumer_group_id: str = "{{ values.platformName }}-analytics-worker"
    kafka_topics: list[str] = []  # Configure topics to consume
    
    # Database Configuration
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    postgres_db: str = "{{ values.postgresDbName }}"
    postgres_user: str = "postgres"
    postgres_password: str = "postgres"
    
    # API Configuration
    api_key: str = ""  # Set via environment variable
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()

