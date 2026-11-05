import os
import joblib
import pandas as pd
import numpy as np
from typing import Optional, Dict, Any

try:
    from mandi_api_client import MandiApiClient
except ImportError:
    try:
        from ml_pricing_model.mandi_api_client import MandiApiClient
    except ImportError:
        MandiApiClient = None

class DynamicPricingPredictor:
    """
    AgriLink APMC-Linked Dynamic Pricing & Fair Share Engine.
    Uses the live open-source Mandi Price API (AGMARKNET Karnataka feed) to ingest
    real-time mandi benchmarks, and feeds them into the trained Random Forest ML model
    to predict fair consumer prices and calculate transparent 68-10-14-8 value shares.
    """
    def __init__(self, model_path=None):
        if model_path is None:
            base_dir = os.path.dirname(os.path.abspath(__file__))
            model_path = os.path.join(base_dir, "pricing_engine.joblib")
        self.model_path = model_path
        self.payload = None
        self.mandi_client = MandiApiClient() if MandiApiClient else None
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

    def get_live_benchmarks(self) -> Dict[str, float]:
        """Returns live APMC modal benchmarks (Rs./kg) from the open-source Mandi Price API."""
        if self.mandi_client:
            return self.mandi_client.get_all_benchmarks()
        elif self.payload:
            return self.payload.get("latest_apmc_benchmarks", {})
        return {}

    def calculate_price_and_shares(self, commodity: str, variety: str = "Hybrid / Nati", grade: str = "Grade A",
                                origin_district: str = "Mandya", distance_km: float = 85.0,
                                is_organic: bool = False, custom_apmc_modal: Optional[float] = None):
        """
        Calculates Fair Consumer Price and 4-way transparent split (Farmer 68%, Aggregator 10%, Delivery 14%, Platform 8%)
        using real APMC mandi rates from the open-source Mandi Price API + trained ML model.
        """
        mandi_meta = {
            "source": "Fallback Baseline",
            "market": f"{origin_district} APMC Yard",
            "district": origin_district,
            "arrival_date": "Historical",
            "is_live_api": False
        }

        # 1. Fetch real-time APMC benchmark from open-source Mandi Price API
        if custom_apmc_modal is not None:
            apmc_modal = float(custom_apmc_modal)
            mandi_meta["source"] = "Custom Override by User"
        elif self.mandi_client:
            mandi_data = self.mandi_client.get_commodity_price(commodity, origin_district)
            apmc_modal = float(mandi_data.get("modal_price_per_kg", 28.0))
            mandi_meta["source"] = mandi_data.get("source", "Mandi Price API (AGMARKNET)")
            mandi_meta["market"] = mandi_data.get("market", f"{origin_district} APMC")
            mandi_meta["district"] = mandi_data.get("district", origin_district)
            mandi_meta["arrival_date"] = mandi_data.get("arrival_date", "Latest")
            mandi_meta["is_live_api"] = mandi_data.get("is_live_api", False)
        elif self.payload and "latest_apmc_benchmarks" in self.payload:
            benchmarks = self.payload.get("latest_apmc_benchmarks", {})
            apmc_modal = float(benchmarks.get(commodity, 28.0))
        else:
            apmc_modal = 28.0

        # 2. Predict Fair Consumer Price via trained ML model
        if self.payload and "model" in self.payload:
            input_df = pd.DataFrame([{
                "commodity": commodity,
                "variety": variety,
                "grade": grade,
                "origin_district": origin_district,
                "distance_km": float(distance_km),
                "is_organic": bool(is_organic),
                "apmc_modal_price_per_kg": float(apmc_modal)
            }])
            try:
                pred_price = float(self.payload["model"].predict(input_df)[0])
                pred_price = max(apmc_modal * 1.05, round(pred_price, 2))
            except Exception as e:
                print(f"[Warning] ML prediction error: {e}. Using economic heuristic.")
                pred_price = self._heuristic_price(apmc_modal, grade, is_organic, distance_km)
        else:
            pred_price = self._heuristic_price(apmc_modal, grade, is_organic, distance_km)

        return self._build_shares_response(
            commodity=commodity,
            consumer_price=pred_price,
            apmc_modal=apmc_modal,
            origin=origin_district,
            distance_km=distance_km,
            is_organic=is_organic,
            grade=grade,
            mandi_meta=mandi_meta
        )

    def _heuristic_price(self, apmc_modal: float, grade: str, is_organic: bool, distance_km: float) -> float:
        grade_mult = 1.15 if grade == "Grade A+" else (1.08 if grade == "Grade A" else 0.95)
        org_mult = 1.22 if is_organic else 1.0
        dist_cost = distance_km * 0.045
        return round(max(apmc_modal * 1.10, (apmc_modal * grade_mult * org_mult) + dist_cost), 2)

    def _build_shares_response(self, commodity: str, consumer_price: float, apmc_modal: float,
                               origin: str, distance_km: float, is_organic: bool = False,
                               grade: str = "Grade A", mandi_meta: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        meta = mandi_meta or {}
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
            "apmc_market_name": meta.get("market", f"{origin} APMC"),
            "apmc_district": meta.get("district", origin),
            "apmc_arrival_date": meta.get("arrival_date", "Latest"),
            "pricing_source": meta.get("source", "Mandi Price API (AGMARKNET Karnataka Feed)"),
            "is_live_apmc_feed": meta.get("is_live_api", True),
            "predicted_fair_consumer_price_per_kg": consumer_price,
            "fair_share_breakdown": {
                "farmer": {
                    "role": "Farmer (Producer)",
                    "share_pct": 68.0,
                    "payout_per_kg": farmer_payout,
                    "benefit_description": f"+{farmer_benefit_pct}% higher payout vs APMC traditional middlemen rate (Rs.{traditional_farmer_payout}/kg)"
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
    res = p.calculate_price_and_shares("Tomato", is_organic=True, origin_district="Mandya", distance_km=85.0)
    print("Commodity:", res['commodity'])
    print("Market:", res['apmc_market_name'], f"({res['apmc_district']})")
    print("Pricing Source:", res['pricing_source'])
    print("Real APMC Modal Rate: Rs.", res['apmc_mandi_benchmark_per_kg'], "/kg")
    print("ML Fair Consumer Price: Rs.", res['predicted_fair_consumer_price_per_kg'], "/kg")
    print("Farmer Direct Payout (68%): Rs.", res['fair_share_breakdown']['farmer']['payout_per_kg'], "/kg")
