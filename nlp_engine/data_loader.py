import os
from pathlib import Path
import pandas as pd
from typing import Dict

def find_repo_root() -> Path:
    """Finds repository root directory."""
    curr = Path(__file__).resolve().parent
    for p in [curr, curr.parent, curr.parent.parent]:
        if (p / "database").exists() or (p / "backend_fastapi").exists():
            return p
    return curr.parent

def load_nlp_tables() -> Dict[str, pd.DataFrame]:
    """
    Loads database tables required by the Farmer NLP Query Engine.
    Prefers database/csv/ and falls back to ml recommendation datasets.
    """
    root = find_repo_root()
    csv_dir = root / "database" / "csv"
    fallback_dir = root / "ml" / "recommendation_research" / "data"

    table_mapping = {
        "orders": ["customer_order.csv", "customer_order_rows.csv"],
        "order_items": ["order_item.csv", "order_item_rows.csv"],
        "seller_listings": ["seller_listing.csv", "seller_listing_rows.csv"],
        "inventory": ["inventory_item.csv", "inventory_item_rows.csv"],
        "crops": ["crop.csv", "crop_rows.csv"],
        "farmer_profile": ["farmer_profile.csv", "farmer_profile_rows.csv"],
        "reviews": ["customer_review.csv", "customer_review_rows.csv"],
        "pricing_log": ["ml_pricing_log.csv", "ml_pricing_log_rows.csv"]
    }

    loaded = {}
    for table_key, candidate_files in table_mapping.items():
        found = False
        for directory in [csv_dir, fallback_dir]:
            if not directory.exists():
                continue
            for f_name in candidate_files:
                p = directory / f_name
                if p.exists():
                    try:
                        loaded[table_key] = pd.read_csv(p)
                        found = True
                        break
                    except Exception:
                        pass
            if found:
                break
        if not found:
            loaded[table_key] = pd.DataFrame()

    return loaded
