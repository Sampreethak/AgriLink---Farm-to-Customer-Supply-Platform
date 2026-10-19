import os
from pathlib import Path

# Paths to data directories
ML_DIR = Path(__file__).resolve().parent.parent
PROJECT_ROOT = ML_DIR.parent

DATA_DIR_CSV = PROJECT_ROOT / "database" / "csv"
DATA_DIR_REC = PROJECT_ROOT / "AgriLink_Recommendation_Code" / "AgriLink_Recommendation_Code" / "data"

OUTPUT_DIR = ML_DIR / "output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

DEFAULT_INTERACTION_WEIGHTS = {
    "VIEW": 1.0,
    "SEARCH": 1.0,
    "WISHLIST": 2.0,
    "ADD_TO_CART": 5.0,
    "CART": 5.0,
    "RATING": 4.0,
    "REVIEW": 5.0,
    "PURCHASE": 10.0,
}
