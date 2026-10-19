from pathlib import Path
import pandas as pd

from .config import DATA_DIR


def load_csv(name: str, data_dir: Path = DATA_DIR) -> pd.DataFrame:
    path = Path(data_dir) / name
    if not path.exists():
        raise FileNotFoundError(f"Dataset not found: {path}")
    return pd.read_csv(path)


def load_customer_tables(data_dir: Path = DATA_DIR):
    return {
        "orders": load_csv("customer_order_rows.csv", data_dir),
        "order_items": load_csv("order_item_rows.csv", data_dir),
        "seller_listings": load_csv("seller_listing_rows.csv", data_dir),
        "inventory": load_csv("inventory_item_rows.csv", data_dir),
        "crops": load_csv("crop_rows.csv", data_dir),
        "interactions": load_csv("user_interaction_rows.csv", data_dir),
        "reviews": load_csv("customer_review_rows.csv", data_dir),
        "customers": load_csv("customer_profile_rows.csv", data_dir),
    }


def build_purchase_data(data_dir: Path = DATA_DIR) -> pd.DataFrame:
    t = load_customer_tables(data_dir)
    orders = t["orders"].copy()
    order_items = t["order_items"].copy()
    listings = t["seller_listings"].copy()
    inventory = t["inventory"].copy()
    crops = t["crops"].copy()

    keep_status = orders["order_status"].astype(str).str.upper().eq("DELIVERED")
    orders = orders.loc[keep_status].copy()

    purchase = (
        order_items
        .merge(orders[["order_id", "customer_id", "order_status", "created_at"]], on="order_id", how="inner")
        .merge(listings[["listing_id", "inventory_id", "rating_avg", "rating_count", "is_organic"]], on="listing_id", how="inner")
        .merge(inventory[["inventory_id", "farmer_id", "crop_id", "quantity", "price_per_unit", "grade", "harvest_date", "status"]], on="inventory_id", how="inner")
        .merge(crops[["crop_id", "crop_name", "category_id", "is_perishable"]], on="crop_id", how="inner")
    )
    purchase["created_at"] = pd.to_datetime(purchase["created_at"], errors="coerce", utc=True)
    purchase["harvest_date"] = pd.to_datetime(purchase["harvest_date"], errors="coerce", utc=True)
    return purchase


def build_listing_catalog(data_dir: Path = DATA_DIR) -> pd.DataFrame:
    t = load_customer_tables(data_dir)
    listings = t["seller_listings"].copy()
    inventory = t["inventory"].copy()
    crops = t["crops"].copy()
    catalog = (
        listings
        .merge(inventory, on="inventory_id", how="inner", suffixes=("_listing", "_inventory"))
        .merge(crops[["crop_id", "crop_name", "category_id", "is_perishable"]], on="crop_id", how="inner")
    )
    catalog["harvest_date"] = pd.to_datetime(catalog["harvest_date"], errors="coerce", utc=True)
    return catalog


def build_interactions(data_dir: Path = DATA_DIR) -> pd.DataFrame:
    t = load_customer_tables(data_dir)
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
