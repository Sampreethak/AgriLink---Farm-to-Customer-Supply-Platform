import os
import time
import json
import urllib.request
import urllib.error
import urllib.parse
from typing import Dict, Any, Optional

class MandiApiClient:
    """
    Official data.gov.in AGMARKNET APMC Mandi Live Price Client (with keyless fallback).
    Resource: https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070
    """
    DATA_GOV_URL = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
    FALLBACK_API_URL = "https://mandi-api.onrender.com/v1"
    
    # Aliases mapping AgriLink standard commodities to Mandi API commodity strings
    COMMODITY_ALIASES = {
        "tomato": ["tomato"],
        "potato": ["potato"],
        "onion": ["onion"],
        "carrot": ["carrot"],
        "cabbage": ["cabbage"],
        "green capsicum": ["chilly capsicum", "capsicum"],
        "capsicum": ["capsicum", "chilly capsicum"],
        "green chilli": ["green chilli", "green chilly", "chilli"],
        "chilli": ["green chilli", "green chilly"],
        "palak": ["palak", "spinach"],
        "coriander": ["corriander seed", "coriander"],
        "ginger": ["ginger(green)", "ginger(dry)", "ginger"],
        "garlic": ["garlic"],
        "banana": ["banana"],
        "papaya": ["papaya"],
        "ragi": ["ragi(finger millet)", "ragi"],
        "rice": ["paddy(common)", "rice"],
        "paddy": ["paddy(common)", "paddy"],
        "wheat": ["wheat"],
        "brinjal": ["brinjal"],
        "cauliflower": ["cauliflower"],
        "green peas": ["green peas", "peas"],
        "groundnut": ["groundnut"],
        "jaggery": ["gur(jaggery)", "jaggery"],
        "gur": ["gur(jaggery)"],
        "maize": ["maize"],
        "bitter gourd": ["bitter gourd"],
        "bottle gourd": ["bottle gourd"],
        "cucumber": ["cucumbar(kheera)", "cucumber"],
        "radish": ["raddish", "radish"]
    }

    # Baseline fallback rates (Rs./kg) if external API is temporarily unreachable
    FALLBACK_BENCHMARKS = {
        "Tomato": 22.20,
        "Potato": 17.70,
        "Onion": 26.70,
        "Carrot": 34.60,
        "Cabbage": 16.00,
        "Green Peas": 57.50,
        "Green Capsicum": 46.00,
        "Green Chilli": 29.90,
        "Palak": 17.10,
        "Coriander": 13.50,
        "Mint": 13.30,
        "Ginger": 45.00,
        "Garlic": 96.50,
        "Banana": 31.90,
        "Papaya": 25.00,
        "Pomegranate": 100.30,
        "Grapes": 63.90,
        "Ragi": 34.00,
        "Rice": 47.80,
        "Brinjal": 24.00,
        "Cauliflower": 20.00
    }

    def __init__(self, cache_ttl_seconds: int = 3600):
        self.cache_ttl = cache_ttl_seconds
        self._cached_data = None
        self._cache_timestamp = 0.0
        self.api_key = os.getenv("DATA_GOV_APMC_API_KEY") or self._load_key_from_dotenv()

    def _load_key_from_dotenv(self) -> str:
        """Reads DATA_GOV_APMC_API_KEY from backend_fastapi/.env if not already exported."""
        try:
            env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "backend_fastapi", ".env")
            if os.path.exists(env_path):
                with open(env_path, "r", encoding="utf-8") as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith("DATA_GOV_APMC_API_KEY="):
                            return line.split("=", 1)[1].strip().strip('"').strip("'")
        except Exception:
            pass
        return ""

    def _fetch_from_data_gov(self, state_filter: Optional[str] = "Karnataka") -> list:
        """Fetches live AGMARKNET APMC records from data.gov.in using the registered API key."""
        if not self.api_key:
            return []
        params = {
            "api-key": self.api_key,
            "format": "json",
            "limit": "500",
        }
        if state_filter:
            params["filters[state.keyword]"] = state_filter
        url = f"{self.DATA_GOV_URL}?{urllib.parse.urlencode(params)}"
        req = urllib.request.Request(
            url,
            headers={"User-Agent": "AgriLink-DynamicPricing/2.0", "Accept": "application/json"}
        )
        with urllib.request.urlopen(req, timeout=12) as response:
            if response.status == 200:
                payload = json.loads(response.read().decode("utf-8"))
                return payload.get("records", []) or []
        return []

    def fetch_karnataka_prices(self, force_refresh: bool = False) -> Dict[str, Any]:
        """Fetches latest APMC market prices from data.gov.in (Karnataka first, then All-India), with keyless fallback."""
        now = time.time()
        if not force_refresh and self._cached_data and (now - self._cache_timestamp < self.cache_ttl):
            return self._cached_data

        # 1. Primary: Official data.gov.in AGMARKNET API with API Key
        if self.api_key:
            try:
                records = self._fetch_from_data_gov("Karnataka")
                if not records:
                    # Fallback within data.gov.in to All-India live daily batch if Karnataka hasn't reported yet today
                    records = self._fetch_from_data_gov(None)
                if records:
                    normalized = {
                        "success": True,
                        "source": "data.gov.in AGMARKNET Live API",
                        "data": records,
                    }
                    self._cached_data = normalized
                    self._cache_timestamp = now
                    print(f"[OK] Fetched {len(records)} live APMC records from data.gov.in AGMARKNET API.")
                    return normalized
            except Exception as e:
                print(f"[Warning] data.gov.in APMC API error: {e}. Trying fallback feed.")

        # 2. Secondary: Keyless Mandi Price API fallback
        url = f"{self.FALLBACK_API_URL}/prices?state=Karnataka"
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": "AgriLink-DynamicPricing/1.0",
                "Accept": "application/json"
            }
        )

        try:
            with urllib.request.urlopen(req, timeout=12) as response:
                if response.status == 200:
                    payload = json.loads(response.read().decode("utf-8"))
                    if payload.get("success") and "data" in payload:
                        payload.setdefault("source", "Mandi Price API (AGMARKNET Karnataka Feed)")
                        self._cached_data = payload
                        self._cache_timestamp = now
                        print(f"[OK] Fetched {len(payload['data'])} live APMC records from fallback Mandi API.")
                        return payload
        except Exception as e:
            print(f"[Warning] Mandi Price API live fetch error: {e}. Using cached/fallback APMC data.")

        return self._cached_data or {"success": False, "data": []}

    def get_commodity_price(self, commodity: str, origin_district: Optional[str] = "Mandya") -> Dict[str, Any]:
        """
        Retrieves real-time modal price per kg for a commodity.
        Prioritizes corridor markets (Mandya, Ramanagara, Bengaluru South) when available.
        """
        comm_clean = commodity.strip().lower()
        search_terms = self.COMMODITY_ALIASES.get(comm_clean, [comm_clean])

        api_response = self.fetch_karnataka_prices()
        items = api_response.get("data", [])

        corridor_matches = []
        general_matches = []

        for item in items:
            item_comm = item.get("commodity", "").lower()
            if any(term in item_comm for term in search_terms):
                dist = item.get("district", "")
                mkt = item.get("market", "")
                modal_per_quintal = float(item.get("modal_price", 0))
                if modal_per_quintal <= 0:
                    continue

                record = {
                    "commodity": commodity,
                    "api_commodity": item.get("commodity"),
                    "variety": item.get("variety"),
                    "grade": item.get("grade"),
                    "market": mkt,
                    "district": dist,
                    "modal_price_per_kg": round(modal_per_quintal / 100.0, 2),
                    "min_price_per_kg": round(float(item.get("min_price", modal_per_quintal)) / 100.0, 2),
                    "max_price_per_kg": round(float(item.get("max_price", modal_per_quintal)) / 100.0, 2),
                    "arrival_date": item.get("arrival_date"),
                    "is_live_api": True,
                    "source": api_response.get("source", "data.gov.in AGMARKNET Live API")
                }

                # Check if in Mandya-Bengaluru corridor
                is_corridor = (
                    "mandya" in dist.lower() or 
                    "ramanagara" in dist.lower() or 
                    "bengaluru" in dist.lower() or 
                    "mysore" in dist.lower() or 
                    "channapatna" in mkt.lower()
                )
                if is_corridor:
                    corridor_matches.append(record)
                else:
                    general_matches.append(record)

        if corridor_matches:
            # Corridor match found (e.g. Mandya APMC / Ramanagara APMC)
            return corridor_matches[0]
        elif general_matches:
            # Fall back to Karnataka average/first match
            avg_modal = round(sum(m["modal_price_per_kg"] for m in general_matches) / len(general_matches), 2)
            first = general_matches[0].copy()
            first["modal_price_per_kg"] = avg_modal
            return first

        # Fallback to local baseline benchmarks
        fallback_modal = self.FALLBACK_BENCHMARKS.get(commodity.title(), 28.0)
        return {
            "commodity": commodity,
            "api_commodity": commodity,
            "variety": "Local / Hybrid",
            "grade": "Grade A",
            "market": f"{origin_district} APMC Yard",
            "district": origin_district,
            "modal_price_per_kg": fallback_modal,
            "min_price_per_kg": round(fallback_modal * 0.85, 2),
            "max_price_per_kg": round(fallback_modal * 1.25, 2),
            "arrival_date": "Historical APMC Karnataka Baseline",
            "is_live_api": False,
            "source": "APMC Karnataka Historical Baseline (Fallback)"
        }

    def get_all_benchmarks(self) -> Dict[str, float]:
        """Returns benchmark modal rates (Rs./kg) for all core commodities."""
        benchmarks = {}
        for comm in self.FALLBACK_BENCHMARKS.keys():
            res = self.get_commodity_price(comm)
            benchmarks[comm] = res["modal_price_per_kg"]
        return benchmarks
