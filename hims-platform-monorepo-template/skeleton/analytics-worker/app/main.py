"""
{{ values.platformName | title }} Analytics Worker
FastAPI worker for analytics and ML model inference
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.core.kafka_consumer import KafkaConsumer
from app.core.security import verify_api_key

app = FastAPI(
    title="{{ values.platformName | title }} Analytics Worker",
    description="{{ values.description }}",
    version="0.1.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/health")
async def health():
    return {"status": "healthy", "service": "analytics-worker"}

# Kafka consumer (started on app startup)
kafka_consumer = KafkaConsumer()

@app.on_event("startup")
async def startup_event():
    """Start Kafka consumer on application startup"""
    await kafka_consumer.start()

@app.on_event("shutdown")
async def shutdown_event():
    """Stop Kafka consumer on application shutdown"""
    await kafka_consumer.stop()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

