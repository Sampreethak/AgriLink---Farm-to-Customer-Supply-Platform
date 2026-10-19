"""
Recency-Weighted Recommendation Module
AgriLink Customer Recommendation Engine — Module 5

EXACT implementation from notebook 02_recency_weighted_recommendation.ipynb.

Algorithm:
  WeightedScore = Quantity * exp(-decay * AgeDays)
  where decay = 0.03 (default, configurable)

  Aggregated per product: RecencyScore = sum(WeightedScore per row)
  Sorted by (RecencyScore DESC, LastPurchased DESC)

Cold-start: customer with no history → freshest catalog items by harvest_date.
No pkl file needed: purely a scoring function on purchase history.
"""
import pandas as pd
import numpy as np

DEFAULT_DECAY = 0.03  # Matches notebook default; lower = slower fade


def recency_recommendations(
    customer_id,
    df: pd.DataFrame,
    top_n: int = 5,
    decay: float = DEFAULT_DECAY,
    as_of=None,
    exclude_previously_bought: bool = False
) -> pd.DataFrame:
    """
    EXACT implementation from notebook cell 2.

    Args:
        customer_id: Customer identifier
        df: Purchase DataFrame with columns [CustomerID/customer_id, Product/crop_name,
            Quantity/quantity, OrderDate/created_at, OrderID/order_id]
        top_n: Number of items to return
        decay: Exponential decay rate (λ). Default 0.03 → scores halve in ~23 days.
        as_of: Reference timestamp. Defaults to max date + 1 day.
        exclude_previously_bought: If True, strips all previously purchased products
            (creates a pure discovery feed).

    Returns:
        DataFrame with [Product, RecencyScore, LastPurchased] sorted by RecencyScore DESC.
    """
    # Normalise column names to match notebook expectations
    col_map = {}
    if "customer_id" in df.columns:
        col_map["customer_id"] = "CustomerID"
    if "crop_name" in df.columns:
        col_map["crop_name"] = "Product"
    if "quantity" in df.columns:
        col_map["quantity"] = "Quantity"
    if "created_at" in df.columns:
        col_map["created_at"] = "OrderDate"
    if "order_id" in df.columns:
        col_map["order_id"] = "OrderID"

    df_nb = df.rename(columns=col_map) if col_map else df.copy()

    # Convert OrderDate
    if "OrderDate" in df_nb.columns:
        df_nb["OrderDate"] = pd.to_datetime(df_nb["OrderDate"], utc=True, errors="coerce")
        df_nb["OrderDate"] = df_nb["OrderDate"].dt.tz_localize(None) if df_nb["OrderDate"].dt.tz is not None else df_nb["OrderDate"]

    history = df_nb[df_nb["CustomerID"].astype(str) == str(customer_id)].copy()

    if history.empty:
        return pd.DataFrame(columns=["Product", "RecencyScore", "LastPurchased"])

    if as_of is None:
        as_of = df_nb["OrderDate"].max() + pd.Timedelta(days=1)
    as_of = pd.Timestamp(as_of)

    history["AgeDays"] = (as_of - history["OrderDate"]).dt.total_seconds() / 86400
    qty_col = "Quantity" if "Quantity" in history.columns else None
    if qty_col:
        history["Quantity"] = pd.to_numeric(history[qty_col], errors="coerce").fillna(1.0)
    else:
        history["Quantity"] = 1.0

    history["WeightedScore"] = history["Quantity"].clip(lower=0) * np.exp(
        -decay * history["AgeDays"].clip(lower=0)
    )

    scored = history.groupby("Product").agg(
        RecencyScore=("WeightedScore", "sum"),
        LastPurchased=("OrderDate", "max")
    ).reset_index()

    if exclude_previously_bought:
        scored = scored.iloc[0:0]

    return scored.sort_values(
        ["RecencyScore", "LastPurchased"], ascending=False
    ).head(top_n)


