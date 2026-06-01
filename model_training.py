import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier

# 讀資料
df = pd.read_csv("dataset.csv")

# 特徵（你現在真正有的基因）
features = ["IDO1", "GJB2", "PTAFR", "BIRC3"]

X = df[features]   # ❗不能 .values
y = df["status"]   # 0/1分類

# 標準化
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 切資料
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

# 模型
model = RandomForestClassifier(n_estimators=200, random_state=42)
model.fit(X_train, y_train)

# 存檔
joblib.dump(model, "model.pkl")
joblib.dump(scaler, "scaler.pkl")

print("✅ Training complete")