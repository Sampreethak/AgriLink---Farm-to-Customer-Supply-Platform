import numpy as np
import pandas as pd


def recommend_replacements(target_listing_id, catalog: pd.DataFrame, top_n=3):
    """
    Replacement ranking for out-of-stock or alternative listings.
    Uses available same-crop listings + price, rating, quality grade signals.
    """
    target_str = str(target_listing_id)
    catalog_copy = catalog.copy()
    catalog_copy["listing_id_str"] = catalog_copy["listing_id"].astype(str)

    target = catalog_copy[catalog_copy["listing_id_str"] == target_str]
    if target.empty:
        # Fallback to general available listings
        target_crop = None
        target_price = 30.0
    else:
        target_row = target.iloc[0]
        target_crop = target_row.get("crop_id")
        target_price = float(target_row.get("price_per_unit", 30.0))

    if "status" in catalog_copy.columns:
        x = catalog_copy[(catalog_copy["listing_id_str"] != target_str) & catalog_copy["status"].astype(str).str.upper().isin(["AVAILABLE", "ACTIVE"])].copy()
    else:
        x = catalog_copy[catalog_copy["listing_id_str"] != target_str].copy()

    if x.empty:
        x = catalog_copy[catalog_copy["listing_id_str"] != target_str].copy()

    if x.empty:
        return pd.DataFrame()

    if target_crop is not None and "crop_id" in x.columns:
        x["same_crop"] = (x["crop_id"] == target_crop).astype(float)
    else:
        x["same_crop"] = 0.5

    x["price_similarity"] = 1 / (1 + abs(pd.to_numeric(x.get("price_per_unit", 0), errors="coerce").fillna(0) - target_price))
    x["rating_score"] = pd.to_numeric(x.get("rating_avg", 0), errors="coerce").fillna(0) / 5.0

    grade_order = {"A+": 1.0, "A": 0.9, "B": 0.75, "C": 0.6}
    x["grade_score"] = x.get("grade", pd.Series("A", index=x.index)).map(grade_order).fillna(0.7)

    x["replacement_score"] = 0.55 * x["same_crop"] + 0.15 * x["price_similarity"] + 0.15 * x["rating_score"] + 0.15 * x["grade_score"]
    x["recommendation_type"] = "REPLACEMENT"
    x["reason"] = x.apply(
        lambda r: "Same crop alternative listing from nearby farm." if r["same_crop"] == 1.0 else "Alternative crop listing ranked by price, rating, and quality.",
        axis=1
    )
    return x.sort_values("replacement_score", ascending=False).head(top_n).reset_index(drop=True)
