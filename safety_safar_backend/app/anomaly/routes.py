"""
Geofencing & Anomaly Detection Routes
- Track location every 10 seconds
- Detect danger zone entry
- Detect abnormal speed
- Detect geofence exit
- Store AnomalyAlerts in DB
"""

from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from sqlalchemy import desc
from app.auth.dependencies import get_db, get_current_user, require_authority
from app.models.anomaly import LocationTrack, AnomalyAlert, DangerZone, AnomalyConfig
from app.models.users import User
from datetime import datetime, timezone, timedelta
from pydantic import BaseModel
from typing import Optional, List
import math

router = APIRouter(prefix="/anomaly", tags=["Anomaly & Geofencing"])

# ─────────────────────────────────────────────────────────────────
#  Constants / Default Thresholds
# ─────────────────────────────────────────────────────────────────
DEFAULT_SPEED_THRESHOLD_KMH = 50.0     # Above this → overspeeding anomaly
DEFAULT_GEOFENCE_RADIUS_KM = 100.0    # India bounding radius (example)
GEOFENCE_CENTER_LAT = 20.5937         # Center of India
GEOFENCE_CENTER_LNG = 78.9629
EARTH_RADIUS_KM = 6371.0


# ─────────────────────────────────────────────────────────────────
#  Pydantic Schemas
# ─────────────────────────────────────────────────────────────────
class LocationUpdate(BaseModel):
    latitude: float
    longitude: float
    accuracy: Optional[float] = None
    timestamp: Optional[str] = None


class DangerZoneCreate(BaseModel):
    name: str
    latitude: float
    longitude: float
    radius: float          # metres
    danger_level: str      # low / medium / high / critical
    zone_type: str         # restricted / unsafe / construction / industrial
    description: Optional[str] = None
    reason: Optional[str] = None


