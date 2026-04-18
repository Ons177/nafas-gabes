from fastapi import FastAPI, HTTPException
from typing import List
from fastapi.middleware.cors import CORSMiddleware
from database import get_db_connection, init_db
from schemas import (
    UserCreate,
    UserLogin,
    PredictRequest,
    PredictResponse,
    ReportRequest,
    AlertResponse,
    CitizenDashboardResponse,
    FarmerDashboardResponse,
    FactoryDashboardResponse,
)
from mock_data import stations_data, alerts_data
import joblib
import pandas as pd

app = FastAPI(title="O2 Gabes API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Initialisation base
init_db()
model = joblib.load("../gabes-ai/model.pkl")


@app.get("/")
def home():
    return {"message": "O2 Gabes API is running"}


@app.get("/test-db")
def test_db():
    try:
        conn = get_db_connection()
        conn.close()
        return {"message": "Database connection successful"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


# =========================
# AUTH
# =========================
@app.post("/register")
def register(user: UserCreate):
    conn = get_db_connection()
    cursor = conn.cursor()

    existing_user = cursor.execute(
        "SELECT * FROM users WHERE email = ?",
        (user.email,)
    ).fetchone()

    if existing_user:
        conn.close()
        raise HTTPException(status_code=400, detail="Email already registered")

    cursor.execute(
        "INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, ?)",
        (user.full_name, user.email, user.password, user.role)
    )

    conn.commit()
    user_id = cursor.lastrowid
    conn.close()

    return {
        "message": "User registered successfully",
        "user": {
            "id": user_id,
            "full_name": user.full_name,
            "email": user.email,
            "role": user.role
        }
    }


@app.post("/login")
def login(user: UserLogin):
    conn = get_db_connection()
    cursor = conn.cursor()

    db_user = cursor.execute(
        "SELECT * FROM users WHERE email = ? AND password = ?",
        (user.email, user.password)
    ).fetchone()

    conn.close()

    if not db_user:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    return {
        "message": "Login successful",
        "user": {
            "id": db_user["id"],
            "full_name": db_user["full_name"],
            "email": db_user["email"],
            "role": db_user["role"]
        }
    }


# =========================
# DASHBOARDS
# =========================
@app.get("/citizen/dashboard", response_model=CitizenDashboardResponse)
def citizen_dashboard():
    return {
        "zone": "Gabes Sud",
        "risk_color": "red",
        "toxic_risk_score": 82,
        "alert_message": "Pic de pollution attendu dans 2h",
        "recommended_actions": [
            "Porter un masque",
            "Fermer les fenêtres",
            "Éviter les sorties inutiles"
        ]
    }


@app.get("/farmer/dashboard", response_model=FarmerDashboardResponse)
def farmer_dashboard():
    return {
        "zone": "Gabes Rural",
        "water_stress_score": 74,
        "agriculture_impact_score": 68,
        "recommendations": [
            "Réduire l’irrigation aujourd’hui",
            "Surveiller l’humidité du sol",
            "Privilégier une culture résistante à la sécheresse"
        ]
    }


@app.get("/factory/dashboard", response_model=FactoryDashboardResponse)
def factory_dashboard():
    return {
        "factory_name": "Factory A",
        "pollution_risk_score": 79,
        "predicted_peak_time": "13:00",
        "recommendations": [
            "Réduire la production de 15%",
            "Optimiser la filtration",
            "Éviter l’activité maximale entre 12h et 14h"
        ]
    }


# =========================
# PREDICTION
# =========================
@app.post("/predict", response_model=PredictResponse)
def predict(data: PredictRequest):
    df = pd.DataFrame([{
        "T2M": data.temperature,
        "RH2M": data.humidity,
        "PS": data.pressure,
        "PRECTOTCORR": data.rain,
        "WS10M": data.wind,
        "WD10M": data.wind_direction,
        "DIST_FACTORY_KM": data.distance_usine,
        "INDUSTRIAL_FACTOR": data.facteur_industriel,
    }])

    pollution_score = float(model.predict(df)[0])

    if pollution_score >= 80:
        risk_level = "danger"
    elif pollution_score >= 50:
        risk_level = "moderate"
    else:
        risk_level = "safe"

    return {
        "pollution_score": round(pollution_score, 2),
        "risk_level": risk_level
    }
@app.get("/predictions")
def get_predictions():
    conn = get_db_connection()
    cursor = conn.cursor()

    rows = cursor.execute(
        "SELECT * FROM predictions ORDER BY id DESC"
    ).fetchall()

    conn.close()

    return [dict(row) for row in rows]


# =========================
# MAP + ALERTS
# =========================
@app.get("/map-data")
def map_data():
    return stations_data


@app.get("/alerts", response_model=List[AlertResponse])
def alerts():
    return alerts_data


# =========================
# REPORTS
# =========================
@app.post("/report")
def report(data: ReportRequest):
    description_lower = data.description.lower()

    if "fumée" in description_lower or "smoke" in description_lower:
        classification = "air_pollution"
    elif "eau" in description_lower or "water" in description_lower:
        classification = "water_pollution"
    elif "odeur" in description_lower or "odor" in description_lower:
        classification = "odor_pollution"
    else:
        classification = "other"

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        INSERT INTO reports (report_type, description, latitude, longitude, classification)
        VALUES (?, ?, ?, ?, ?)
        """,
        (
            data.report_type,
            data.description,
            data.latitude,
            data.longitude,
            classification
        )
    )

    conn.commit()
    report_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Report received successfully",
        "report_id": report_id,
        "classification": classification
    }


@app.get("/reports")
def get_reports():
    conn = get_db_connection()
    cursor = conn.cursor()

    rows = cursor.execute(
        "SELECT * FROM reports ORDER BY id DESC"
    ).fetchall()

    conn.close()

    return [dict(row) for row in rows]