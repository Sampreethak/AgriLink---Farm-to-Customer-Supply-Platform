from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data"
OUTPUT_DIR = PROJECT_ROOT / "output"

# Customer interaction weights. The uploaded dataset already contains
# interaction_weight, so that value is preferred when present.
DEFAULT_INTERACTION_WEIGHTS = {
    "VIEW": 1.0,
    "SEARCH": 1.0,
    "WISHLIST": 2.0,
    "ADD_TO_CART": 5.0,
    "RATING": 4.0,
    "PURCHASE": 10.0,
}
