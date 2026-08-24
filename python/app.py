import streamlit as st
from pages import home
from pages import discovery
from pages import play_next
from pages import backlog
from pages import recommendation_review
from utils.database import get_connection

st.set_page_config(
    page_title="GAIAS",
    layout="wide"
)

st.markdown(
    """
    <style>
        .block-container {
            padding-top: 2rem;
            padding-bottom: 2rem;
            padding-left: 3rem;
            padding-right: 3rem;
            max-width: 1600px;
        }

        [data-testid="stSidebar"] {
            min-width: 250px;
            max-width: 250px;
        }

        [data-testid="stMetric"] {
            padding: 0.75rem 0.5rem;
        }

        h1 {
            margin-bottom: 0.25rem;
        }

        h2, h3 {
            margin-top: 1rem;
            margin-bottom: 0.5rem;
        }

    [data-testid="stSidebar"] .stRadio > div {
    gap: 0.25rem;
}

[data-testid="stSidebar"] label {
    padding: 0.35rem 0;
}

[data-testid="stSidebar"] hr {
    margin-top: 0.75rem;
    margin-bottom: 0.75rem;
}
    </style>
    """,
    unsafe_allow_html=True
)

st.sidebar.markdown("## GAIAS")
st.sidebar.caption("Game Assessment, Inventory, and Analytics System")
st.sidebar.divider()

page = st.sidebar.radio(
    "Go to",
    [
        "Home",
        "Discovery",
        "Play Next",
        "Backlog",
        "Recommendation Review"
    ],
    label_visibility="collapsed"
)

con = get_connection()

if page == "Home":
    home.render(con)

elif page == "Discovery":
    discovery.render(con)

elif page == "Play Next":
    play_next.render(con)

elif page == "Backlog":
    backlog.render(con)

elif page == "Recommendation Review":
    recommendation_review.render(con)

con.close()