import os
import joblib
import numpy as np
import pandas as pd

class RecommendationPredictor:
    def __init__(self, artifacts_dir=None):
        if artifacts_dir is None:
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            artifacts_dir = os.path.join(base_dir, "artifacts")
        
        self.artifacts_dir = artifacts_dir
        self.model = None
        self.vectorizer = None
        self.mappings = None
        self.load_artifacts()
        
    def load_artifacts(self):
        try:
            model_path = os.path.join(self.artifacts_dir, "lightfm_model.joblib")
            mappings_path = os.path.join(self.artifacts_dir, "id_mappings.joblib")
            
            if os.path.exists(model_path) and os.path.exists(mappings_path):
                self.model = joblib.load(model_path)
                self.mappings = joblib.load(mappings_path)
                print(f"Successfully loaded ML Recommendation Engine artifacts from: {self.artifacts_dir}")
            else:
                print(f"Warning: Artifacts not found at {self.artifacts_dir}. Cold-start mode active.")
        except Exception as e:
            print(f"Error loading artifacts: {e}")
            
    def recommend_for_customer(self, customer_id, top_k=10):
        if self.mappings and 'user2idx' in self.mappings:
            user2idx = self.mappings['user2idx']
            idx2item = self.mappings['idx2item']
            scores = self.mappings['collaborative_scores']
            listings = self.mappings['listings']
            
            if customer_id in user2idx:
                u_idx = user2idx[customer_id]
                user_scores = scores[u_idx]
                top_indices = np.argsort(-user_scores)[:top_k]
                
                results = []
                for idx in top_indices:
                    item_id = idx2item[idx]
                    listing = next((l for l in listings if l['listing_id'] == item_id), None)
                    if listing:
                        item_dict = dict(listing)
                        item_dict['recommendation_score'] = float(user_scores[idx])
                        results.append(item_dict)
                return results
                
        # Cold start fallback: return default top-rated listings sorted by rating_avg
        if self.mappings and 'listings' in self.mappings:
            sorted_listings = sorted(self.mappings['listings'], key=lambda x: x.get('rating_avg', 0), reverse=True)
            return sorted_listings[:top_k]
            
        return []

if __name__ == "__main__":
    predictor = RecommendationPredictor()
    recs = predictor.recommend_for_customer("55555555-5555-5555-5555-555555555555", top_k=5)
    print("Sample Top-5 Recommendations for Customer:")
    for r in recs:
        print(f"  - {r.get('title')} | Price: Rs.{r.get('price_per_unit')} / {r.get('unit')}")
