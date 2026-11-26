"""
Inter-service HTTP client for connecting AgriLink (Microservice 1) with:
  - Microservice 2: Citizen Identity & Double-Entry Wallet (CIS)
  - Microservice 3: RTO / Commercial Fleet & Logistics Platform (RTO)

Design principle:
  - Zero breaking changes to standalone AgriLink, Citizen, or RTO services.
  - Every remote call has a short timeout and graceful fallback so AgriLink
    continues working identically even when Citizen or RTO are offline.
"""

import os
import uuid
import logging
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

import httpx

logger = logging.getLogger("agrilink.inter_service")

CITIZEN_SERVICE_URL = os.getenv("CITIZEN_SERVICE_URL", "http://localhost:8001/api/v1").rstrip("/")
RTO_SERVICE_URL = os.getenv("RTO_SERVICE_URL", "http://localhost:8002/v1").rstrip("/")
INTERNAL_SERVICE_SECRET = os.getenv(
    "INTERNAL_SERVICE_SECRET",
    "insecure-internal-secret-for-marketplace-and-rto",
)
REQUEST_TIMEOUT = float(os.getenv("INTER_SERVICE_TIMEOUT", "3.0"))


def _citizen_headers() -> Dict[str, str]:
    return {
        "X-Service-Key": INTERNAL_SERVICE_SECRET,
        "Content-Type": "application/json",
    }


def _rto_headers(idempotency_key: Optional[str] = None) -> Dict[str, str]:
    headers = {
        "Content-Type": "application/json",
        "X-Correlation-ID": str(uuid.uuid4()),
    }
    if idempotency_key:
        headers["Idempotency-Key"] = idempotency_key
    return headers


def check_ecosystem_health() -> Dict[str, Any]:
    """Ping Citizen (M2) and RTO (M3) to report live tri-service connectivity."""
    citizen_base = CITIZEN_SERVICE_URL.rsplit("/api/v1", 1)[0]
    rto_base = RTO_SERVICE_URL.rsplit("/v1", 1)[0]

    services = {
        "agrilink_m1": {"status": "UP", "url": "self"},
        "citizen_m2": {"status": "OFFLINE", "url": citizen_base},
        "rto_vehicle_m3": {"status": "OFFLINE", "url": rto_base},
    }

    with httpx.Client(timeout=2.0) as client:
        for key, url in [
            ("citizen_m2", f"{citizen_base}/docs"),
            ("rto_vehicle_m3", f"{rto_base}/docs"),
        ]:
            try:
                res = client.get(url)
                if res.status_code < 500:
                    services[key]["status"] = "UP"
                    services[key]["http_status"] = res.status_code
            except Exception as exc:
                services[key]["error"] = str(exc)

    return services