# ─────────────────────────────────────────────────────────────────
#  Utility: Haversine distance (metres)
# ─────────────────────────────────────────────────────────────────
def haversine_m(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Return distance between two GPS points in METRES."""
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return EARTH_RADIUS_KM * c * 1000  # metres


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    return haversine_m(lat1, lon1, lat2, lon2) / 1000.0


# ─────────────────────────────────────────────────────────────────
#  Utility: compute speed between two location tracks (km/h)
# ─────────────────────────────────────────────────────────────────
def compute_speed_kmh(prev: LocationTrack, curr_lat: float, curr_lon: float,
                      curr_time: datetime) -> float:
    dist_km = haversine_km(prev.latitude, prev.longitude, curr_lat, curr_lon)
    prev_time = prev.timestamp
    if prev_time.tzinfo is None:
        prev_time = prev_time.replace(tzinfo=timezone.utc)
    if curr_time.tzinfo is None:
        curr_time = curr_time.replace(tzinfo=timezone.utc)
    elapsed_hours = (curr_time - prev_time).total_seconds() / 3600.0
    if elapsed_hours <= 0:
        return 0.0
    return dist_km / elapsed_hours


# ─────────────────────────────────────────────────────────────────
#  Helper: create & persist an AnomalyAlert
# ─────────────────────────────────────────────────────────────────
def create_anomaly(
    db: Session,
    user_id,
    anomaly_type: str,
    severity: str,
    description: str,
    lat: float,
    lon: float,
    extra_data: dict = None,
):
    alert = AnomalyAlert(
        user_id=user_id,
        anomaly_type=anomaly_type,
        severity=severity,
        description=description,
        latitude=lat,
        longitude=lon,
        alert_data=extra_data or {},
        alert_status="active",
    )
    db.add(alert)
    db.commit()
    return alert


# ─────────────────────────────────────────────────────────────────
#  POST /anomaly/track-location  (Tourist sends location)
# ─────────────────────────────────────────────────────────────────
@router.post("/track-location")
def track_location(
    data: LocationUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    now = datetime.now(timezone.utc)

    # Parse provided timestamp or use now
    if data.timestamp:
        try:
            now = datetime.fromisoformat(data.timestamp.replace("Z", "+00:00"))
        except Exception:
            pass

    anomalies_detected = []

    # ── 1. Fetch last known location ──────────────────────────────
    prev_track = (
        db.query(LocationTrack)
        .filter(LocationTrack.user_id == current_user.id)
        .order_by(desc(LocationTrack.timestamp))
        .first()
    )

    # ── 2. Speed anomaly detection ────────────────────────────────
    speed_kmh = 0.0
    if prev_track:
        speed_kmh = compute_speed_kmh(
            prev_track, data.latitude, data.longitude, now
        )
        if speed_kmh > DEFAULT_SPEED_THRESHOLD_KMH:
            create_anomaly(
                db,
                current_user.id,
                anomaly_type="overspeeding",
                severity="warning",
                description=(
                    f"Abnormal speed detected: {speed_kmh:.1f} km/h "
                    f"(threshold: {DEFAULT_SPEED_THRESHOLD_KMH} km/h)"
                ),
                lat=data.latitude,
                lon=data.longitude,
                extra_data={"speed_kmh": round(speed_kmh, 2)},
            )
            anomalies_detected.append(
                {"type": "overspeeding", "speed_kmh": round(speed_kmh, 2)}
            )

    # ── 3. Geofence exit detection ────────────────────────────────
    dist_from_center_km = haversine_km(
        GEOFENCE_CENTER_LAT, GEOFENCE_CENTER_LNG,
        data.latitude, data.longitude,
    )
    if dist_from_center_km > DEFAULT_GEOFENCE_RADIUS_KM:
        create_anomaly(
            db,
            current_user.id,
            anomaly_type="geofence_exit",
            severity="critical",
            description=(
                f"Tourist exited the designated travel zone. "
                f"Distance from center: {dist_from_center_km:.1f} km"
            ),
            lat=data.latitude,
            lon=data.longitude,
            extra_data={
                "distance_km": round(dist_from_center_km, 2),
                "geofence_radius_km": DEFAULT_GEOFENCE_RADIUS_KM,
            },
        )
        anomalies_detected.append(
            {
                "type": "geofence_exit",
                "distance_km": round(dist_from_center_km, 2),
            }
        )

    # ── 4. Danger zone entry detection ───────────────────────────
    active_zones = (
        db.query(DangerZone)
        .filter(DangerZone.is_active == True)
        .all()
    )
    for zone in active_zones:
        dist_m = haversine_m(
            zone.latitude, zone.longitude,
            data.latitude, data.longitude,
        )
        if dist_m <= zone.radius:
            # Avoid duplicate alerts within last 10 minutes for same zone
            recent_cutoff = now - timedelta(minutes=10)
            recent = (
                db.query(AnomalyAlert)
                .filter(
                    AnomalyAlert.user_id == current_user.id,
                    AnomalyAlert.anomaly_type == "danger_zone_entry",
                    AnomalyAlert.alert_data["zone_id"].astext == str(zone.id),
                    AnomalyAlert.created_at >= recent_cutoff,
                )
                .first()
            )
            if not recent:
                severity_map = {
                    "low": "info",
                    "medium": "warning",
                    "high": "warning",
                    "critical": "critical",
                }
                create_anomaly(
                    db,
                    current_user.id,
                    anomaly_type="danger_zone_entry",
                    severity=severity_map.get(zone.danger_level, "warning"),
                    description=(
                        f"Tourist entered danger zone: '{zone.name}'. "
                        f"Level: {zone.danger_level.upper()}. "
                        f"{zone.reason or ''}"
                    ),
                    lat=data.latitude,
                    lon=data.longitude,
                    extra_data={
                        "zone_id": str(zone.id),
                        "zone_name": zone.name,
                        "zone_type": zone.zone_type,
                        "danger_level": zone.danger_level,
                        "distance_m": round(dist_m, 1),
                    },
                )
                anomalies_detected.append(
                    {
                        "type": "danger_zone_entry",
                        "zone_name": zone.name,
                        "danger_level": zone.danger_level,
                    }
                )

    # ── 5. Save location track ────────────────────────────────────
    track = LocationTrack(
        user_id=current_user.id,
        latitude=data.latitude,
        longitude=data.longitude,
        accuracy=data.accuracy,
        speed=round(speed_kmh, 2) if speed_kmh else None,
        timestamp=now,
    )
    db.add(track)
    db.commit()

    return {
        "status": "ok",
        "anomalies": anomalies_detected,
        "anomaly_detected": len(anomalies_detected) > 0,
    }


# ─────────────────────────────────────────────────────────────────
#  GET /anomaly/alerts  (Authority views all anomaly alerts)
# ─────────────────────────────────────────────────────────────────
@router.get("/alerts")
def get_anomaly_alerts(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_authority),
):
    alerts = (
        db.query(AnomalyAlert, User)
        .join(User, AnomalyAlert.user_id == User.id)
        .order_by(desc(AnomalyAlert.created_at))
        .limit(100)
        .all()
    )
    result = []
    for alert, user in alerts:
        result.append({
            "id": str(alert.id),
            "user_id": str(alert.user_id),
            "tourist_name": f"{user.first_name or ''} {user.last_name or ''}".strip(),
            "tourist_phone": user.phone,
            "anomaly_type": alert.anomaly_type,
            "severity": alert.severity,
            "description": alert.description,
            "latitude": alert.latitude,
            "longitude": alert.longitude,
            "alert_data": alert.alert_data,
            "alert_status": alert.alert_status,
            "is_resolved": alert.is_resolved,
            "created_at": alert.created_at.isoformat() if alert.created_at else None,
        })
    return result


# ─────────────────────────────────────────────────────────────────
#  POST /anomaly/alerts/resolve/{alert_id}
# ─────────────────────────────────────────────────────────────────
@router.post("/alerts/resolve/{alert_id}")
def resolve_anomaly_alert(
    alert_id: str,
    note: Optional[str] = Body(None, embed=True),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_authority),
):
    alert = db.query(AnomalyAlert).filter(AnomalyAlert.id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=404, detail="Anomaly alert not found")
    alert.is_resolved = True
    alert.alert_status = "resolved"
    alert.authority_id = current_user.id
    alert.authority_note = note
    alert.resolved_at = datetime.now(timezone.utc)
    db.commit()
    return {"message": "Anomaly alert resolved"}


# ─────────────────────────────────────────────────────────────────
#  GET /anomaly/danger-zones  (List all active danger zones)
# ─────────────────────────────────────────────────────────────────
@router.get("/danger-zones")
def get_danger_zones(
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    radius_km: Optional[float] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    zones = db.query(DangerZone).filter(DangerZone.is_active == True).all()
    result = []
    for z in zones:
        dist = None
        if latitude is not None and longitude is not None:
            dist = round(haversine_km(latitude, longitude, z.latitude, z.longitude), 2)
            if radius_km is not None and dist > radius_km:
                continue
        result.append({
            "id": str(z.id),
            "name": z.name,
            "latitude": z.latitude,
            "longitude": z.longitude,
            "radius": z.radius,
            "danger_level": z.danger_level,
            "zone_type": z.zone_type,
            "description": z.description,
            "reason": z.reason,
            "distance_km": dist,
        })
    return result


# ─────────────────────────────────────────────────────────────────
#  POST /anomaly/danger-zones  (Authority adds a danger zone)
# ─────────────────────────────────────────────────────────────────
@router.post("/danger-zones")
def add_danger_zone(
    data: DangerZoneCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_authority),
):
    zone = DangerZone(
        name=data.name,
        latitude=data.latitude,
        longitude=data.longitude,
        radius=data.radius,
        danger_level=data.danger_level,
        zone_type=data.zone_type,
        description=data.description,
        reason=data.reason,
        created_by=current_user.id,
    )
    db.add(zone)
    db.commit()
    db.refresh(zone)
    return {"message": "Danger zone added", "id": str(zone.id)}


# ─────────────────────────────────────────────────────────────────
#  DELETE /anomaly/danger-zones/{zone_id}
# ─────────────────────────────────────────────────────────────────
@router.delete("/danger-zones/{zone_id}")
def delete_danger_zone(
    zone_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_authority),
):
    zone = db.query(DangerZone).filter(DangerZone.id == zone_id).first()
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")
    zone.is_active = False
    db.commit()
    return {"message": "Danger zone deactivated"}


# ─────────────────────────────────────────────────────────────────
#  GET /anomaly/config  (Get detection thresholds)
# ─────────────────────────────────────────────────────────────────
@router.get("/config")
def get_config(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_authority),
):
    cfg = db.query(AnomalyConfig).filter(AnomalyConfig.is_active == True).first()
    if not cfg:
        return {
            "stillness_minutes": 45,
            "speed_threshold_kmh": DEFAULT_SPEED_THRESHOLD_KMH,
            "geofence_radius_km": DEFAULT_GEOFENCE_RADIUS_KM,
            "gps_update_interval_sec": 10,
        }
    return {
        "stillness_minutes": cfg.stillness_minutes,
        "speed_threshold_kmh": cfg.speed_threshold_kmh,
        "route_deviation_warning_m": cfg.route_deviation_warning_m,
        "route_deviation_alert_m": cfg.route_deviation_alert_m,
        "gps_update_interval_sec": cfg.gps_update_interval_sec,
    }
