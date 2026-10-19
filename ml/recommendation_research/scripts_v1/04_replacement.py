import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_listing_catalog
from agri_recommender.replacement import recommend_replacements

catalog=build_listing_catalog(DATA_DIR)
target=catalog["listing_id"].iloc[0]
print("Target listing:",target)
print(recommend_replacements(target,catalog,top_n=3))
