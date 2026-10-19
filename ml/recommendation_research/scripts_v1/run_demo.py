import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_purchase_data, build_interactions, build_listing_catalog
from agri_recommender.customer_hybrid import build_customer_hybrid

purchase=build_purchase_data(DATA_DIR)
interactions=build_interactions(DATA_DIR)
catalog=build_listing_catalog(DATA_DIR)
customer_id=purchase["customer_id"].iloc[0]
final,_=build_customer_hybrid(customer_id,purchase,interactions,catalog,top_n=10)
print(final)
