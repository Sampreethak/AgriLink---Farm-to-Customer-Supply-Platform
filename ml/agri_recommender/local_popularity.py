"""
Local Popularity Recommendation Module
AgriLink Customer Recommendation Engine — Module 7

EXACT implementation from notebook 04_local_popularity_recommendation.ipynb.

Algorithm:
  1. Identify customer's location: mode of their past orders' Location field.
  2. Filter all orders to that location zone.
  3. Score each product by:
     - LocalOrderCount = nunique(OrderID)          [primary sort key]
     - LocalCustomerCount = nunique(CustomerID)    [secondary sort key]
     - TotalQuantity = sum(Quantity)               [tertiary sort key]
  4. Return top_n, sorted descending.

Cold-start: customer with no purchase history → global popularity baseline
  (same algorithm but without location filter).

Location field: The notebook uses North/South/East/West zones.
AgriLink production uses Bengaluru / Mandya / Mysuru / Tumkur / Hassan zones.
The _normalise_location() function maps both formats.

No pkl file needed: purely an aggregation-based ranking model.
"""
import pandas as pd
import numpy as np


# AgriLink zone mapping
ZONE_MAP = {
    "north": "Bengaluru",
    "bengaluru": "Bengaluru",
    "bangalore": "Bengaluru",
    "north bengaluru": "Bengaluru",
    "electronic city": "Bengaluru",
    "hebbal": "Bengaluru",
    "vidyaranyapura": "Bengaluru",
    "devanahalli": "Bengaluru",
    "bengaluru urban": "Bengaluru",
    "south": "Mandya",
    "mandya": "Mandya",
    "maddur": "Mandya",
    "srirangapatna": "Mandya",
    "east": "Mysuru",
    "mysuru": "Mysuru",
    "mysore": "Mysuru",
    "west": "Tumkur",
    "tumkur": "Tumkur",
    "tumkuru": "Tumkur",
    "hassan": "Hassan",
    "karnataka": "Bengaluru",  # Default to Bengaluru for state-level entries
}


def _normalise_location(location_str: str) -> str:
    """Map a raw location string to an AgriLink zone name."""
    if not location_str or str(location_str).strip().lower() in ("nan", "none", ""):
        return "Bengaluru"
    loc = str(location_str).strip().lower()
    for key, zone in ZONE_MAP.items():
        if key in loc:
            return zone
    return location_str.strip().title()  # Unknown zone — keep as-is


def local_popularity_recommendations_core(
    customer_id,
    df: pd.DataFrame,
    top_n: int = 10,
    exclude_purchased: bool = False
) -> pd.DataFrame:
    """
    EXACT implementation from notebook cell 2 (adapted for AgriLink column names).

    Uses Location mode (most frequent zone from customer's order history) to
    identify the customer's locality, then ranks products by local order frequency.

    Args:
        customer_id: Customer identifier
        df: Purchase history with [CustomerID/customer_id, OrderID/order_id,
            Product/crop_name, Quantity/quantity, Location/district/city]
        top_n: Number of items to return
        exclude_purchased: If True, exclude products the customer has already bought

    Returns:
        DataFrame with [Location, Product, LocalOrderCount, LocalCustomerCount, TotalQuantity]
        Or empty DataFrame if customer not found.
    """
    # Normalise column names
    id_col = "CustomerID" if "CustomerID" in df.columns else "customer_id"
    oid_col = "OrderID" if "OrderID" in df.columns else "order_id"
    prod_col = "Product" if "Product" in df.columns else "crop_name"
    qty_col = "Quantity" if "Quantity" in df.columns else "quantity"

    # Location column detection
    loc_col = None
    for lc in ["Location", "location", "district", "city", "region", "delivery_address"]:
        if lc in df.columns:
            loc_col = lc
            break

    c_str = str(customer_id)
    customer_rows = df[df[id_col].astype(str) == c_str]

    if customer_rows.empty:
        return pd.DataFrame(columns=["Product", "LocalOrderCount", "LocalCustomerCount"])

    # Get customer location (mode of their orders' location, then normalize)
    if loc_col and loc_col in customer_rows.columns:
        raw_location = customer_rows[loc_col].astype(str).mode().iloc[0]
        location = _normalise_location(raw_location)
    else:
        location = "Bengaluru"  # Default zone

    # Filter to local zone
    if loc_col:
        normalised_locs = df[loc_col].astype(str).apply(_normalise_location)
        local_df = df[normalised_locs == location]
        if local_df.empty:
            local_df = df  # Fallback to all orders if zone has no data
    else:
        local_df = df

    # Aggregate: exactly as in notebook
    scored = local_df.groupby(prod_col).agg(
        LocalOrderCount=(oid_col, "nunique"),
        LocalCustomerCount=(id_col, "nunique"),
        TotalQuantity=(qty_col, "sum")
    ).reset_index()

    if exclude_purchased:
        bought = set(customer_rows[prod_col].astype(str))
        scored = scored[~scored[prod_col].astype(str).isin(bought)]

    scored = scored.sort_values(
        ["LocalOrderCount", "LocalCustomerCount", "TotalQuantity"],
        ascending=False
    ).head(top_n).reset_index(drop=True)

    scored.insert(0, "Location", location)
    scored = scored.rename(columns={prod_col: "Product"})
    return scored


