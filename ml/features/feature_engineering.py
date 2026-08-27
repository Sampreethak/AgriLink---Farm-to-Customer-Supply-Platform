import logging

logger = logging.getLogger(__name__)

class FeatureEngineer:
    """
    Feature Engineering Pipeline converting raw Customer, Listing, and Interaction
    records into numerical feature matrices and interaction mappings.
    """
    def __init__(self):
        self.customer_ids = []
        self.listing_ids = []
        self.cust_to_idx = {}
        self.list_to_idx = {}

    def fit_transform(self, customers_list: list, listings_list: list, interactions_list: list):
        logger.info("Engaging feature engineering pipeline for LightFM Hybrid Recommendation...")

        # Unique Customer & Listing Mapping
        self.customer_ids = sorted(list(set(c['customer_id'] for c in customers_list)))
        self.listing_ids = sorted(list(set(l['listing_id'] for l in listings_list)))

        self.cust_to_idx = {cid: idx for idx, cid in enumerate(self.customer_ids)}
        self.list_to_idx = {lid: idx for idx, lid in enumerate(self.listing_ids)}

        n_users = len(self.customer_ids)
        n_items = len(self.listing_ids)

        # 1. Build Interaction Matrix (n_users x n_items)
        interaction_matrix = [[0.0 for _ in range(n_items)] for _ in range(n_users)]

        for item in interactions_list:
            cid = str(item.get('customer_id'))
            lid = str(item.get('listing_id'))
            score = float(item.get('interaction_score', 1.0))

            if cid in self.cust_to_idx and lid in self.list_to_idx:
                u_idx = self.cust_to_idx[cid]
                i_idx = self.list_to_idx[lid]
                interaction_matrix[u_idx][i_idx] = max(interaction_matrix[u_idx][i_idx], score)

        # 2. Extract Customer Features (Loyalty points, Interaction count)
        cust_dict = {c['customer_id']: c for c in customers_list}
        customer_features = []
        for cid in self.customer_ids:
            c_info = cust_dict.get(cid, {})
            loyalty = float(c_info.get('loyalty_points', 0)) / 100.0
            customer_features.append([loyalty, 1.0])

        # 3. Extract Listing Features (Price, Quantity, Freshness, Organic)
        list_dict = {l['listing_id']: l for l in listings_list}
        listing_features = []
        for lid in self.listing_ids:
            l_info = list_dict.get(lid, {})
            price = float(l_info.get('price_per_unit', 30.0)) / 100.0
            qty = float(l_info.get('available_quantity', 50.0)) / 500.0
            fresh = float(l_info.get('freshness_score', 90.0)) / 100.0
            organic = 1.0 if l_info.get('is_organic', False) else 0.0
            listing_features.append([price, qty, fresh, organic])

        return {
            "interaction_matrix": interaction_matrix,
            "customer_features": customer_features,
            "listing_features": listing_features,
            "customer_ids": self.customer_ids,
            "listing_ids": self.listing_ids,
            "cust_to_idx": self.cust_to_idx,
            "list_to_idx": self.list_to_idx
        }
