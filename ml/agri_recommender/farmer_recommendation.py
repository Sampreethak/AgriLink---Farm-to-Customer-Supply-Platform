import numpy as np
import pandas as pd


def recommend_crops_for_farmer(farmer_id, purchase_data, inventory, farmers, pricing_log, top_n=10):
    """
    Demand-opportunity ranking for a farmer based on purchase demand, active supply gap, and predicted APMC market prices.
    """
    f_str = str(farmer_id)

    # 1. Calculate demand per crop
    demand = purchase_data.groupby("crop_id").agg(
        order_count=("order_id", "nunique"),
        quantity_demand=("quantity", "sum")
    ).reset_index()

    # 2. Calculate available supply
    if "status" in inventory.columns:
        avail_inv = inventory[inventory["status"].astype(str).str.upper().isin(["AVAILABLE", "ACTIVE"])].copy()
    else:
        avail_inv = inventory.copy()

    supply = avail_inv.groupby("crop_id").agg(available_supply=("quantity", "sum")).reset_index()

    x = demand.merge(supply, on="crop_id", how="left").fillna({"available_supply": 0})
    x["supply_gap"] = (x["quantity_demand"] - x["available_supply"]).clip(lower=0)

    # 3. Get latest predicted price from pricing log if present
    if not pricing_log.empty and "prediction_date" in pricing_log.columns:
        price = pricing_log.sort_values("prediction_date").groupby("crop_id").tail(1)[["crop_id", "predicted_price", "confidence_score"]]
        x = x.merge(price, on="crop_id", how="left")
    else:
        x["predicted_price"] = 40.0
        x["confidence_score"] = 0.85

    x["farmer_id"] = f_str

    # 4. Merge farmer profile if available
    farmer_prof = farmers[farmers["farmer_id"].astype(str) == f_str] if "farmer_id" in farmers.columns else pd.DataFrame()
    if not farmer_prof.empty and "primary_crops" in farmer_prof.columns:
        p_crops = str(farmer_prof.iloc[0].get("primary_crops", ""))
        primary_set = {s.strip().lower() for s in p_crops.split(",") if s.strip()}
    else:
        primary_set = set()

    crop_names = purchase_data[["crop_id", "crop_name"]].drop_duplicates("crop_id")
    x = x.merge(crop_names, on="crop_id", how="left")

    x["farmer_fit"] = x["crop_name"].astype(str).str.lower().apply(
        lambda c: 1.0 if (not primary_set or c in primary_set) else 0.7
    )

    max_demand = x["quantity_demand"].max() or 1.0
    max_gap = x["supply_gap"].max() or 1.0
    max_price = x["predicted_price"].fillna(0).max() or 1.0

    x["demand_score"] = x["quantity_demand"] / max_demand
    x["gap_score"] = x["supply_gap"] / max_gap
    x["price_score"] = x["predicted_price"].fillna(0) / max_price

    x["opportunity_score"] = (
        0.45 * x["gap_score"] +
        0.30 * x["demand_score"] +
        0.20 * x["price_score"] +
        0.05 * x["farmer_fit"]
    )
    x["recommendation_type"] = "FARMER_CROP_OPPORTUNITY"
    x["reason"] = x.apply(
        lambda r: f"High demand gap ({r['supply_gap']:.0f} kg unmet demand) • Predicted APMC price: ₹{r['predicted_price']:.2f}/kg.",
        axis=1
    )
    return x.sort_values("opportunity_score", ascending=False).head(top_n).reset_index(drop=True)
