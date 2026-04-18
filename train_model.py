import pandas as pd
import joblib
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error

df = pd.read_csv("data/air_quality.csv")
df = df.dropna()

# Ici la cible doit déjà exister dans le dataset
# Exemple : PollutionScore
X = df[[
    "temperature",
    "humidity",
    "wind",
    "rain",
    "distance_usine",
    "facteur_industriel"
]]

y = df["pollution_score"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

preds = model.predict(X_test)
mae = mean_absolute_error(y_test, preds)

print("MAE:", mae)

joblib.dump(model, "model.pkl")
print("Model saved in model.pkl")