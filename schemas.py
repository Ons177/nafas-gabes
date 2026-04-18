from pydantic import BaseModel, EmailStr
from typing import List


class CitizenDashboardResponse(BaseModel):
    zone: str
    risk_color: str
    toxic_risk_score: int
    alert_message: str
    recommended_actions: List[str]


class FarmerDashboardResponse(BaseModel):
    zone: str
    water_stress_score: int
    agriculture_impact_score: int
    recommendations: List[str]


class FactoryDashboardResponse(BaseModel):
    factory_name: str
    pollution_risk_score: int
    predicted_peak_time: str
    recommendations: List[str]


class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    role: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class PredictRequest(BaseModel):
    temperature: float
    humidity: float
    pressure: float
    rain: float
    wind: float
    wind_direction: float
    distance_usine: float
    facteur_industriel: float


class PredictResponse(BaseModel):
    pollution_score: float
    risk_level: str


class ReportRequest(BaseModel):
    report_type: str
    description: str
    latitude: float
    longitude: float


class AlertResponse(BaseModel):
    id: int
    zone: str
    level: str
    message: str