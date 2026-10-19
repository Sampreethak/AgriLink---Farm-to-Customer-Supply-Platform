import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_listing_catalog
from agri_recommender.aggregator_matching import recommend_supplier_listings

catalog=build_listing_catalog(DATA_DIR)
print(recommend_supplier_listings("Tomato",500,catalog,top_n=10))
