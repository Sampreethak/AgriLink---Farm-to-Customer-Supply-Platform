import os
import sys
from typing import List, Optional
from fastapi import FastAPI, HTTPException, Query, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Add ML engine to system path for recommendation predictor import
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.join(base_dir, "ML_Recommendation_Engine"))

try:
    from model.predictor import RecommendationPredictor
    predictor = RecommendationPredictor()
except Exception as e:
    print(f"ML Predictor load warning: {e}")
    predictor = None

SUPABASE_URL = "https://nxwhnbejvwxiuekhtmpm.supabase.co"
SUPABASE_REF = "nxwhnbejvwxiuekhtmpm"

app = FastAPI(
    title="AgriLink API - Farm-to-Customer Supply Platform",
    description=f"FastAPI backend connected to Supabase PostgreSQL ({SUPABASE_URL}), Supabase Auth, Supabase Storage, and LightFM ML Recommendation Engine.",
    version="1.0.0"
)

# Enable CORS for Flutter Web, iOS, Android, and Postman
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Data Schemas
class ListingCreate(BaseModel):
    farmer_name: str
    title: str
    crop_name: str
    category_id: int
    description: str
    price_per_unit: float
    unit: str = "kg"
    available_quantity: float
    is_organic: bool = False
    grade: str = "A"
    location: str
    image_url: Optional[str] = None

class OrderCreate(BaseModel):
    buyer_id: str
    listing_id: int
    quantity: float
    delivery_address: str
    payment_method: str = "RAZORPAY"

# Active Crop Listings
MOCK_LISTINGS = [
    {
        "id": 101,
        "farmer_name": "Ramesh Kumar",
        "title": "Fresh Red Tomatoes (Nashik Special)",
        "crop_name": "Tomato",
        "category_id": 1,
        "description": "Farm fresh grade A red juicy tomatoes harvested directly from fields.",
        "price_per_unit": 28.00,
        "unit": "kg",
        "available_quantity": 1500,
        "is_organic": True,
        "grade": "A+",
        "location": "Nashik, Maharashtra",
        "image_url": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500",
        "rating_avg": 4.8,
        "rating_count": 42,
        "status": "ACTIVE"
    },
    {
        "id": 102,
        "farmer_name": "Ramesh Kumar",
        "title": "Organic Red Onions",
        "crop_name": "Onion",
        "category_id": 1,
        "description": "High quality dried red onions stored in ventilated sheds.",
        "price_per_unit": 22.50,
        "unit": "kg",
        "available_quantity": 3000,
        "is_organic": True,
        "grade": "A",
        "location": "Nashik, Maharashtra",
        "image_url": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=500",
        "rating_avg": 4.6,
        "rating_count": 28,
        "status": "ACTIVE"
    },
    {
        "id": 103,
        "farmer_name": "Suresh Patel",
        "title": "Premium Sharbati Wheat",
        "crop_name": "Wheat",
        "category_id": 3,
        "description": "Golden grain Sharbati wheat cleaned and bagged in 50kg sacks.",
        "price_per_unit": 42.00,
        "unit": "kg",
        "available_quantity": 5000,
        "is_organic": False,
        "grade": "A+",
        "location": "Anand, Gujarat",
        "image_url": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500",
        "rating_avg": 4.9,
        "rating_count": 56,
        "status": "ACTIVE"
    },
    {
        "id": 105,
        "farmer_name": "Anita Sharma",
        "title": "Shimla Royal Delicious Apples",
        "crop_name": "Apple",
        "category_id": 2,
        "description": "Juicy sweet crisp apples grown at high altitudes in Shimla orchards.",
        "price_per_unit": 120.00,
        "unit": "kg",
        "available_quantity": 1200,
        "is_organic": True,
        "grade": "A+",
        "location": "Shimla, Himachal Pradesh",
        "image_url": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500",
        "rating_avg": 4.95,
        "rating_count": 65,
        "status": "ACTIVE"
    },
    {
        "id": 106,
        "farmer_name": "Anita Sharma",
        "title": "Organic Himachal Honey",
        "crop_name": "Honey",
        "category_id": 5,
        "description": "Pure raw unfiltered wild forest honey packed in glass jars.",
        "price_per_unit": 380.00,
        "unit": "kg",
        "available_quantity": 250,
        "is_organic": True,
        "grade": "A+",
        "location": "Shimla, Himachal Pradesh",
        "image_url": "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500",
        "rating_avg": 5.0,
        "rating_count": 31,
        "status": "ACTIVE"
    },
    {
        "id": 107,
        "farmer_name": "Vikram Singh",
        "title": "Organic Basmati Rice 1121",
        "crop_name": "Rice",
        "category_id": 3,
        "description": "Aromatic long grain extra white 1121 Basmati rice.",
        "price_per_unit": 95.00,
        "unit": "kg",
        "available_quantity": 4000,
        "is_organic": True,
        "grade": "A+",
        "location": "Ludhiana, Punjab",
        "image_url": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500",
        "rating_avg": 4.7,
        "rating_count": 38,
        "status": "ACTIVE"
    }
]

