import requests

def test_supabase_live_sync():
    print("================================================================================")
    print("TESTING LIVE DYNAMIC SYNCHRONIZATION WITH SUPABASE CLOUD DATABASE")
    print("================================================================================")
    
    # 1. Post a dynamic new crop listing via FastAPI backend endpoint
    url = "http://127.0.0.1:8000/api/v1/listings"
    payload = {
        "title": "Live Supabase Sync Test - Fresh Organic Mangoes",
        "crop_name": "Mango",
        "category_id": 1,
        "farmer_name": "Live Test Farmer",
        "description": "Directly published crop listing to test live Supabase cloud sync.",
        "price_per_unit": 120.0,
        "unit": "kg",
        "available_quantity": 500.0,
        "is_organic": True,
        "grade": "A+",
        "location": "Mandya, Karnataka"
    }
    
    response = requests.post(url, json=payload)
    print(f"[HTTP Status]: {response.status_code}")
    data = response.json()
    print("[API Response]:", data)
    print(f"[Supabase Cloud Synced Status]: {data.get('supabase_synced')}")
    
    # 2. Query Supabase directly via PostgREST to verify row existence in Cloud Postgres
    supabase_url = "https://nxwhnbejvwxiuekhtmpm.supabase.co/rest/v1/seller_listing?title=eq.Live Supabase Sync Test - Fresh Organic Mangoes"
    headers = {
        "apikey": "sb_publishable__NSFd-NXvWsSDms7aE1tJQ_uziQLZO7",
        "Authorization": "Bearer sb_publishable__NSFd-NXvWsSDms7aE1tJQ_uziQLZO7"
    }
    res = requests.get(supabase_url, headers=headers)
    print("\n[Direct Supabase Query Check]:")
    print(f"Supabase HTTP Status: {res.status_code}")
    print("Supabase Data Rows Found:", res.json())

if __name__ == "__main__":
    test_supabase_live_sync()
