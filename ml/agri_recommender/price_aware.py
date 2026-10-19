"""
Price-Aware Recommendation Module
AgriLink Customer Recommendation Engine — Module 6

EXACT implementation from notebook 03_price_aware_recommendation.ipynb.

Algorithm:
  1. Estimate customer's preferred_price = weighted_median(UnitPrice, Quantity)
     - weighted_median: price at which cumulative weight crosses 50%
  2. PriceFitScore = exp(-|CurrentPrice - preferred_price| / max(|preferred_price|, 1.0))
  3. PopularityScore = (OrderCount per product) / max(OrderCount)
  4. HybridPriceScore = (price_weight * PriceFitScore + popularity_weight * PopularityScore)
                        / (price_weight + popularity_weight)

Default weights: price_weight=0.5, popularity_weight=0.5

Cold-start: preferred_price = global median price across all orders.
No pkl file needed: purely a scoring function.
"""
import pandas as pd
import numpy as np


DEFAULT_PRICE_WEIGHT = 0.5
DEFAULT_POPULARITY_WEIGHT = 0.5


def weighted_median(values, weights) -> float:
    """
    EXACT implementation from notebook cell 2.
    Returns the weighted median of values.
    If no valid values, returns np.nan.
    """
    values = np.asarray(values, dtype=float)
    weights = np.asarray(weights, dtype=float)
    mask = np.isfinite(values) & np.isfinite(weights) & (weights > 0)
    values, weights = values[mask], weights[mask]
    if len(values) == 0:
        return np.nan
    order = np.argsort(values)
    values, weights = values[order], weights[order]
    return float(values[np.searchsorted(np.cumsum(weights), weights.sum() / 2)])


def price_aware_recommendations(
    customer_id,
    orders: pd.DataFrame,
    catalog: pd.DataFrame,
    top_n: int = 10,
    price_weight: float = DEFAULT_PRICE_WEIGHT,
    popularity_weight: float = DEFAULT_POPULARITY_WEIGHT,
    exclude_purchased: bool = False
) -> pd.DataFrame:
    """
    EXACT implementation from notebook cell 2.

    Args:
        customer_id: Customer identifier (matches CustomerID or customer_id column)
        orders: Purchase history DataFrame
        catalog: Product catalog DataFrame
        top_n: Number of recommendations
        price_weight: Weight for price-fit score (default 0.5)
        popularity_weight: Weight for popularity score (default 0.5)
        exclude_purchased: If True, excludes already-purchased products

    Returns:
        DataFrame sorted by HybridPriceScore DESC with catalog metadata.
    """
    # Normalise column names
    id_col = "CustomerID" if "CustomerID" in orders.columns else "customer_id"
    price_col_o = "UnitPrice" if "UnitPrice" in orders.columns else "price_per_unit"
    qty_col = "Quantity" if "Quantity" in orders.columns else "quantity"
    prod_col_o = "Product" if "Product" in orders.columns else "crop_name"
    oid_col = "OrderID" if "OrderID" in orders.columns else "order_id"
    price_col_c = "CurrentPrice" if "CurrentPrice" in catalog.columns else "price_per_unit"
    prod_col_c = "Product" if "Product" in catalog.columns else "crop_name"

    hist = orders[orders[id_col].astype(str) == str(customer_id)].copy()

    if hist.empty:
        # Cold-start: use global median price
        if not orders.empty and price_col_o in orders.columns:
            preferred_price = float(pd.to_numeric(orders[price_col_o], errors="coerce").median())
        elif not catalog.empty and price_col_c in catalog.columns:
            preferred_price = float(pd.to_numeric(catalog[price_col_c], errors="coerce").median())
        else:
            preferred_price = 45.0
    else:
        hist[price_col_o] = pd.to_numeric(hist[price_col_o], errors="coerce")
        hist[qty_col] = pd.to_numeric(hist[qty_col], errors="coerce").fillna(1.0)
        preferred_price = weighted_median(hist[price_col_o], hist[qty_col])
        if not np.isfinite(preferred_price):
            preferred_price = float(pd.to_numeric(catalog[price_col_c], errors="coerce").median()) if not catalog.empty else 45.0

    # Compute global popularity: unique order count per product
    if not orders.empty and oid_col in orders.columns and prod_col_o in orders.columns:
        popularity = orders.groupby(prod_col_o)[oid_col].nunique()
    else:
        popularity = pd.Series(dtype=float)

    result = catalog.copy()
    result[price_col_c] = pd.to_numeric(result[price_col_c], errors="coerce")
    result = result.dropna(subset=[prod_col_c, price_col_c])

    if "Available" in result.columns:
        result = result[result["Available"].astype(bool)]

    result["Popularity"] = result[prod_col_c].map(popularity).fillna(0).astype(float)
    max_pop = result["Popularity"].max()
    result["PopularityScore"] = result["Popularity"] / max_pop if max_pop > 0 else 0.0

    # Price fit: exp(-|price - preferred| / max(|preferred|, 1.0))
    denom = max(abs(float(preferred_price)), 1.0)
    result["PriceFitScore"] = np.exp(
        -np.abs(result[price_col_c] - preferred_price) / denom
    )

    total_weight = max(price_weight + popularity_weight, 1e-12)
    result["HybridPriceScore"] = (
        price_weight * result["PriceFitScore"] +
        popularity_weight * result["PopularityScore"]
    ) / total_weight

    if exclude_purchased and not hist.empty:
        bought = set(hist[prod_col_o].dropna().astype(str))
        result = result[~result[prod_col_c].astype(str).isin(bought)]

    result["EstimatedPreferredUnitPrice"] = preferred_price
    return result.sort_values("HybridPriceScore", ascending=False).head(top_n).reset_index(drop=True)


