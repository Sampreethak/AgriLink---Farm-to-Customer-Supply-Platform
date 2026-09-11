import os
import joblib
import pandas as pd
import numpy as np

class DynamicPricingPredictor:
    def __init__(self, model_path=None):
        if model_path is None:
            base_dir = os.path.dirname(os.path.abspath(__file__))
            model_path = os.path.join(base_dir, "pricing_engine.joblib")
        self.model_path = model_path
        self.payload = None
        self.load_model()
        
    def load_model(self):
        try:
            if os.path.exists(self.model_path):
                self.payload = joblib.load(self.model_path)
                print(f"[OK] Dynamic Pricing Engine loaded from: {self.model_path}")
            else:
                print(f"[Warning] Pricing model not found at {self.model_path}")
        except Exception as e:
            print(f"Error loading pricing engine: {e}")
            self.payload = None

    def calculate_price_and_shares(self, commodity, variety="Hybrid / Nati", grade="Grade A",
                                origin_district="Mandya", distance_km=85.0,
                                is_organic=False, custom_apmc_modal=None):
        if not self.payload or "model" not in self.payload:
            base_price = 35.0 if not is_organic else 45.0
            return self._build_shares_response(commodity, base_price, 25.0, origin_district, distance_km, is_organic, grade)

        benchmarks = self.payload.get("latest_apmc_benchmarks", {})
        apmc_modal = custom_apmc_modal if custom_apmc_modal is not None else benchmarks.get(commodity, 28.0)

        input_df = pd.DataFrame([{
            "commodity": commodity,
            "variety": variety,
            "grade": grade,
            "origin_district": origin_district,
            "distance_km": float(distance_km),
            "is_organic": bool(is_organic),
            "apmc_modal_price_per_kg": float(apmc_modal)
        }])

        pred_price = float(self.payload["model"].predict(input_df)[0])
        pred_price = max(apmc_modal * 1.05, round(pred_price, 2))
        return self._build_shares_response(commodity, pred_price, apmc_modal, origin_district, distance_km, is_organic, grade)

    def _build_shares_response(self, commodity, consumer_price, apmc_modal, origin, distance_km, is_organic=False, grade="Grade A"):
        farmer_share_pct = 0.68
        aggregator_share_pct = 0.10
        delivery_share_pct = 0.14
        platform_share_pct = 0.08

        farmer_payout = round(consumer_price * farmer_share_pct, 2)
        aggregator_payout = round(consumer_price * aggregator_share_pct, 2)
        delivery_payout = round(consumer_price * delivery_share_pct, 2)
        platform_fee = round(consumer_price * platform_share_pct, 2)

        traditional_farmer_payout = round(apmc_modal * 0.32, 2)
        farmer_benefit_pct = round(((farmer_payout - traditional_farmer_payout) / (traditional_farmer_payout + 1e-6)) * 100, 1)

        return {
            "commodity": commodity,
            "grade": grade,
            "is_organic": is_organic,
            "corridor": f"{origin} -> Bengaluru ({int(distance_km)} km)",
            "apmc_mandi_benchmark_per_kg": apmc_modal,
            "predicted_fair_consumer_price_per_kg": consumer_price,
            "fair_share_breakdown": {
                "farmer": {
                    "role": "Farmer (Producer)",
                    "share_pct": 68.0,
                    "payout_per_kg": farmer_payout,
                    "benefit_description": f"+{farmer_benefit_pct}%\ higher payout vs APMC traditional middlemen rate (Rs.{traditional_farmer_payout}/kg)"
                },
                "aggregator": {
                    "role": "SHG Homemaker (Tier-1) + Corridor Hub (Tier-2)",
                    "share_pct": 10.0,
                    "payout_per_kg": aggregator_payout,
                    "benefit_description": "Fair compensation for local SHG collection, quality grading, and 4-6 hr staging"
                },
                "delivery_partner": {
                    "role": "Corridor Highway Transport & Last-Mile Rider",
                    "share_pct": 14.0,
                    "payout_per_kg": delivery_payout,
                    "benefit_description": f"Covers Mandya-Bengaluru highway pooling ({int(distance_km)} km) and doorstep delivery"
                },
                "platform": {
                    "role": "AgriLink Platform & Quality Tech",
                    "share_pct": 8.0,
                    "payout_per_kg": platform_fee,
                    "benefit_description": "AI dynamic pricing oracle, QR traceability, and escrow payment settlement"
                }
            },
            "consumer_savings": {
                "supermarket_benchmark_per_kg": round(consumer_price * 1.25, 2),
                "savings_pct": 20.0,
                "savings_description": "Fresh morning harvest delivered at 20% lower price than city supermarket retail"
            }
        }

if __name__ == "__main__":
    p = DynamicPricingPredictor()
    res = p.calculate_price_and_shares("Tomato", is_organic=True, origin_district="Mandya", distance_km=95.0)
    print("Commodity:", res['commodity'])
    print("Fair Consumer Price: Rs.", res['predicted_fair_consumer_price_per_kg'])
    print("Farmer Payout (68%): Rs.", res['fair_share_breakdown']['farmer']['payout_per_kg'])