def recency_weighted_recommendations(
    purchase_data: pd.DataFrame,
    catalog: pd.DataFrame,
    customer_id,
    top_n: int = 6,
    decay: float = DEFAULT_DECAY
) -> pd.DataFrame:
    """
    Main API function: Recency-weighted recommendations with catalog enrichment.
    Wraps recency_recommendations() with catalog metadata and cold-start handling.

    Cold-start: customer not in purchase_data → returns freshest catalog items.

    Args:
        purchase_data: Full purchase history DataFrame
        catalog: Active listings catalog DataFrame
        customer_id: Target customer
        top_n: Number of recommendations
        decay: Exponential decay λ (default 0.03 from notebook)

    Returns:
        DataFrame with recommendation rows including listing metadata.
    """
    c_str = str(customer_id)
    crop_col = "crop_name" if "crop_name" in catalog.columns else "Product"

    # Check if customer has any history
    id_col = "customer_id" if "customer_id" in purchase_data.columns else "CustomerID"
    has_history = (
        not purchase_data.empty
        and id_col in purchase_data.columns
        and not purchase_data[purchase_data[id_col].astype(str) == c_str].empty
    )

    if not has_history or purchase_data.empty:
        # Cold-start: return freshest catalog items
        return _catalog_freshness_fallback(catalog, top_n, c_str, crop_col)

    # Get recency-scored items (exact notebook algorithm)
    scored = recency_recommendations(c_str, purchase_data, top_n=top_n, decay=decay)

    if scored.empty:
        return _catalog_freshness_fallback(catalog, top_n, c_str, crop_col)

    results = []
    for rank, (_, row) in enumerate(scored.iterrows()):
        crop = str(row["Product"])
        recency_score = float(row["RecencyScore"])
        last_purchased = row.get("LastPurchased")

        cat_row = catalog[catalog[crop_col].astype(str) == crop].head(1) if not catalog.empty else pd.DataFrame()
        listing_id = str(cat_row.iloc[0].get("listing_id", f"rw-{rank}")) if not cat_row.empty else f"rw-{rank}"
        crop_id = str(cat_row.iloc[0].get("crop_id", f"crop-{rank}")) if not cat_row.empty else f"crop-{rank}"
        price = float(cat_row.iloc[0].get("price_per_unit", 35.0)) if not cat_row.empty else 35.0
        rating = float(cat_row.iloc[0].get("rating_avg", 4.8)) if not cat_row.empty else 4.8
        grade = str(cat_row.iloc[0].get("grade", "A")) if not cat_row.empty else "A"
        is_organic = bool(cat_row.iloc[0].get("is_organic", False)) if not cat_row.empty else False

        # Human-readable time label
        if last_purchased is not None and not pd.isnull(last_purchased):
            days_ago = (pd.Timestamp.now() - pd.Timestamp(last_purchased)).days
            if days_ago <= 7:
                time_label = f"{days_ago} day(s) ago"
            elif days_ago <= 30:
                time_label = f"{days_ago // 7} week(s) ago"
            else:
                time_label = f"{days_ago // 30} month(s) ago"
        else:
            time_label = "recently"

        # Normalize score to 0-1 range
        max_score = float(scored["RecencyScore"].max()) if len(scored) > 0 else 1.0
        norm_score = round(recency_score / max(max_score, 1e-6), 4)

        results.append({
            "customer_id": c_str,
            "listing_id": listing_id,
            "crop_id": crop_id,
            "crop_name": crop,
            "price_per_unit": price,
            "rating_avg": rating,
            "grade": grade,
            "is_organic": is_organic,
            "score": norm_score,
            "recency_raw_score": round(recency_score, 4),
            "recommendation_type": "RECENCY_WEIGHTED",
            "reason": f"⏱️ You ordered this {time_label} — still available fresh from Mandya-Bengaluru farms. Score: {norm_score:.0%}",
            "badge": f"#{rank+1} Recent Pick"
        })

    return pd.DataFrame(results) if results else pd.DataFrame()


def _catalog_freshness_fallback(catalog: pd.DataFrame, top_n: int, customer_id: str, crop_col: str) -> pd.DataFrame:
    """Cold-start fallback: return freshest/best-rated catalog items."""
    if catalog.empty:
        return pd.DataFrame()

    cat = catalog.copy()
    ref = pd.Timestamp.now(tz="UTC")

    if "harvest_date" in cat.columns:
        cat["harvest_date"] = pd.to_datetime(cat["harvest_date"], utc=True, errors="coerce")
        cat["age_days"] = (ref - cat["harvest_date"]).dt.days.clip(lower=0).fillna(14)
    else:
        cat["age_days"] = 14

    cat["freshness_score"] = np.exp(-DEFAULT_DECAY * cat["age_days"])
    if "rating_avg" in cat.columns:
        max_r = cat["rating_avg"].max()
        cat["rating_norm"] = (cat["rating_avg"] / max_r).clip(0, 1) if max_r > 0 else 1.0
    else:
        cat["rating_norm"] = 1.0

    cat["final_score"] = 0.6 * cat["freshness_score"] + 0.4 * cat["rating_norm"]
    cat = cat.sort_values("final_score", ascending=False).head(top_n)

    results = []
    for rank, (_, row) in enumerate(cat.iterrows()):
        results.append({
            "customer_id": customer_id,
            "listing_id": str(row.get("listing_id", f"rw-cold-{rank}")),
            "crop_id": str(row.get("crop_id", f"crop-{rank}")),
            "crop_name": str(row.get(crop_col, "Fresh Produce")),
            "price_per_unit": float(row.get("price_per_unit", 35.0)),
            "rating_avg": float(row.get("rating_avg", 4.8)),
            "grade": str(row.get("grade", "A")),
            "is_organic": bool(row.get("is_organic", False)),
            "score": round(float(row.get("final_score", 0.85)), 4),
            "recency_raw_score": 0.0,
            "recommendation_type": "RECENCY_WEIGHTED_COLD_START",
            "reason": f"🌿 Freshly harvested from Mandya farms — top-rated pick for new members.",
            "badge": f"#{rank+1} Fresh Pick"
        })

    return pd.DataFrame(results) if results else pd.DataFrame()
