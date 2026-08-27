import os
import sys

# Ensure root module import
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import logging
from model.trainer import ModelTrainer
from model.predictor import RecommendationPredictor
from evaluation.metrics import ModelEvaluator
from visualizations.dashboard_generator import VisualizationDashboard
from db.database import DatabaseConnector

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

def main():
    logger.info("Starting Full Training, Evaluation & Visualization Script for AgriLink ML Engine...")

    # 1. Train Model
    trainer = ModelTrainer()
    train_res = trainer.train_pipeline()
    logger.info(f"Training Completed: {train_res}")

    # 2. Load Predictor & Raw Data for Evaluation
    predictor = RecommendationPredictor()
    raw_data = DatabaseConnector().load_raw_data()
    customers_list = raw_data['customers']
    listings_list = raw_data['listings']
    interactions_list = raw_data['interactions']

    # Build Ground Truth Dictionary
    ground_truth = {}
    for row in interactions_list:
        cid = str(row['customer_id'])
        lid = str(row['listing_id'])
        if cid not in ground_truth:
            ground_truth[cid] = set()
        ground_truth[cid].add(lid)

    # Generate Predictions for Evaluation
    predictions = {}
    total_catalog = set(str(l['listing_id']) for l in listings_list)

    for cust in customers_list:
        cust_id = str(cust['customer_id'])
        recs = predictor.recommend_for_customer(cust_id, top_k=10)
        predictions[cust_id] = [r['listing_id'] for r in recs]

    # 3. Evaluate Metrics
    evaluator = ModelEvaluator()
    metrics = evaluator.evaluate_model(ground_truth, predictions, total_catalog, k=10)
    logger.info(f"Final ML Model Metrics: {metrics}")

    # 4. Generate Visualizations
    dashboard = VisualizationDashboard()
    dashboard.generate_all_dashboards(metrics, listings_list)

    print("\n" + "=" * 65)
    print(" AGRILINK MACHINE LEARNING RECOMMENDATION ENGINE READY")
    print("=" * 65)
    for k, v in metrics.items():
        print(f"  - {k:<22}: {v}")
    print("=" * 65 + "\n")

if __name__ == "__main__":
    main()
