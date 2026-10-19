import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_purchase_data, build_interactions, build_listing_catalog
from agri_recommender.customer_hybrid import build_customer_hybrid
from agri_recommender.repeat_explore import split_repeat_explore

purchase=build_purchase_data(DATA_DIR)
interactions=build_interactions(DATA_DIR)
catalog=build_listing_catalog(DATA_DIR)
customer_id=purchase["customer_id"].iloc[0]
final,_=build_customer_hybrid(customer_id,purchase,interactions,catalog,top_n=20)
purchased=set(purchase.loc[purchase["customer_id"]==customer_id,"crop_id"])
repeat,explore=split_repeat_explore(final,purchased,top_n=10)
print("REPEAT")
print(repeat)
print("\nEXPLORE")
print(explore)
