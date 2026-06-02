import streamlit as st
import pandas as pd
import joblib
import matplotlib.pyplot as plt
import io
import qrcode

# ======================
# Page config
# ======================
st.set_page_config(page_title="LUAD Prediction System", layout="wide")

# ======================
# Title + Info
# ======================
st.title("🧬 Lung Adenocarcinoma Prediction System")

st.markdown("""
### 👤 Student Information
- Name: 劉康聖  
- University: Chang Jung Christian University  
- Major: Biotechnology  
""")

st.write("---")

# ======================
# Load model
# ======================
model = joblib.load("model.pkl")
scaler = joblib.load("scaler.pkl")

# ======================
# Genes (IMPORTANT: must match model training)
# ======================
genes = ["IDO1", "GJB2", "PTAFR", "BIRC3"]

# ======================
# Input UI
# ======================
st.sidebar.header("Gene Expression Input")

inputs = {}
for g in genes:
    inputs[g] = st.sidebar.number_input(g, value=1.0)

df = pd.DataFrame([inputs])

st.subheader("Input Data")
st.dataframe(df)

# ======================
# Prediction
# ======================
if st.button("Predict Risk"):

    scaled = scaler.transform(df)
    pred = model.predict(scaled)[0]
    prob = model.predict_proba(scaled)[0]

    if pred == 1:
        st.error(f"🔥 High Risk LUAD ({prob[1]*100:.2f}%)")
    else:
        st.success(f"🟢 Low Risk LUAD ({prob[0]*100:.2f}%)")

    # ----------------------
    # Chart 1: Probability
    # ----------------------
    st.subheader("Prediction Probability")

    fig, ax = plt.subplots()
    ax.bar(["Low Risk", "High Risk"], prob)
    ax.set_ylim(0, 1)
    st.pyplot(fig)

    # ----------------------
    # Chart 2: Gene Expression
    # ----------------------
    st.subheader("Gene Expression Levels")

    fig2, ax2 = plt.subplots()
    ax2.bar(df.columns, df.iloc[0])
    ax2.tick_params(axis='x', rotation=45)
    st.pyplot(fig2)

# ======================
# Gene Explanation
# ======================
st.write("---")
st.subheader("🧬 Key Genes Explanation")

st.markdown("""
- **IDO1**：免疫抑制相關基因  
- **GJB2**：細胞間通訊  
- **PTAFR**：發炎與訊號傳遞  
- **BIRC3**：抑制細胞凋亡  
""")

# ======================
# QR Code (FINAL FIXED VERSION)
# ======================
st.write("---")
st.subheader("🔗 Share System QR Code")

# 👉 一定要用 Streamlit Cloud 網址
url = "https://lung-cancer-prediction1-i8ah4bbmitplzlry972vlf.streamlit.app"

qr_img = qrcode.make(url)

buf = io.BytesIO()
qr_img.save(buf, format="PNG")

st.image(buf.getvalue(), caption="Scan to open system")
