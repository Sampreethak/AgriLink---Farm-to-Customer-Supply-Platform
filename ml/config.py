import os

# Database Connection Settings
DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "agrilink_db")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")

DB_URI = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Model Hyperparameters
NO_COMPONENTS = int(os.getenv("NO_COMPONENTS", "32"))
LEARNING_RATE = float(os.getenv("LEARNING_RATE", "0.05"))
LOSS_FUNCTION = os.getenv("LOSS_FUNCTION", "warp")  # 'warp', 'bpr', 'logistic'
EPOCHS = int(os.getenv("EPOCHS", "30"))
RANDOM_STATE = int(os.getenv("RANDOM_STATE", "42"))

# Recommendation System Parameters
TOP_K_RECOMMENDATIONS = 10
MODEL_SAVE_PATH = os.path.join(os.path.dirname(__file__), "artifacts", "lightfm_recommender.joblib")
FEATURE_PIPELINE_PATH = os.path.join(os.path.dirname(__file__), "artifacts", "feature_pipeline.joblib")

# API Config
API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8000"))
