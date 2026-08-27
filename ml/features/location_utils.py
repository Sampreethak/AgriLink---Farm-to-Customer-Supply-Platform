import math

def calculate_haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great circle distance between two points on the earth in kilometers.
    """
    if pd_isna(lat1) or pd_isna(lon1) or pd_isna(lat2) or pd_isna(lon2):
        return 15.0  # Default fallback distance of 15 km

    R = 6371.0  # Earth radius in kilometers

    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    distance = R * c
    return round(distance, 2)

def pd_isna(val):
    return val is None or (isinstance(val, float) and math.isnan(val))

def estimate_delivery_time_mins(distance_km: float) -> int:
    """
    Estimate delivery time in minutes based on distance.
    Base processing time = 20 mins, speed = 25 km/h.
    """
    base_processing_mins = 20
    transit_mins = int((distance_km / 25.0) * 60)
    return base_processing_mins + transit_mins

def estimate_delivery_cost(distance_km: float) -> float:
    """
    Calculate estimated delivery cost in INR.
    Base charge = ₹30 for first 5 km + ₹10 per additional km.
    """
    if distance_km <= 5.0:
        return 30.0
    return round(30.0 + (distance_km - 5.0) * 10.0, 2)
