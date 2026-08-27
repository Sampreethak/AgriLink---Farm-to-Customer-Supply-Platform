# ⚙️ AgriLink — FastAPI Backend

Primary Python REST API server integrating with Supabase and the ML recommendation engine.

## Setup

```bash
pip install -r requirements.txt

# Create .env file with:
# SUPABASE_URL=https://nxwhnbejvwxiuekhtmpm.supabase.co
# SUPABASE_KEY=your_service_key

python -m uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

## API Docs
Visit `http://127.0.0.1:8000/docs` after starting the server.

## Endpoints
- `GET /listings` — Browse all marketplace listings
- `GET /recommendations/{user_id}` — ML-powered product recommendations
- `POST /orders` — Place a new order
- `GET /health` — Server health check
