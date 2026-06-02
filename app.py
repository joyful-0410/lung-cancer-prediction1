import streamlit as st
import pandas as pd
import joblib
import matplotlib.pyplot as plt
import qrcode

# ======================
# Page config
# ======================
st.set_page_config(page_title="LUAD Demo System", layout="wide")

# ======================
# Title + Personal Info
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
# 6 genes (fixed version)
# ======================
genes = [
    "IDO1",
    "GJB2",
    "PTAFR",
    "BIRC3"
]

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

    try:
        scaled = scaler.transform(df)

        pred = model.predict(scaled)[0]
        prob = model.predict_proba(scaled)[0]

        # result
        if pred == 1:
            st.error(f"🔥 High Risk LUAD ({prob[1]*100:.2f}%)")
        else:
            st.success(f"🟢 Low Risk LUAD ({prob[0]*100:.2f}%)")

        # ======================
        # Chart 1: Probability
        # ======================
        st.subheader("Prediction Probability")

        fig, ax = plt.subplots()
        ax.bar(["Low Risk", "High Risk"], prob)
        ax.set_ylim(0, 1)
        st.pyplot(fig)

        # ======================
        # Chart 2: Gene Expression
        # ======================
        st.subheader("Gene Expression Levels")

        fig2, ax2 = plt.subplots()
        ax2.bar(df.columns, df.iloc[0])
        ax2.tick_params(axis='x', rotation=45)
        st.pyplot(fig2)

    except Exception as e:
        st.error("❌ Prediction Error")
        st.exception(e)

# ======================
# Gene explanation
# ======================
st.write("---")
st.subheader("🧬 Key Genes Explanation")

st.markdown("""
- **IDO1**：參與免疫抑制，可影響腫瘤逃避免疫系統  
- **GJB2**：細胞間通訊相關基因，與腫瘤傳播有關  
- **PTAFR**：參與發炎與細胞訊號傳遞  
- **BIRC3**：抑制細胞凋亡，與腫瘤存活相關  
""")

# ======================
# QR Code (safe version)
# ======================
st.write("---")
st.subheader("🔗 Share System QR Code")

url = "http://localhost:8502"

import io
import qrcode

st.write("---")
st.subheader("🔗 Share System QR Code")

url = "http://172.xxx.xxx.xxx:8502"

qr_img = qrcode.make(url)

buf = io.BytesIO()
qr_img.save(buf, format="PNG")
byte_im = buf.getvalue()

st.image(byte_im)