def global_popularity(df: pd.DataFrame, top_n: int = 10) -> pd.DataFrame:
    """
    EXACT implementation from notebook cell 3.
    Global popularity baseline — no location filter.
    Used for cold-start customers with no location/history data.
    """
    id_col = "CustomerID" if "CustomerID" in df.columns else "customer_id"
    oid_col = "OrderID" if "OrderID" in df.columns else "order_id"
    prod_col = "Product" if "Product" in df.columns else "crop_name"

    return (
        df.groupby(prod_col)
        .agg(
            GlobalOrderCount=(oid_col, "nunique"),
            GlobalCustomerCount=(id_col, "nunique")
        )
        .sort_values(["GlobalOrderCount", "GlobalCustomerCount"], ascending=False)
        .head(top_n)
        .reset_index()
        .rename(columns={prod_col: "Product"})
    )


def local_popularity_recommendations(
    purchase_data: pd.DataFrame,
    catalog: pd.DataFrame,
    customer_id,
    tables: dict = None,
    top_n: int = 6,
    region_override: str = None
) -> pd.DataFrame:
    """
    API wrapper: local_popularity_recommendations_core() + catalog enrichment.
    Supports cold-start via global_popularity() fallback.

    Args:
        purchase_data: Full purchase history DataFrame
        catalog: Active listings catalog DataFrame
        customer_id: Target customer
        tables: Optional dict of loaded tables (for location lookup without purchase history)
        top_n: Number of recommendations
        region_override: Force a zone (e.g. "Mandya")

    Returns:
        DataFrame with recommendation rows including listing metadata.
    """
    c_str = str(customer_id)
    crop_col = "crop_name" if "crop_name" in catalog.columns else "Product"

    # Inject region_override into purchase_data if provided
    if region_override and not purchase_data.empty:
        pd_work = purchase_data.copy()
        id_col = "customer_id" if "customer_id" in pd_work.columns else "CustomerID"
        if id_col in pd_work.columns:
            pd_work.loc[pd_work[id_col].astype(str) == c_str, "Location"] = region_override
    else:
        pd_work = purchase_data

    is_cold_start = (
        purchase_data.empty
        or ("customer_id" not in purchase_data.columns and "CustomerID" not in purchase_data.columns)
    )
    if not is_cold_start:
        id_col = "customer_id" if "customer_id" in purchase_data.columns else "CustomerID"
        is_cold_start = purchase_data[purchase_data[id_col].astype(str) == c_str].empty

    if is_cold_start or purchase_data.empty:
        # Cold-start: use global popularity baseline
        if purchase_data.empty:
            return _catalog_fallback(catalog, top_n, c_str, crop_col)
        scored = global_popularity(purchase_data, top_n=top_n)
        location = region_override or "AgriLink"
        is_local = False
    else:
        # Run exact notebook algorithm
        scored = local_popularity_recommendations_core(c_str, pd_work, top_n=top_n)
        location = scored["Location"].iloc[0] if not scored.empty and "Location" in scored.columns else "Bengaluru"
        is_local = True

    if scored.empty:
        return _catalog_fallback(catalog, top_n, c_str, crop_col)

    results = []
    prod_col_scored = "Product"
    count_col = "LocalOrderCount" if "LocalOrderCount" in scored.columns else "GlobalOrderCount"
    cust_col = "LocalCustomerCount" if "LocalCustomerCount" in scored.columns else "GlobalCustomerCount"

    for rank, (_, row) in enumerate(scored.iterrows()):
        crop = str(row[prod_col_scored])
        order_count = int(row.get(count_col, 0))
        cust_count = int(row.get(cust_col, 0))
        total_qty = int(row.get("TotalQuantity", 0))

        cat_match = catalog[catalog[crop_col].astype(str) == crop].head(1) if not catalog.empty else pd.DataFrame()
        listing_id = str(cat_match.iloc[0].get("listing_id", f"lp-{rank}")) if not cat_match.empty else f"lp-{rank}"
        crop_id = str(cat_match.iloc[0].get("crop_id", f"crop-{rank}")) if not cat_match.empty else f"crop-{rank}"
        price = float(cat_match.iloc[0].get("price_per_unit", 35.0)) if not cat_match.empty else 35.0
        rating = float(cat_match.iloc[0].get("rating_avg", 4.8)) if not cat_match.empty else 4.8
        grade = str(cat_match.iloc[0].get("grade", "A")) if not cat_match.empty else "A"
        is_organic = bool(cat_match.iloc[0].get("is_organic", False)) if not cat_match.empty else False

        # Normalize score to 0-1 based on rank
        max_orders = int(scored[count_col].max()) if len(scored) > 0 else 1
        norm_score = round(order_count / max(max_orders, 1), 4)

        if is_local and order_count > 0:
            reason = f"📍 Trending in {location} — ordered in {order_count} orders by {cust_count} local buyers. Total: {total_qty} kg sold."
            rec_type = "LOCAL_POPULARITY"
        elif order_count > 0:
            reason = f"🔥 Platform-wide favourite — ordered in {order_count} orders across all regions."
            rec_type = "LOCAL_POPULARITY_GLOBAL"
        else:
            reason = f"⭐ Top-rated from the {location} corridor — fresh and available from local farms."
            rec_type = "LOCAL_POPULARITY_COLD_START"

        results.append({
            "customer_id": c_str,
            "listing_id": listing_id,
            "crop_id": crop_id,
            "crop_name": crop,
            "price_per_unit": price,
            "rating_avg": rating,
            "grade": grade,
            "is_organic": is_organic,
            "location": location,
            "local_order_count": order_count,
            "local_customer_count": cust_count,
            "score": norm_score,
            "recommendation_type": rec_type,
            "reason": reason,
            "badge": f"#{rank+1} Local Trend"
        })

    return pd.DataFrame(results) if results else pd.DataFrame()