def introspect_token(token: str) -> Dict[str, Any]:
    """Validate a Citizen JWT via CIS /internal/tokens/introspect."""
    url = f"{CITIZEN_SERVICE_URL}/internal/tokens/introspect"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.post(url, json={"token": token}, headers=_citizen_headers())
            if res.status_code == 200:
                return {"connected": True, **res.json()}
            return {"connected": True, "active": False, "status_code": res.status_code, "detail": res.text}
    except Exception as exc:
        logger.debug(f"CIS introspect fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "active": False, "error": str(exc)}


def login_via_citizen(identifier: str, password: str) -> Dict[str, Any]:
    """
    Authenticate a user against Citizen (M2) /auth/login and fetch their
    status, personas, and wallet_id. Falls back cleanly if M2 is offline.
    """
    login_url = f"{CITIZEN_SERVICE_URL}/auth/login"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.post(
                login_url,
                json={"identifier": identifier, "password": password, "device_label": "agrilink-web"},
            )
            if res.status_code != 200:
                return {"connected": True, "authenticated": False, "status_code": res.status_code, "detail": res.text}

            token_data = res.json()
            access_token = token_data.get("access_token")
            citizen_id = token_data.get("citizen_id") or (token_data.get("citizen") or {}).get("id")

            # Introspect token if citizen_id wasn't directly in the login response
            if not citizen_id and access_token:
                intro = introspect_token(access_token)
                citizen_id = intro.get("citizen_id")

            status_info = get_citizen_status(str(citizen_id)) if citizen_id else {}
            return {
                "connected": True,
                "authenticated": True,
                "citizen_id": str(citizen_id) if citizen_id else None,
                "access_token": access_token,
                "refresh_token": token_data.get("refresh_token"),
                "citizen_status": status_info,
            }
    except Exception as exc:
        logger.debug(f"CIS login fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "authenticated": False, "error": str(exc)}


def get_citizen_status(citizen_id: str) -> Dict[str, Any]:
    """Fetch citizen KYC tier, status, and wallet_id from CIS."""
    url = f"{CITIZEN_SERVICE_URL}/internal/citizens/{citizen_id}/status"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url, headers=_citizen_headers())
            if res.status_code == 200:
                return {"connected": True, **res.json()}
            return {"connected": True, "error": res.text, "status_code": res.status_code}
    except Exception as exc:
        logger.debug(f"CIS status fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "error": str(exc)}


def lookup_citizen_by_identifier(identifier: str) -> Dict[str, Any]:
    """
    Resolve a Citizen profile (citizen_id, wallet_id, kyc_tier) using ONLY
    X-Service-Key (no Citizen password required).
    Supports UUID directly via /internal/citizens/{id}/status, or email/phone
    via /internal/citizens/lookup?identifier=... if enabled on M2.
    """
    ident = (identifier or "").strip()
    if not ident:
        return {"connected": False, "found": False, "error": "Empty identifier"}

    if len(ident) == 36 and ident.count("-") == 4:
        st = get_citizen_status(ident)
        return {"found": bool(st.get("citizen_id")), **st}

    url = f"{CITIZEN_SERVICE_URL}/internal/citizens/lookup"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url, params={"identifier": ident}, headers=_citizen_headers())
            if res.status_code == 200:
                data = res.json()
                return {"connected": True, "found": True, **data}
            return {
                "connected": True,
                "found": False,
                "status_code": res.status_code,
                "note": "Citizen lookup by email/phone not available on M2 or user not found; pass citizen_id UUID or login once with Citizen credentials.",
            }
    except Exception as exc:
        return {"connected": False, "fallback": True, "found": False, "error": str(exc)}


def get_citizen_personas(citizen_id: str) -> Dict[str, Any]:
    """Fetch citizen active personas from CIS."""
    url = f"{CITIZEN_SERVICE_URL}/internal/citizens/{citizen_id}/personas"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url, headers=_citizen_headers())
            if res.status_code == 200:
                return {"connected": True, **res.json()}
            return {"connected": True, "active_personas": [], "status_code": res.status_code}
    except Exception as exc:
        logger.debug(f"CIS personas fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "active_personas": [], "error": str(exc)}


def get_citizen_bank_accounts(
    citizen_id: str,
    access_token: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Fetch linked bank accounts for a citizen from M2.
    Tries X-Service-Key internal endpoints first, then Bearer JWT endpoints
    if a Citizen access_token is available from AgriLink login.
    """
    headers_key = _citizen_headers()
    endpoints_key = [
        f"{CITIZEN_SERVICE_URL}/internal/citizens/{citizen_id}/bank-accounts",
        f"{CITIZEN_SERVICE_URL}/internal/citizens/{citizen_id}/bank_accounts",
    ]
    with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
        for url in endpoints_key:
            try:
                res = client.get(url, headers=headers_key)
                if res.status_code == 200:
                    data = res.json()
                    items = data if isinstance(data, list) else data.get("bank_accounts", data.get("items", data.get("accounts", [])))
                    return {"connected": True, "source": "internal_key", "bank_accounts": items}
            except Exception as exc:
                logger.debug(f"CIS internal bank-accounts failed ({url}): {exc}")

        if access_token:
            bearer_headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json",
            }
            for url in [
                f"{CITIZEN_SERVICE_URL}/bank-accounts",
                f"{CITIZEN_SERVICE_URL}/bank-accounts/me",
                f"{CITIZEN_SERVICE_URL}/citizens/me/bank-accounts",
                f"{CITIZEN_SERVICE_URL}/wallet/bank-accounts",
            ]:
                try:
                    res = client.get(url, headers=bearer_headers)
                    if res.status_code == 200:
                        data = res.json()
                        items = data if isinstance(data, list) else data.get("bank_accounts", data.get("items", data.get("accounts", [])))
                        return {"connected": True, "source": "citizen_jwt", "bank_accounts": items}
                except Exception as exc:
                    logger.debug(f"CIS JWT bank-accounts failed ({url}): {exc}")

    return {"connected": True, "bank_accounts": [], "note": "No bank-accounts endpoint matched or no linked bank accounts returned."}


def get_citizen_wallet_details(
    citizen_id: str,
    wallet_id: Optional[str] = None,
    access_token: Optional[str] = None,
) -> Dict[str, Any]:
    """Fetch wallet balance & currency from M2 via X-Service-Key or Citizen JWT."""
    headers_key = _citizen_headers()
    with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
        for url in [
            f"{CITIZEN_SERVICE_URL}/internal/citizens/{citizen_id}/wallet",
            f"{CITIZEN_SERVICE_URL}/internal/wallets/{wallet_id}" if wallet_id else None,
        ]:
            if not url:
                continue
            try:
                res = client.get(url, headers=headers_key)
                if res.status_code == 200:
                    return {"connected": True, "source": "internal_key", **res.json()}
            except Exception as exc:
                logger.debug(f"CIS internal wallet details failed ({url}): {exc}")

        if access_token:
            bearer_headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json",
            }
            for url in [
                f"{CITIZEN_SERVICE_URL}/wallets/me",
                f"{CITIZEN_SERVICE_URL}/wallet/me",
                f"{CITIZEN_SERVICE_URL}/wallet",
            ]:
                try:
                    res = client.get(url, headers=bearer_headers)
                    if res.status_code == 200:
                        return {"connected": True, "source": "citizen_jwt", **res.json()}
                except Exception as exc:
                    logger.debug(f"CIS JWT wallet details failed ({url}): {exc}")

    return {"connected": True}


def get_rto_vehicles() -> Dict[str, Any]:
    """Fetch all registered vehicles from Microservice 3 (RTO /v1/vehicles)."""
    url = f"{RTO_SERVICE_URL}/vehicles"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url)
            if res.status_code == 200:
                data = res.json()
                items = data if isinstance(data, list) else data.get("items", data.get("vehicles", []))
                return {"connected": True, "count": len(items), "vehicles": items}
            return {"connected": True, "count": 0, "vehicles": [], "status_code": res.status_code}
    except Exception as exc:
        logger.debug(f"RTO vehicles fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "count": 0, "vehicles": [], "error": str(exc)}


def get_user_rto_data(
    citizen_id: str,
    full_name: Optional[str] = None,
    email: Optional[str] = None,
) -> Dict[str, Any]:
    """Fetch registered vehicles, rental listings, and outbox events belonging to a specific user from RTO (M3)."""
    vehicles_res = get_rto_vehicles()
    listings_res = get_rto_listings()
    outbox_res = get_rto_outbox_events(published_filter=None)

    cid_lower = (citizen_id or "").strip().lower()
    name_lower = (full_name or "").strip().lower()
    email_lower = (email or "").strip().lower()
    email_prefix = email_lower.split("@")[0] if "@" in email_lower else ""

    def _matches(text: str) -> bool:
        t = (text or "").lower()
        if cid_lower and cid_lower in t:
            return True
        if name_lower and len(name_lower) >= 3 and (name_lower in t or t in name_lower):
            return True
        if email_prefix and len(email_prefix) >= 3 and email_prefix in t:
            return True
        return False

    matched_vehicles = []
    for v in vehicles_res.get("vehicles", []):
        owner_id = str(v.get("owner_citizen_id") or "").lower()
        owner_name = str(v.get("owner_name") or "").lower()
        if (cid_lower and owner_id == cid_lower) or (owner_name and _matches(owner_name)):
            matched_vehicles.append(v)

    matched_listings = []
    for item in listings_res.get("listings", []):
        owner_id = str(item.get("owner_citizen_id") or "").lower()
        veh = item.get("vehicle") or {}
        owner_name = str(veh.get("owner_name") or "").lower()
        if (cid_lower and owner_id == cid_lower) or (owner_name and _matches(owner_name)):
            matched_listings.append(item)

    matched_events = []
    for ev in outbox_res.get("events", []):
        payload_str = str(ev.get("payload") or "")
        if _matches(payload_str):
            matched_events.append(ev)

    return {
        "connected": vehicles_res.get("connected", False) or listings_res.get("connected", False) or outbox_res.get("connected", False),
        "owned_vehicles_count": len(matched_vehicles),
        "owned_vehicles": matched_vehicles,
        "owned_listings_count": len(matched_listings),
        "owned_listings": matched_listings,
        "related_events_count": len(matched_events),
        "related_events": matched_events,
        "all_available_fleet_count": listings_res.get("count", 0),
        "all_available_fleet": listings_res.get("listings", []),
    }


def check_persona_eligibility(citizen_id: str, persona: str) -> Dict[str, Any]:
    """Verify whether a citizen holds an active persona (e.g. FARMER, CUSTOMER)."""
    url = f"{CITIZEN_SERVICE_URL}/internal/citizens/{citizen_id}/eligibility"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url, params={"persona": persona}, headers=_citizen_headers())
            if res.status_code == 200:
                return {"connected": True, **res.json()}
            return {"connected": True, "eligible": False, "error": res.text}
    except Exception as exc:
        logger.debug(f"CIS eligibility fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "eligible": True, "error": str(exc)}


def place_wallet_hold(
    wallet_id: str,
    amount: float,
    reason_code: str,
    idempotency_key: str,
    expires_in_hours: int = 72,
) -> Dict[str, Any]:
    """Place an escrow hold on a Citizen wallet via CIS-M6."""
    url = f"{CITIZEN_SERVICE_URL}/internal/wallets/{wallet_id}/hold"
    payload = {
        "amount": round(float(amount), 2),
        "reason_code": reason_code[:60],
        "idempotency_key": idempotency_key[:100],
        "expires_in_hours": expires_in_hours,
    }
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.post(url, json=payload, headers=_citizen_headers())
            if res.status_code in (200, 201):
                return {"connected": True, "held": True, **res.json()}
            return {"connected": True, "held": False, "status_code": res.status_code, "error": res.text}
    except Exception as exc:
        logger.debug(f"CIS hold fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "held": False, "error": str(exc)}


def release_wallet_hold(wallet_id: str, hold_id: str) -> Dict[str, Any]:
    """Release an active escrow hold back to the buyer's wallet."""
    url = f"{CITIZEN_SERVICE_URL}/internal/wallets/{wallet_id}/release"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.post(url, params={"hold_id": hold_id}, headers=_citizen_headers())
            if res.status_code == 200:
                return {"connected": True, "released": True, **res.json()}
            return {"connected": True, "released": False, "status_code": res.status_code, "error": res.text}
    except Exception as exc:
        logger.debug(f"CIS release fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "released": False, "error": str(exc)}


def credit_wallet(
    wallet_id: str,
    amount: float,
    description: str,
    reference_type: str,
    idempotency_key: str,
) -> Dict[str, Any]:
    """Credit a Citizen wallet (used for 68-10-14-8 fair-share settlements)."""
    url = f"{CITIZEN_SERVICE_URL}/internal/wallets/{wallet_id}/credit"
    payload = {
        "amount": round(float(amount), 2),
        "description": description[:255],
        "reference_type": reference_type[:60],
        "idempotency_key": idempotency_key[:100],
    }
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.post(url, json=payload, headers=_citizen_headers())
            if res.status_code in (200, 201):
                return {"connected": True, "credited": True, **res.json()}
            return {"connected": True, "credited": False, "status_code": res.status_code, "error": res.text}
    except Exception as exc:
        logger.debug(f"CIS credit fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "credited": False, "error": str(exc)}


def settle_order_fair_share(
    order_id: str,
    total_amount: float,
    farmer_wallet_id: Optional[str] = None,
    aggregator_wallet_id: Optional[str] = None,
    logistics_wallet_id: Optional[str] = None,
    platform_wallet_id: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Execute the AgriLink 68-10-14-8 fair-share settlement via Citizen Wallet (M2).
    Any party without a wallet_id is recorded in the breakdown without failing.
    """
    splits = [
        ("FARMER", 0.68, farmer_wallet_id, "AGRILINK_FARMER_PAYOUT"),
        ("AGGREGATOR", 0.10, aggregator_wallet_id, "AGRILINK_AGGREGATOR_PAYOUT"),
        ("LOGISTICS", 0.14, logistics_wallet_id, "AGRILINK_LOGISTICS_PAYOUT"),
        ("PLATFORM", 0.08, platform_wallet_id, "AGRILINK_PLATFORM_FEE"),
    ]
    results = {}
    for role, pct, w_id, ref_type in splits:
        share = round(float(total_amount) * pct, 2)
        if w_id and share > 0:
            res = credit_wallet(
                wallet_id=w_id,
                amount=share,
                description=f"{role} {int(pct*100)}% settlement for {order_id}",
                reference_type=ref_type,
                idempotency_key=f"settle-{order_id}-{role.lower()}",
            )
            results[role.lower()] = {"amount": share, "wallet_id": w_id, **res}
        else:
            results[role.lower()] = {"amount": share, "wallet_id": w_id, "skipped": True}
    return results


def request_rto_vehicle(
    agrilink_job_ref: str,
    delivery_person_citizen_id: str = "CIT-DELIVERY-003",
    delivery_person_name: str = "Suresh Gowda",
    delivery_person_kyc_tier: str = "T3",
    delivery_person_licence_classes: str = "LMV,HMV",
    vehicle_class: str = "LIGHT_COMMERCIAL",
    min_capacity_kg: float = 500.0,
    destination: str = "Bengaluru Hub",
    duration_hours: int = 8,
    idempotency_key: Optional[str] = None,
) -> Dict[str, Any]:
    """Dispatch a delivery vehicle request to Microservice 3 (RTO / Fleet)."""
    url = f"{RTO_SERVICE_URL}/vehicle-requests"
    now = datetime.now(timezone.utc)
    start_dt = (now + timedelta(minutes=15)).isoformat().replace("+00:00", "Z")
    end_dt = (now + timedelta(hours=duration_hours)).isoformat().replace("+00:00", "Z")
    idem = idempotency_key or f"idemp-{agrilink_job_ref}"

    payload = {
        "agrilink_job_ref": agrilink_job_ref,
        "delivery_person_citizen_id": delivery_person_citizen_id,
        "delivery_person_name": delivery_person_name,
        "delivery_person_kyc_tier": delivery_person_kyc_tier,
        "delivery_person_licence_classes": delivery_person_licence_classes,
        "vehicle_class": vehicle_class,
        "min_capacity_kg": float(min_capacity_kg),
        "start_time": start_dt,
        "end_time": end_dt,
        "destination": destination,
        "idempotency_key": idem,
    }
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.post(url, json=payload, headers=_rto_headers(idem))
            if res.status_code in (200, 201):
                return {"connected": True, "assigned": True, **res.json()}
            return {"connected": True, "assigned": False, "status_code": res.status_code, "error": res.text}
    except Exception as exc:
        logger.debug(f"RTO vehicle-requests fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "assigned": False, "error": str(exc)}


def get_rto_outbox_events(published_filter: Optional[bool] = False) -> Dict[str, Any]:
    """Poll transactional outbox events from Microservice 3 (RTO)."""
    url = f"{RTO_SERVICE_URL}/inter-service/outbox"
    params = {} if published_filter is None else {"published_filter": str(published_filter).lower()}
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url, params=params)
            if res.status_code == 200:
                return {"connected": True, "events": res.json()}
            return {"connected": True, "events": [], "status_code": res.status_code}
    except Exception as exc:
        logger.debug(f"RTO outbox fallback (offline): {exc}")
        return {"connected": False, "fallback": True, "events": [], "error": str(exc)}


def get_rto_catalog() -> Dict[str, Any]:
    """Fetch Microservice 3 (RTO) inter-service catalog metadata."""
    url = f"{RTO_SERVICE_URL}/inter-service/catalog"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url)
            if res.status_code == 200:
                return {"connected": True, "catalog": res.json()}
            return {"connected": True, "status_code": res.status_code}
    except Exception as exc:
        return {"connected": False, "fallback": True, "error": str(exc)}


def get_rto_listings() -> Dict[str, Any]:
    """Fetch available commercial vehicle rental listings from Microservice 3 (RTO)."""
    url = f"{RTO_SERVICE_URL}/listings"
    try:
        with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
            res = client.get(url)
            if res.status_code == 200:
                data = res.json()
                items = data if isinstance(data, list) else data.get("items", data.get("listings", []))
                return {"connected": True, "count": len(items), "listings": items[:10]}
            return {"connected": True, "count": 0, "listings": [], "status_code": res.status_code}
    except Exception as exc:
        return {"connected": False, "fallback": True, "count": 0, "listings": [], "error": str(exc)}