def price_aware_recommendations_api(
    purchase_data: pd.DataFrame,
    catalog: pd.DataFrame,
    customer_id,
    top_n: int = 6
) -> pd.DataFrame:
    """
    API wrapper: Calls price_aware_recommendations() and enriches the output
    with listing metadata fields needed by the FastAPI response format.

    Cold-start: customer with no purchase history uses global median price.

    Args:
        purchase_data: Full purchase history (all customers)
        catalog: Active listings catalog
        customer_id: Target customer
        top_n: Number of recommendations

    Returns:
        DataFrame with full recommendation rows including reason and badge.
    """
    c_str = str(customer_id)
    crop_col = "crop_name" if "crop_name" in catalog.columns else "Product"
    id_col = "customer_id" if "customer_id" in purchase_data.columns else "CustomerID"

    is_cold_start = (
        purchase_data.empty
        or id_col not in purchase_data.columns
        or purchase_data[purchase_data[id_col].astype(str) == c_str].empty
    )

    if catalog.empty:
        return pd.DataFrame()

    # Run notebook algorithm
    recs = price_aware_recommendations(c_str, purchase_data, catalog, top_n=top_n)

    if recs.empty:
        return pd.DataFrame()

    results = []
    price_col_c = "CurrentPrice" if "CurrentPrice" in recs.columns else "price_per_unit"
    prod_col = "Product" if "Product" in recs.columns else "crop_name"

    for rank, (_, row) in enumerate(recs.iterrows()):
        crop = str(row.get(prod_col, "Fresh Produce"))
        price = float(row.get(price_col_c, 35.0))
        pref = float(row.get("EstimatedPreferredUnitPrice", price))
        hybrid_score = float(row.get("HybridPriceScore", 0.5))
        price_fit = float(row.get("PriceFitScore", 0.8))
        pop_score = float(row.get("PopularityScore", 0.5))

        # Get catalog listing metadata
        cat_match = catalog[catalog[crop_col].astype(str) == crop].head(1) if not catalog.empty else pd.DataFrame()
        listing_id = str(cat_match.iloc[0].get("listing_id", f"pa-{rank}")) if not cat_match.empty else f"pa-{rank}"
        crop_id = str(cat_match.iloc[0].get("crop_id", f"crop-{rank}")) if not cat_match.empty else f"crop-{rank}"
        rating = float(cat_match.iloc[0].get("rating_avg", 4.8)) if not cat_match.empty else 4.8
        grade = str(cat_match.iloc[0].get("grade", "A")) if not cat_match.empty else "A"
        is_organic = bool(cat_match.iloc[0].get("is_organic", False)) if not cat_match.empty else False

        if is_cold_start:
            reason = f"💰 Platform-favourite at ₹{price:.0f}/kg — popular with AgriLink customers in your price range."
            rec_type = "PRICE_AWARE_COLD_START"
            badge = f"#{rank+1} Value Pick"
        else:
            fit_pct = int(price_fit * 100)
            reason = f"💰 {fit_pct}% price fit to your ₹{pref:.0f}/kg budget — popular with {int(row.get('Popularity', 0))} orders."
            rec_type = "PRICE_AWARE"
            badge = f"#{rank+1} Price Smart"

        results.append({
            "customer_id": c_str,
            "listing_id": listing_id,
            "crop_id": crop_id,
            "crop_name": crop,
            "price_per_unit": price,
            "rating_avg": rating,
            "grade": grade,
            "is_organic": is_organic,
            "score": round(hybrid_score, 4),
            "price_fit_score": round(price_fit, 4),
            "popularity_score": round(pop_score, 4),
            "estimated_preferred_price": round(pref, 2),
            "recommendation_type": rec_type,
            "reason": reason,
            "badge": badge
        })

    return pd.DataFrame(results) if results else pd.DataFrame()
