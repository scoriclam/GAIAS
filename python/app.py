import streamlit as st
import duckdb

st.set_page_config(
    page_title="GAIAS",
    layout="wide"
)

st.title("GAIAS")
st.subheader("Game Assessment, Inventory, and Analytics System")

con = duckdb.connect("gaias.duckdb", read_only=True)

df = con.execute("""
    SELECT *
    FROM mart_game_discovery_v1
    LIMIT 50
""").df()

st.write("### Game Discovery Preview")
st.dataframe(df, use_container_width=True)

con.close()
