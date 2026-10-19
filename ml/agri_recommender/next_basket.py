"""
Next-Basket Recommendation Module
AgriLink Customer Recommendation Engine — Module 4

EXACT implementation from notebook 01_next_basket_recommendation.ipynb.

Algorithm (Personal Frequency + Global Fallback):
  1. Build customer's chronological basket sequences from order history.
  2. Score candidate items: personal_count[item] (frequency in their baskets).
  3. Fallback ordering: global_counts across all customers for items not in personal history.
  4. Return top_k items.

Metrics (from notebook evaluation):
  - Recall@5 and Recall@10 on held-out last basket
  - NDCG@10 for ranking quality

Cold-start: customer with no history → pure global frequency fallback.
No pkl file needed: this is a frequency-count model, no training required.
"""
import pandas as pd
import numpy as np
from collections import Counter


def _build_order_table(purchase_data: pd.DataFrame) -> pd.DataFrame:
    """
    Group purchase rows into per-order baskets.
    Returns: DataFrame with columns [customer_id, order_id, order_date, basket]
    where basket is a sorted list of crop_name values.
    """
    if purchase_data.empty:
        return pd.DataFrame()

    # Normalise column names
    id_col = "customer_id" if "customer_id" in purchase_data.columns else "CustomerID"
    oid_col = "order_id" if "order_id" in purchase_data.columns else "OrderID"
    crop_col = "crop_name" if "crop_name" in purchase_data.columns else "Product"
    date_col = "created_at" if "created_at" in purchase_data.columns else "OrderDate"

    grp = (
        purchase_data
        .groupby([id_col, oid_col], as_index=False)
        .agg(
            order_date=(date_col, "min"),
            basket=(crop_col, lambda x: sorted(set(x.dropna())))
        )
    )
    grp = grp.rename(columns={id_col: "customer_id", oid_col: "order_id"})
    grp = grp.sort_values(["customer_id", "order_date", "order_id"])
    return grp


def _build_global_counts(order_table: pd.DataFrame) -> Counter:
    """
    Build global item frequency counter across all customers and orders.
    Used as the cold-start / fallback ranking signal.
    """
    counter = Counter()
    for baskets in order_table["basket"]:
        for item in baskets:
            counter[item] += 1
    return counter


def recommend_next_basket(history_baskets: list, top_k: int = 5, fallback_counts: Counter = None) -> list:
    """
    Exact implementation from notebook cell 4.

    Args:
        history_baskets: List of basket-lists (each basket is a list/set of crop names)
        top_k: Number of items to return
        fallback_counts: Global frequency Counter for items not in personal history

    Returns:
        List of top_k recommended crop names.
    """
    personal_counts = Counter(p for basket in history_baskets for p in basket)
    ranked = [p for p, _ in personal_counts.most_common()]

    fallback = fallback_counts or Counter()
    for p, _ in fallback.most_common():
        if p not in ranked:
            ranked.append(p)

    return ranked[:top_k]


def predict_next_basket(
    purchase_data: pd.DataFrame,
    catalog: pd.DataFrame,
    customer_id,
    top_n: int = 6
) -> pd.DataFrame:
    """
    Main API function: Predict next basket for a customer.
    Wraps recommend_next_basket() with catalog enrichment and cold-start handling.

    Cold-start (no history): Returns globally most-purchased crops.

    Args:
        purchase_data: Full purchase DataFrame (all customers)
        catalog: Active listings catalog DataFrame
        customer_id: Target customer
        top_n: Number of recommendations

    Returns:
        DataFrame with recommendation rows including listing metadata.
    """
    c_str = str(customer_id)
    order_table = _build_order_table(purchase_data)
    global_counts = _build_global_counts(order_table)

    # Get this customer's basket history
    customer_baskets_df = order_table[order_table["customer_id"] == c_str].copy() if not order_table.empty else pd.DataFrame()

    if customer_baskets_df.empty or len(customer_baskets_df) < 1:
        # Cold-start: use global frequency
        is_cold_start = True
        history_baskets = []
    else:
        is_cold_start = False
        history_baskets = customer_baskets_df["basket"].tolist()

    # Get recommendations using exact notebook algorithm
    recommended_crops = recommend_next_basket(history_baskets, top_k=top_n * 2, fallback_counts=global_counts)

    # Exclude crops in the most recent basket (already have them)
    if not is_cold_start and history_baskets:
        last_basket = set(history_baskets[-1])
        recommended_crops = [c for c in recommended_crops if c not in last_basket]

    # Enrich with catalog metadata
    results = []
    seen = set()
    crop_col = "crop_name" if "crop_name" in catalog.columns else "Product"

    for rank, crop in enumerate(recommended_crops):
        if crop in seen or len(results) >= top_n:
            break
        seen.add(crop)

        cat_row = catalog[catalog[crop_col].astype(str) == crop].head(1) if not catalog.empty else pd.DataFrame()
        listing_id = str(cat_row.iloc[0].get("listing_id", f"nbr-{rank}")) if not cat_row.empty else f"nbr-{rank}"
        crop_id = str(cat_row.iloc[0].get("crop_id", f"crop-{rank}")) if not cat_row.empty else f"crop-{rank}"
        price = float(cat_row.iloc[0].get("price_per_unit", 35.0)) if not cat_row.empty else 35.0
        rating = float(cat_row.iloc[0].get("rating_avg", 4.8)) if not cat_row.empty else 4.8
        grade = str(cat_row.iloc[0].get("grade", "A")) if not cat_row.empty else "A"
        is_organic = bool(cat_row.iloc[0].get("is_organic", False)) if not cat_row.empty else False
        freq = global_counts.get(crop, 0)
        score = round(1.0 - rank * 0.06, 4) if not is_cold_start else round(1.0 - rank * 0.04, 4)

        rec_type = "NEXT_BASKET_COLD_START" if is_cold_start else "NEXT_BASKET"
        if is_cold_start:
            reason = f"🌟 Trending farm-fresh pick — ordered {freq} times by AgriLink customers. Perfect for your first basket!"
            badge = f"#{rank+1} Popular"
        else:
            reason = f"🛒 Based on your basket patterns — you've bought this in {sum(1 for b in history_baskets if crop in b)} of {len(history_baskets)} past orders."
            badge = f"#{rank+1} Next Pick"

        results.append({
            "customer_id": c_str,
            "listing_id": listing_id,
            "crop_id": crop_id,
            "crop_name": crop,
            "price_per_unit": price,
            "rating_avg": rating,
            "grade": grade,
            "is_organic": is_organic,
            "score": score,
            "recommendation_type": rec_type,
            "reason": reason,
            "badge": badge
        })

    return pd.DataFrame(results) if results else pd.DataFrame()
