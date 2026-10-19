import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_interactions, build_listing_catalog
from agri_recommender.collaborative_filtering import recommend_for_customer

interactions=build_interactions(DATA_DIR)
catalog=build_listing_catalog(DATA_DIR)
customer_id=interactions["customer_id"].iloc[0]
print("Customer:",customer_id)
print(recommend_for_customer(customer_id,interactions,catalog,top_n=10))
