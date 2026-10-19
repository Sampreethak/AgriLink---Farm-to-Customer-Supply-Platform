import pandas as pd

from .buy_again import generate_buy_again
from .fp_growth import train_fp_growth, recommend_for_basket
from .collaborative_filtering import recommend_for_customer
from .ranking import rank_candidates


def build_customer_hybrid(customer_id, purchase_data, interactions, catalog, top_n=10):
    c_str = str(customer_id)
    buy_again = generate_buy_again(purchase_data, customer_id=c_str, top_n=top_n * 2)

    fp_freq, fp_rules, _ = train_fp_growth(purchase_data)
    customer_purchases = purchase_data[purchase_data["customer_id"].astype(str) == c_str]
    basket = list(customer_purchases["crop_name"].dropna().unique())
    assoc = recommend_for_basket(basket, fp_rules, top_n=top_n * 2)

    if not assoc.empty and "crop_name" in assoc.columns:
        cat_subset = catalog[["crop_name", "listing_id", "crop_id"]].drop_duplicates("crop_name")
        assoc = assoc.merge(cat_subset, on="crop_name", how="left")
        assoc["customer_id"] = customer_id

    cf = recommend_for_customer(c_str, interactions, catalog, top_n=top_n * 2)

    candidates = pd.concat([buy_again, assoc, cf], ignore_index=True, sort=False)
    if not candidates.empty:
        candidates = candidates.dropna(subset=["listing_id", "crop_id", "crop_name"])
        candidates = candidates.drop_duplicates(["customer_id", "listing_id", "recommendation_type"], keep="first")
        ranked = rank_candidates(candidates, catalog)
        ranked = ranked.drop_duplicates(["customer_id", "listing_id"], keep="first")
        result = ranked.head(top_n).reset_index(drop=True)
    else:
        result = pd.DataFrame()

    return result, {
        "buy_again": buy_again,
        "association": assoc,
        "collaborative": cf,
        "frequent_itemsets": fp_freq,
        "rules": fp_rules
    }
