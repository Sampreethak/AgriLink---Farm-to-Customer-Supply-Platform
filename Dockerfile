# ==============================================================================
# AgriLink FastAPI & Machine Learning Core - Production Dockerfile
# ==============================================================================

FROM python:3.11-slim

# Prevent Python from writing bytecode files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

WORKDIR /app

# Install minimal OS dependencies for C compilation, PostgreSQL libraries & curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python and ML dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source code and ML models
COPY backend_fastapi/ /app/backend_fastapi/
COPY ml/ /app/ml/
COPY ml_pricing_model/ /app/ml_pricing_model/
COPY nlp_engine/ /app/nlp_engine/
COPY database/ /app/database/

# Copy regression and verification test suites for Docker CI validation
COPY test_farmer_nlp_chatbot.py /app/
COPY test_mandi_pricing_integration.py /app/
COPY verify_farmer_rls_nlp.py /app/
COPY verify_full_system_integrity.py /app/

# Expose standard FastAPI port
EXPOSE 8000

# Container healthcheck probe
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start production ASGI server with Uvicorn
CMD ["uvicorn", "backend_fastapi.main:app", "--host", "0.0.0.0", "--port", "8000"]
