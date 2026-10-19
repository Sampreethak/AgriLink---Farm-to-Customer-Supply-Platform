from pathlib import Path
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

from .config import DATA_DIR_CSV, DATA_DIR_REC


def load_csv(name: str, primary_dir: Path = DATA_DIR_CSV, fallback_dir: Path = DATA_DIR_REC) -> pd.DataFrame:
    """Load a dataset table by trying primary (database/csv) and fallback (AgriLink_Recommendation_Code/data)."""
    possible_names = [name]
    if name.endswith(".csv"):
        base = name[:-4]
        possible_names.extend([f"{base}_rows.csv", base])
    else:
        possible_names.extend([f"{name}.csv", f"{name}_rows.csv"])

    dirs = [Path(primary_dir), Path(fallback_dir)]
    for d in dirs:
        for p_name in possible_names:
            path = d / p_name
            if path.exists():
                return pd.read_csv(path)

    raise FileNotFoundError(f"Dataset table '{name}' not found in {primary_dir} or {fallback_dir}")


def load_customer_tables():
    return {
        "orders": load_csv("customer_order.csv"),
        "order_items": load_csv("order_item.csv"),
        "seller_listings": load_csv("seller_listing.csv"),
        "inventory": load_csv("inventory_item.csv"),
        "crops": load_csv("crop.csv"),
        "interactions": load_csv("user_interaction.csv"),
        "reviews": load_csv("customer_review.csv"),
        "customers": load_csv("customer_profile.csv"),
        "farmers": load_csv("farmer_profile.csv"),
        "pricing_log": load_csv("ml_pricing_log.csv"),
    }


def build_purchase_data() -> pd.DataFrame:
    t = load_customer_tables()
    orders = t["orders"].copy()
    order_items = t["order_items"].copy()
    listings = t["seller_listings"].copy()
    inventory = t["inventory"].copy()
    crops = t["crops"].copy()

    # Ensure created_at exists in orders
    if "created_at" not in orders.columns:
        # Generate synthetic created_at spread over the last 60 days
        base_date = datetime.now() - timedelta(days=60)
        n = len(orders)
        orders["created_at"] = [base_date + timedelta(minutes=i * (60 * 24 * 60 // max(n, 1))) for i in range(n)]

    keep_status = orders["order_status"].astype(str).str.upper().isin(["DELIVERED", "COMPLETED", "PAID"])
    filtered_orders = orders.loc[keep_status].copy()
    if filtered_orders.empty:
        filtered_orders = orders.copy()

    purchase = (
        order_items
        .merge(filtered_orders[["order_id", "customer_id", "order_status", "created_at"]], on="order_id", how="inner")
        .merge(listings[["listing_id", "inventory_id", "rating_avg", "rating_count", "is_organic"]], on="listing_id", how="inner")
        .merge(inventory[["inventory_id", "farmer_id", "crop_id", "quantity", "price_per_unit", "grade", "harvest_date", "status"]], on="inventory_id", how="inner", suffixes=("_item", "_inventory"))
        .merge(crops[["crop_id", "crop_name", "category_id", "is_perishable"]], on="crop_id", how="inner")
    )

    # Standardize column name quantity
    if "quantity_item" in purchase.columns:
        purchase["quantity"] = purchase["quantity_item"]

    purchase["created_at"] = pd.to_datetime(purchase["created_at"], errors="coerce", utc=True)
    purchase["harvest_date"] = pd.to_datetime(purchase["harvest_date"], errors="coerce", utc=True)
    return purchase


def build_listing_catalog() -> pd.DataFrame:
    t = load_customer_tables()
    listings = t["seller_listings"].copy()
    inventory = t["inventory"].copy()
    crops = t["crops"].copy()

    catalog = (
        listings
        .merge(inventory, on="inventory_id", how="inner", suffixes=("_listing", "_inventory"))
        .merge(crops[["crop_id", "crop_name", "category_id", "is_perishable"]], on="crop_id", how="inner")
    )

    if "price_per_unit" not in catalog.columns and "price_per_unit_inventory" in catalog.columns:
        catalog["price_per_unit"] = catalog["price_per_unit_inventory"]

    catalog["harvest_date"] = pd.to_datetime(catalog["harvest_date"], errors="coerce", utc=True)
    return catalog


def build_interactions() -> pd.DataFrame:
    t = load_customer_tables()
    interactions = t["interactions"].copy()
    listings = t["seller_listings"][["listing_id", "inventory_id"]].copy()
    inventory = t["inventory"][["inventory_id", "crop_id"]].copy()
    crops = t["crops"][["crop_id", "crop_name"]].copy()

    x = (
        interactions
        .merge(listings, on="listing_id", how="left")
        .merge(inventory, on="inventory_id", how="left")
        .merge(crops, on="crop_id", how="left")
    )
    x["created_at"] = pd.to_datetime(x["created_at"], errors="coerce", utc=True)
    return x
