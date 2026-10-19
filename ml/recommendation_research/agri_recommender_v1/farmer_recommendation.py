import numpy as np
import pandas as pd

def recommend_crops_for_farmer(farmer_id, purchase_data, inventory, farmers, pricing_log, top_n=10):
    """Demand-opportunity ranking for a farmer. This is a transparent baseline, not a trained demand-forecasting model."""
    demand=(purchase_data.groupby("crop_id").agg(order_count=("order_id","nunique"),quantity_demand=("quantity","sum")).reset_index())
    supply=(inventory[inventory["status"].astype(str).str.upper().eq("AVAILABLE")].groupby("crop_id").agg(available_supply=("quantity","sum")).reset_index())
    x=demand.merge(supply,on="crop_id",how="left").fillna({"available_supply":0})
    x["supply_gap"]=(x["quantity_demand"]-x["available_supply"]).clip(lower=0)
    price=pricing_log.sort_values("prediction_date").groupby("crop_id").tail(1)[["crop_id","predicted_price","confidence_score"]]
    x=x.merge(price,on="crop_id",how="left")
    x=x.merge(farmers[["farmer_id","farm_size_acres","primary_crops"]],how="cross")
    x=x[x["farmer_id"]==farmer_id].copy()
    primary=x["primary_crops"].fillna("").str.split(",").apply(lambda a:{s.strip() for s in a})
    crop_name=purchase_data[["crop_id","crop_name"]].drop_duplicates("crop_id")
    x=x.merge(crop_name,on="crop_id",how="left")
    x["farmer_fit"]=primary.apply(lambda s: 1.0 if len(s)==0 else 0.7)
    x["demand_score"]=x["quantity_demand"]/(x["quantity_demand"].max() or 1)
    x["gap_score"]=x["supply_gap"]/(x["supply_gap"].max() or 1)
    x["price_score"]=x["predicted_price"].fillna(0)/(x["predicted_price"].fillna(0).max() or 1)
    x["opportunity_score"]=0.45*x["gap_score"]+0.30*x["demand_score"]+0.20*x["price_score"]+0.05*x["farmer_fit"]
    x["recommendation_type"]="FARMER_CROP_OPPORTUNITY"
    x["reason"]="Ranked using demand, current supply gap and predicted price."
    return x.sort_values("opportunity_score",ascending=False).head(top_n).reset_index(drop=True)
