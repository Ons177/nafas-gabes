import os
import uuid
import joblib
import pandas as pd

from typing import List
from pydantic import BaseModel
from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from database import get_db_connection, init_db
from schemas import (
    UserCreate,
    UserLogin,
    ReportRequest,
    AlertResponse,
    CitizenDashboardResponse,
    FarmerDashboardResponse,
    FactoryDashboardResponse,
)
from mock_data import stations_data, alerts_data

app = FastAPI(title="O2 Gabes API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

SYMPTOM_ENCODER_PATH = "symptom_encoder.pkl"
INDUSTRIAL_MODEL_PATH = "model_aqi.pkl"

try:
    symptom_encoder = joblib.load(SYMPTOM_ENCODER_PATH)
    print("✅ symptom_encoder.pkl chargé avec succès")
except Exception as e:
    symptom_encoder = None
    print(f"⚠️ Impossible de charger symptom_encoder.pkl : {e}")

try:
    industrial_model = joblib.load(INDUSTRIAL_MODEL_PATH)
    print("✅ model_aqi.pkl chargé avec succès")
except Exception as e:
    industrial_model = None
    print(f"⚠️ Impossible de charger model_aqi.pkl : {e}")

init_db()


class IndustrialPredictRequest(BaseModel):
    wind_speed: float
    wind_direction: float
    humidity: float
    temperature: float
    pressure: float
    rain: float
    factory_activity: float
    residential_proximity: float
    pm25: float
    pm10: float
    no2: float
    so2: float
    CO: float
    o3: float
    hour: int
    month: int


class IndustrialPredictResponse(BaseModel):
    pollution_score: float
    risk_level: str


def init_social_tables():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS social_posts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_full_name TEXT NOT NULL,
            post_type TEXT NOT NULL,
            description TEXT NOT NULL,
            image_url TEXT DEFAULT '',
            location_name TEXT DEFAULT 'Gabès',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS social_reactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            post_id INTEGER NOT NULL,
            user_full_name TEXT NOT NULL,
            reaction_type TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    conn.close()


init_social_tables()


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


@app.post("/register")
def register(user: UserCreate):
    conn = get_db_connection()
    cursor = conn.cursor()

    existing = cursor.execute(
        "SELECT * FROM users WHERE email = ?", (user.email,)
    ).fetchone()

    if existing:
        conn.close()
        raise HTTPException(status_code=400, detail="Email already registered")

    cursor.execute(
        """
        INSERT INTO users (full_name, email, password, role)
        VALUES (?, ?, ?, ?)
        """,
        (user.full_name, user.email, user.password, user.role),
    )

    conn.commit()
    conn.close()

    return {
        "message": "User registered successfully",
        "email": user.email,
        "role": user.role,
    }


@app.post("/login")
def login(user: UserLogin):
    conn = get_db_connection()
    cursor = conn.cursor()

    db_user = cursor.execute(
        "SELECT * FROM users WHERE email = ? AND password = ?",
        (user.email, user.password),
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
            "role": db_user["role"] if "role" in db_user.keys() else "citizen",
        },
    }


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
            "Éviter les sorties inutiles",
        ],
    }


@app.get("/farmer/dashboard", response_model=FarmerDashboardResponse)
def farmer_dashboard():
    return {
        "zone": "Gabes Rural",
        "water_stress_score": 74,
        "agriculture_impact_score": 68,
        "recommendations": [
            "Réduire l'irrigation aujourd'hui",
            "Surveiller l'humidité du sol",
            "Privilégier une culture résistante à la sécheresse",
        ],
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
            "Éviter l'activité maximale entre 12h et 14h",
        ],
    }


