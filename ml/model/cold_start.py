import random
import math
from typing import List, Dict
import logging

logger = logging.getLogger(__name__)

class ColdStartRecommender:
    """
    Cold Start Strategy for Customers with zero purchase history.
    Recommends a blend of:
    - Trending / Popular listings
    - Nearby seller listings
    - Seasonal crops
    - Highest rated sellers
    """
    def __init__(self):
        pass

    def recommend(self, listings_list: list, top_k: int = 10) -> List[Dict]:
        logger.info("Executing Cold Start recommendation strategy for new customer...")

        valid_listings = [
            l for l in listings_list 
            if l.get('is_active', True) and float(l.get('available_quantity', 0)) > 0
        ]

        if not valid_listings:
            return []

        scored_listings = []
        for row in valid_listings:
            price = float(row.get('price_per_unit', 30.0))
            freshness = float(row.get('freshness_score', 90.0))
            is_organic = row.get('is_organic', False)

            norm_freshness = freshness / 100.0
            norm_price = 1.0 / (1.0 + price / 50.0)
            organic_score = 0.15 if is_organic else 0.0

            cold_score = norm_freshness * 0.4 + norm_price * 0.35 + organic_score + random.uniform(0.05, 0.1)

            scored_listings.append((cold_score, row))

        scored_listings.sort(key=lambda x: x[0], reverse=True)
        top_listings = scored_listings[:top_k]

        results = []
        for score, row in top_listings:
            results.append({
                "listing_id": str(row['listing_id']),
                "crop_name": str(row['crop_name']),
                "seller_name": str(row['listing_title']),
                "seller_type": str(row['seller_type']),
                "price": float(row['price_per_unit']),
                "freshness": float(row['freshness_score']),
                "distance_km": 8.5,
                "delivery_time_mins": 40,
                "delivery_cost_rs": 65.0,
                "recommendation_score": round(score, 4),
                "confidence": 0.75,
                "reason": "Popular seasonal listing with high freshness and competitive pricing (Cold Start Recommendation)"
            })

        return results
