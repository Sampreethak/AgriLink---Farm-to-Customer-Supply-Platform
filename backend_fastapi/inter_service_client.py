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