@app.post("/predict", response_model=IndustrialPredictResponse)
def predict(data: IndustrialPredictRequest):
    if industrial_model is None:
        raise HTTPException(status_code=500, detail="Modèle industriel non chargé")

    try:
        features = pd.DataFrame([{
            "wind_speed": data.wind_speed,
            "wind_direction": data.wind_direction,
            "humidity": data.humidity,
            "temperature": data.temperature,
            "pressure": data.pressure,
            "rain": data.rain,
            "factory_activity": data.factory_activity,
            "residential_proximity": data.residential_proximity,
            "pm25": data.pm25,
            "pm10": data.pm10,
            "no2": data.no2,
            "so2": data.so2,
            "CO": data.CO,
            "o3": data.o3,
            "hour": data.hour,
            "month": data.month,
        }])

        prediction = industrial_model.predict(features)[0]
        pred_text = str(prediction).strip().lower()

        if pred_text in ["faible", "low", "safe", "0"]:
            pollution_score = 25.0
            risk_level = "safe"
        elif pred_text in ["moyen", "medium", "moderate", "1"]:
            pollution_score = 60.0
            risk_level = "moderate"
        else:
            pollution_score = 85.0
            risk_level = "danger"

        return {
            "pollution_score": pollution_score,
            "risk_level": risk_level,
        }

    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Erreur prédiction industrielle: {str(e)}"
        )


@app.get("/predictions")
def get_predictions():
    conn = get_db_connection()
    rows = conn.cursor().execute(
        "SELECT * FROM predictions ORDER BY id DESC"
    ).fetchall()
    conn.close()
    return [dict(row) for row in rows]


@app.get("/map-data")
def map_data():
    return stations_data


@app.get("/alerts", response_model=List[AlertResponse])
def get_alerts():
    return alerts_data


@app.post("/report")
def report(data: ReportRequest):
    desc_lower = data.description.lower()

    if "fumée" in desc_lower or "smoke" in desc_lower:
        classification = "air_pollution"
    elif "eau" in desc_lower or "water" in desc_lower:
        classification = "water_pollution"
    elif "odeur" in desc_lower or "odor" in desc_lower:
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
            classification,
        ),
    )
    conn.commit()
    report_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Report received successfully",
        "report_id": report_id,
        "classification": classification,
    }


@app.post("/report/image")
async def report_with_image(
    report_type: str = Form(...),
    description: str = Form(""),
    latitude: float = Form(33.8833),
    longitude: float = Form(10.0982),
    image: UploadFile = File(...),
):
    ext = os.path.splitext(image.filename or "photo.jpg")[1] or ".jpg"
    filename = f"{uuid.uuid4().hex}{ext}"
    filepath = os.path.join(UPLOAD_DIR, filename)

    contents = await image.read()
    with open(filepath, "wb") as f:
        f.write(contents)

    image_url = f"uploads/{filename}"
    desc_lower = description.lower()
    rt_lower = report_type.lower()

    if "fumée" in desc_lower or "fumée" in rt_lower or "industrielle" in rt_lower:
        classification = "air_pollution"
    elif "eau" in desc_lower or "eau" in rt_lower or "contaminée" in rt_lower:
        classification = "water_pollution"
    elif "odeur" in desc_lower or "odeur" in rt_lower:
        classification = "odor_pollution"
    elif "déchet" in desc_lower or "déchet" in rt_lower:
        classification = "waste_pollution"
    else:
        classification = "other"

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            INSERT INTO reports (report_type, description, latitude, longitude, classification, image_url)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (report_type, description, latitude, longitude, classification, image_url),
        )
    except Exception:
        try:
            cursor.execute("ALTER TABLE reports ADD COLUMN image_url TEXT DEFAULT ''")
            conn.commit()
        except Exception:
            pass

        cursor.execute(
            """
            INSERT INTO reports (report_type, description, latitude, longitude, classification, image_url)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (report_type, description, latitude, longitude, classification, image_url),
        )

    conn.commit()
    report_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Report received successfully",
        "report_id": report_id,
        "classification": classification,
        "image_url": image_url,
    }


@app.get("/reports")
def get_reports():
    conn = get_db_connection()
    rows = conn.cursor().execute("SELECT * FROM reports ORDER BY id DESC").fetchall()
    conn.close()
    return [dict(row) for row in rows]


@app.post("/social-posts")
async def create_social_post(
    user_full_name: str = Form(...),
    post_type: str = Form(...),
    description: str = Form(...),
    location_name: str = Form("Gabès"),
    image: UploadFile | None = File(None),
):
    image_url = ""

    if image is not None:
        ext = os.path.splitext(image.filename or "post.jpg")[1] or ".jpg"
        filename = f"{uuid.uuid4().hex}{ext}"
        filepath = os.path.join(UPLOAD_DIR, filename)

        contents = await image.read()
        with open(filepath, "wb") as f:
            f.write(contents)

        image_url = f"uploads/{filename}"

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        INSERT INTO social_posts (user_full_name, post_type, description, image_url, location_name)
        VALUES (?, ?, ?, ?, ?)
        """,
        (user_full_name, post_type, description, image_url, location_name),
    )

    conn.commit()
    post_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Social post created successfully",
        "post_id": post_id,
        "image_url": image_url,
    }


