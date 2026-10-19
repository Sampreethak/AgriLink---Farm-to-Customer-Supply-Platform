import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_purchase_data, load_csv
from agri_recommender.farmer_recommendation import recommend_crops_for_farmer

purchase=build_purchase_data(DATA_DIR)
inventory=load_csv("inventory_item_rows.csv")
farmers=load_csv("farmer_profile_rows.csv")
pricing=load_csv("ml_pricing_log_rows.csv")
farmer_id=farmers["farmer_id"].iloc[0]
print("Farmer:",farmer_id)
print(recommend_crops_for_farmer(farmer_id,purchase,inventory,farmers,pricing,top_n=10))