def _catalog_fallback(catalog: pd.DataFrame, top_n: int, customer_id: str, crop_col: str) -> pd.DataFrame:
    """Fallback when no purchase data available: return top-rated catalog items."""
    if catalog.empty:
        return pd.DataFrame()
    cat = catalog.copy()
    if "rating_avg" in cat.columns:
        cat = cat.sort_values("rating_avg", ascending=False)
    sample = cat.head(top_n)
    results = []
    for rank, (_, row) in enumerate(sample.iterrows()):
        results.append({
            "customer_id": customer_id,
            "listing_id": str(row.get("listing_id", f"lp-cold-{rank}")),
            "crop_id": str(row.get("crop_id", f"crop-{rank}")),
            "crop_name": str(row.get(crop_col, "Fresh Produce")),
            "price_per_unit": float(row.get("price_per_unit", 35.0)),
            "rating_avg": float(row.get("rating_avg", 4.8)),
            "grade": str(row.get("grade", "A")),
            "is_organic": bool(row.get("is_organic", False)),
            "location": "AgriLink",
            "local_order_count": 0,
            "local_customer_count": 0,
            "score": round(1.0 - rank * 0.05, 4),
            "recommendation_type": "LOCAL_POPULARITY_COLD_START",
            "reason": "⭐ Highly rated farm produce — top pick for new AgriLink members.",
            "badge": f"#{rank+1} Popular"
        })
    return pd.DataFrame(results)