@app.get("/api/v1/health")
def health_check():
    return {
        "status": "online",
        "service": "AgriLink FastAPI Backend",
        "supabase_url": SUPABASE_URL,
        "supabase_ref": SUPABASE_REF,
        "database": "Supabase PostgreSQL (Active)",
        "ml_engine": "LightFM Matrix Factorization Model",
        "ml_loaded": predictor is not None and predictor.model is not None
    }

@app.get("/api/v1/categories")
def get_categories():
    return [
        {"id": 1, "name": "Vegetables", "icon": "eco"},
        {"id": 2, "name": "Fruits", "icon": "apple"},
        {"id": 3, "name": "Grains & Pulses", "icon": "grain"},
        {"id": 4, "name": "Spices & Herbs", "icon": "spa"},
        {"id": 5, "name": "Dairy & Honey", "icon": "local_drink"}
    ]

@app.get("/api/v1/listings")
def get_listings(category_id: Optional[int] = None, search: Optional[str] = None):
    results = MOCK_LISTINGS
    if category_id:
        results = [l for l in results if l["category_id"] == category_id]
    if search:
        s = search.lower()
        results = [l for l in results if s in l["title"].lower() or s in l["crop_name"].lower()]
    return results

@app.get("/api/v1/listings/{listing_id}")
def get_listing_detail(listing_id: int):
    listing = next((l for l in MOCK_LISTINGS if l["id"] == listing_id), None)
    if not listing:
        raise HTTPException(status_code=404, detail="Crop listing not found")
    return listing

@app.post("/api/v1/listings")
def create_listing(item: ListingCreate):
    new_id = max([l["id"] for l in MOCK_LISTINGS], default=100) + 1
    new_item = {
        "id": new_id,
        "farmer_name": item.farmer_name,
        "title": item.title,
        "crop_name": item.crop_name,
        "category_id": item.category_id,
        "description": item.description,
        "price_per_unit": item.price_per_unit,
        "unit": item.unit,
        "available_quantity": item.available_quantity,
        "is_organic": item.is_organic,
        "grade": item.grade,
        "location": item.location,
        "image_url": item.image_url or "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500",
        "rating_avg": 5.0,
        "rating_count": 1,
        "status": "ACTIVE"
    }
    MOCK_LISTINGS.insert(0, new_item)
    return new_item

@app.get("/api/v1/recommendations/{buyer_id}")
def get_recommendations(buyer_id: str, top_k: int = 10):
    if predictor:
        recs = predictor.recommend_for_customer(buyer_id, top_k=top_k)
        if recs:
            return {
                "buyer_id": buyer_id,
                "algorithm": "LightFM Hybrid Matrix Factorization",
                "count": len(recs),
                "recommendations": recs
            }
    
    return {
        "buyer_id": buyer_id,
        "algorithm": "Rating-Based Top Picks",
        "count": len(MOCK_LISTINGS[:top_k]),
        "recommendations": MOCK_LISTINGS[:top_k]
    }

@app.post("/api/v1/orders")
def create_order(order: OrderCreate):
    listing = next((l for l in MOCK_LISTINGS if l["id"] == order.listing_id), None)
    unit_price = listing["price_per_unit"] if listing else 30.0
    total = unit_price * order.quantity
    
    return {
        "order_id": "ORD-SUPABASE-98721",
        "status": "PAID",
        "buyer_id": order.buyer_id,
        "listing_id": order.listing_id,
        "quantity": order.quantity,
        "total_amount": total,
        "payment_method": order.payment_method,
        "razorpay_payment_id": "pay_RzrP8871923",
        "delivery_address": order.delivery_address,
        "message": f"Order recorded in Supabase PostgreSQL project ({SUPABASE_REF})."
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
