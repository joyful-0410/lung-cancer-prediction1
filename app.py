import streamlit as st
import pandas as pd
import joblib

st.set_page_config(page_title="LUAD Prediction", layout="wide")

st.title("🧬 Lung Adenocarcinoma Risk Prediction System")
st.write("利用基因表達資料預測肺腺癌高風險 / 低風險分類")


@st.cache_resource
def load_model():
    return joblib.load("model.pkl")

@st.cache_resource
def load_scaler():
    return joblib.load("scaler.pkl")

model = load_model()
scaler = load_scaler()


genes = [
    "SLC34A2","MUC16","ANLN","CDC20","KIF20A",
    "TOP2A","MKI67","BIRC5","TYMS","CCNA2"
]

st.sidebar.header("輸入基因表現值")

inputs = {}
for g in genes:
    inputs[g] = st.sidebar.number_input(g, value=1.0)

df = pd.DataFrame([[inputs[g] for g in genes]], columns=genes)

st.subheader("輸入資料")
st.dataframe(df)

if st.button("Predict Risk"):
    scaled = scaler.transform(df)
    pred = model.predict(scaled)[0]
    prob = model.predict_proba(scaled)[0]

    if pred == 1:
        st.error(f"High Risk LUAD ({prob[1]*100:.2f}%)")
    else:
        st.success(f"Low Risk LUAD ({prob[0]*100:.2f}%)")

    st.subheader("關鍵基因")
    st.markdown("""
- MKI67：細胞增殖標記
- BIRC5：抑制細胞凋亡
- TOP2A：DNA複製相關
- CDC20：細胞週期調控
""")

