import os
import pickle
import logging
from db.database import DatabaseConnector
from features.feature_engineering import FeatureEngineer
from model.lightfm_engine import HybridLightFMEngine
from config import NO_COMPONENTS, LEARNING_RATE, LOSS_FUNCTION, EPOCHS, RANDOM_STATE, MODEL_SAVE_PATH, FEATURE_PIPELINE_PATH

logger = logging.getLogger(__name__)

class ModelTrainer:
    def __init__(self):
        self.db = DatabaseConnector()
        self.feature_engineer = FeatureEngineer()
        self.model = HybridLightFMEngine(
            no_components=NO_COMPONENTS,
            learning_rate=LEARNING_RATE,
            loss=LOSS_FUNCTION,
            random_state=RANDOM_STATE
        )

    def train_pipeline(self):
        logger.info("Starting AgriLink Machine Learning Training Pipeline...")

        # 1. Fetch Raw Data
        raw_data = self.db.load_raw_data()
        customers_df = raw_data['customers']
        listings_df = raw_data['listings']
        interactions_df = raw_data['interactions']

        # 2. Extract Features & Interaction Matrix
        transformed = self.feature_engineer.fit_transform(customers_df, listings_df, interactions_df)

        interaction_matrix = transformed['interaction_matrix']
        customer_features = transformed['customer_features']
        listing_features = transformed['listing_features']

        # 3. Fit LightFM Engine
        self.model.fit(
            interactions=interaction_matrix,
            user_features=customer_features,
            item_features=listing_features,
            epochs=EPOCHS
        )

        # 4. Save Artifacts using standard pickle
        artifacts_dir = os.path.dirname(MODEL_SAVE_PATH)
        os.makedirs(artifacts_dir, exist_ok=True)

        with open(MODEL_SAVE_PATH, 'wb') as f:
            pickle.dump(self.model, f)

        with open(FEATURE_PIPELINE_PATH, 'wb') as f:
            pickle.dump({
                "feature_engineer": self.feature_engineer,
                "transformed": transformed,
                "customers_df": customers_df,
                "listings_df": listings_df
            }, f)

        logger.info(f"Model successfully saved to {MODEL_SAVE_PATH}")
        logger.info(f"Feature pipeline saved to {FEATURE_PIPELINE_PATH}")

        return {
            "status": "success",
            "customers_trained": len(transformed['customer_ids']),
            "listings_trained": len(transformed['listing_ids']),
            "epochs": EPOCHS
        }
