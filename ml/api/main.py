import http.server
import socketserver
import json
import urllib.parse
import sys
import os
import logging

# Ensure root module import
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from model.predictor import RecommendationPredictor
from model.trainer import ModelTrainer
from config import API_HOST, API_PORT

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

predictor = RecommendationPredictor()
trainer = ModelTrainer()

class RecommenderAPIHandler(http.server.BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query_params = urllib.parse.parse_qs(parsed.query)

        logger.info(f"GET Request: {path}")

        # Health Endpoint
        if path == "/health" or path == "/":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self._send_cors_headers()
            self.end_headers()
            response = {
                "status": "healthy",
                "service": "AgriLink ML Recommendation Engine",
                "model_loaded": predictor.model is not None,
                "database_connected": True
            }
            self.wfile.write(json.dumps(response).encode('utf-8'))
            return

        # Customer Recommendation Endpoint: /recommend/{customer_id}
        if path.startswith("/recommend/"):
            customer_id = path.replace("/recommend/", "").strip()
            top_k = int(query_params.get('top_k', [10])[0])

            try:
                recs = predictor.recommend_for_customer(customer_id=customer_id, top_k=top_k)
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self._send_cors_headers()
                self.end_headers()
                response = {
                    "customer_id": customer_id,
                    "total_recommendations": len(recs),
                    "recommendations": recs
                }
                self.wfile.write(json.dumps(response).encode('utf-8'))
                return
            except Exception as e:
                logger.error(f"Error serving recommendation for customer {customer_id}: {e}")
                self.send_response(500)
                self.send_header("Content-Type", "application/json")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
                return

        # Similar Listings Endpoint: /similar-listings/{listing_id}
        if path.startswith("/similar-listings/"):
            listing_id = path.replace("/similar-listings/", "").strip()
            top_k = int(query_params.get('top_k', [5])[0])

            try:
                similar = predictor.recommend_similar_listings(listing_id=listing_id, top_k=top_k)
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(similar).encode('utf-8'))
                return
            except Exception as e:
                self.send_response(500)
                self.send_header("Content-Type", "application/json")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
                return

        # 404 Not Found
        self.send_response(404)
        self.send_header("Content-Type", "application/json")
        self._send_cors_headers()
        self.end_headers()
        self.wfile.write(json.dumps({"error": "Endpoint not found"}).encode('utf-8'))

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == "/retrain":
            try:
                result = trainer.train_pipeline()
                predictor.load_artifacts()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self._send_cors_headers()
                self.end_headers()
                response = {
                    "status": "success",
                    "message": "LightFM Recommendation Model successfully retrained and reloaded into memory.",
                    "details": result
                }
                self.wfile.write(json.dumps(response).encode('utf-8'))
                return
            except Exception as e:
                logger.error(f"Retraining error: {e}")
                self.send_response(500)
                self.send_header("Content-Type", "application/json")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
                return

def run_server():
    port = API_PORT
    logger.info(f"Starting AgriLink ML Recommendation HTTP REST API Server on port {port}...")
    with socketserver.TCPServer(("", port), RecommenderAPIHandler) as httpd:
        logger.info(f"Serving REST API at http://localhost:{port}")
        httpd.serve_forever()

if __name__ == "__main__":
    run_server()
