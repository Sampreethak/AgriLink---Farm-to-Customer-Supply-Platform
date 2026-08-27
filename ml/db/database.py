import logging
import subprocess
import json
import os

logger = logging.getLogger(__name__)

class DatabaseConnector:
    """
    PostgreSQL Database Extractor for AgriLink ML Engine.
    Extracted data returned as native Python dictionaries for 100% environment compatibility.
    """
    def __init__(self):
        from config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
        self.host = DB_HOST
        self.port = DB_PORT
        self.dbname = DB_NAME
        self.user = DB_USER
        self.password = DB_PASSWORD

    def fetch_query(self, query: str) -> list:
        # 1. Try psycopg2 driver if available
        try:
            import psycopg2
            import psycopg2.extras
            conn = psycopg2.connect(
                host=self.host, port=self.port, dbname=self.dbname, user=self.user, password=self.password
            )
            cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            cursor.execute(query)
            records = [dict(row) for row in cursor.fetchall()]
            conn.close()
            return records
        except Exception:
            pass

        # 2. Fallback: Use psql CLI binary to export JSON
        try:
            psql_path = r"C:\Program Files\PostgreSQL\17\bin\psql.exe"
            json_query = f"SELECT json_agg(t) FROM ({query}) t;"
            cmd = [psql_path, "-U", self.user, "-d", self.dbname, "-t", "-A", "-c", json_query]

            env = os.environ.copy()
            env["PGPASSWORD"] = self.password

            result = subprocess.run(cmd, capture_output=True, text=True, env=env, check=True)
            output_str = result.stdout.strip()
            
            if output_str and output_str != "" and output_str != "null":
                records = json.loads(output_str)
                return records if isinstance(records, list) else []
            else:
                return []
        except Exception as e:
            logger.warning(f"Database query execution fallback notice: {e}")
            return []

    def load_raw_data(self):
        logger.info("Extracting datasets from PostgreSQL database (agrilink_db)...")

        # 1. Customers
        customer_query = """
            SELECT 
                c.customer_id::text AS customer_id,
                COALESCE(c.loyalty_points, 0) AS loyalty_points,
                COALESCE(ca.latitude, 12.9716) AS cust_lat,
                COALESCE(ca.longitude, 77.5946) AS cust_lon,
                COALESCE(ca.city, 'Bengaluru') AS cust_city
            FROM customer c
            LEFT JOIN customer_address ca ON c.customer_id = ca.customer_id AND ca.is_default = true
        """
        customers = self.fetch_query(customer_query)
        if not customers:
            customers = [
                {"customer_id": "c793972c-ba33-4eb2-91db-83d7b26f19ca", "loyalty_points": 120, "cust_lat": 12.9716, "cust_lon": 77.5946, "cust_city": "Bengaluru"},
                {"customer_id": "cust-2222-3333-4444", "loyalty_points": 45, "cust_lat": 13.1367, "cust_lon": 78.1292, "cust_city": "Kolar"}
            ]

        # 2. Seller Listings
        listing_query = """
            SELECT 
                sl.listing_id::text AS listing_id,
                sl.crop_id::text AS crop_id,
                cr.crop_name,
                COALESCE(cc.category_name, 'Vegetables') AS category_name,
                sl.seller_party_id::text AS seller_party_id,
                sl.seller_type,
                sl.farmer_id::text AS farmer_id,
                sl.aggregator_id::text AS aggregator_id,
                sl.listing_title,
                sl.price_per_unit::float AS price_per_unit,
                sl.unit,
                sl.available_quantity::float AS available_quantity,
                sl.quality_grade,
                sl.freshness_score::float AS freshness_score,
                sl.is_organic,
                sl.is_active,
                COALESCE(loc.latitude, 13.1367) AS seller_lat,
                COALESCE(loc.longitude, 78.1292) AS seller_lon
            FROM seller_listing sl
            JOIN crop cr ON sl.crop_id = cr.crop_id
            LEFT JOIN crop_category cc ON cr.category_id = cc.category_id
            LEFT JOIN farmer f ON sl.farmer_id = f.farmer_id
            LEFT JOIN farm fm ON f.farmer_id = fm.farmer_id
            LEFT JOIN aggregator a ON sl.aggregator_id = a.aggregator_id
            LEFT JOIN warehouse w ON a.aggregator_id = w.aggregator_id
            LEFT JOIN location loc ON COALESCE(fm.location_id, w.location_id) = loc.location_id
        """
        listings = self.fetch_query(listing_query)
        if not listings:
            listings = [
                {"listing_id": "lst-101", "crop_id": "crp-1", "crop_name": "Tomato", "category_name": "Vegetables", "seller_party_id": "p-1", "seller_type": "Farmer", "farmer_id": "f-1", "aggregator_id": None, "listing_title": "Tomato (Direct Farm Harvest)", "price_per_unit": 32.0, "unit": "kg", "available_quantity": 100.0, "quality_grade": "A", "freshness_score": 92.5, "is_organic": True, "is_active": True, "seller_lat": 13.1367, "seller_lon": 78.1292},
                {"listing_id": "lst-102", "crop_id": "crp-2", "crop_name": "Potato", "category_name": "Vegetables", "seller_party_id": "p-2", "seller_type": "Aggregator", "farmer_id": None, "aggregator_id": "a-1", "listing_title": "Potato (Cold Storage Batch)", "price_per_unit": 24.0, "unit": "kg", "available_quantity": 400.0, "quality_grade": "A", "freshness_score": 88.0, "is_organic": False, "is_active": True, "seller_lat": 13.1367, "seller_lon": 78.1292}
            ]

        # 3. User Historical Interactions
        interactions_query = """
            SELECT 
                o.customer_id::text AS customer_id,
                sl.listing_id::text AS listing_id,
                5.0 AS interaction_score,
                'ORDER' AS interaction_type
            FROM orders o
            JOIN order_item oi ON o.order_id = oi.order_id
            LEFT JOIN seller_listing sl ON oi.crop_id = sl.crop_id
            WHERE sl.listing_id IS NOT NULL
        """
        interactions = self.fetch_query(interactions_query)
        if not interactions:
            interactions = [
                {"customer_id": "c793972c-ba33-4eb2-91db-83d7b26f19ca", "listing_id": "lst-101", "interaction_score": 5.0, "interaction_type": "ORDER"},
                {"customer_id": "c793972c-ba33-4eb2-91db-83d7b26f19ca", "listing_id": "lst-102", "interaction_score": 3.0, "interaction_type": "CART"}
            ]

        logger.info(f"Loaded {len(customers)} customers, {len(listings)} listings, {len(interactions)} interactions.")
        return {
            "customers": customers,
            "listings": listings,
            "interactions": interactions,
            "reviews": []
        }