@app.get("/social-posts")
def get_social_posts():
    conn = get_db_connection()
    cursor = conn.cursor()

    posts = cursor.execute(
        """
        SELECT * FROM social_posts
        ORDER BY id DESC
        """
    ).fetchall()

    result = []
    for row in posts:
        post_id = row["id"]

        confirms = cursor.execute(
            "SELECT COUNT(*) AS c FROM social_reactions WHERE post_id = ? AND reaction_type = 'confirm'",
            (post_id,),
        ).fetchone()["c"]

        urgents = cursor.execute(
            "SELECT COUNT(*) AS c FROM social_reactions WHERE post_id = ? AND reaction_type = 'urgent'",
            (post_id,),
        ).fetchone()["c"]

        result.append({
            "id": row["id"],
            "user_full_name": row["user_full_name"],
            "post_type": row["post_type"],
            "description": row["description"],
            "image_url": row["image_url"],
            "location_name": row["location_name"],
            "created_at": row["created_at"],
            "confirms_count": confirms,
            "urgents_count": urgents,
        })

    conn.close()
    return result


@app.post("/social-posts/{post_id}/react")
def react_to_post(post_id: int, payload: dict):
    reaction_type = payload.get("reaction_type", "")
    user_full_name = payload.get("user_full_name", "Citoyen")

    if reaction_type not in ["confirm", "urgent"]:
        raise HTTPException(status_code=400, detail="Invalid reaction type")

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        INSERT INTO social_reactions (post_id, user_full_name, reaction_type)
        VALUES (?, ?, ?)
        """,
        (post_id, user_full_name, reaction_type),
    )

    conn.commit()
    conn.close()

    return {"message": "Reaction added successfully"}


@app.post("/health-advice")
def health_advice(payload: dict):
    symptoms = payload.get("symptoms", [])

    if not symptoms:
        raise HTTPException(status_code=400, detail="No symptoms provided")

    symptoms_lower = [str(s).lower() for s in symptoms]
    encoded_symptoms = symptoms

    if symptom_encoder is not None:
        try:
            encoded_symptoms = symptom_encoder.transform(symptoms).tolist()
        except Exception:
            encoded_symptoms = symptoms

    if "essoufflement" in symptoms_lower or "vertiges" in symptoms_lower:
        risk_level = "élevé"
        advice = [
            "Évitez immédiatement les zones exposées à la pollution.",
            "Portez un masque si vous devez sortir.",
            "Restez dans un endroit aéré et sûr.",
            "Consultez rapidement si la gêne respiratoire s’aggrave.",
        ]
    elif (
        "toux" in symptoms_lower
        or "irritation des yeux" in symptoms_lower
        or "irritation de la gorge" in symptoms_lower
    ):
        risk_level = "modéré"
        advice = [
            "Limitez l’exposition extérieure pendant quelques heures.",
            "Fermez les fenêtres si une odeur ou une fumée est présente dehors.",
            "Hydratez-vous régulièrement.",
            "Surveillez l’évolution des symptômes.",
        ]
    elif (
        "maux de tête" in symptoms_lower
        or "fatigue" in symptoms_lower
        or "nausée" in symptoms_lower
    ):
        risk_level = "modéré"
        advice = [
            "Éloignez-vous temporairement de la zone suspecte.",
            "Reposez-vous dans un environnement calme et aéré.",
            "Buvez de l’eau.",
            "Signalez la situation si d’autres personnes ressentent la même chose.",
        ]
    else:
        risk_level = "faible"
        advice = [
            "Restez vigilant et observez l’évolution de vos symptômes.",
            "Évitez les zones à forte pollution si possible.",
            "Signalez toute aggravation dans l’application.",
        ]

    return {
        "risk_level": risk_level,
        "advice": advice,
        "encoded_symptoms": encoded_symptoms,
    }