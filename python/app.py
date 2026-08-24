import streamlit as st
import duckdb

st.set_page_config(
    page_title="GAIAS",
    layout="wide"
)

st.title("GAIAS")
st.subheader("Game Assessment, Inventory, and Analytics System")

con = duckdb.connect("gaias.duckdb", read_only=True)

# Load filter values directly from the database
play_statuses = con.execute("""
    SELECT DISTINCT PlayStatusName
    FROM mart_game_discovery_v1
    WHERE PlayStatusName IS NOT NULL
    ORDER BY PlayStatusName
""").fetchall()

playability_statuses = con.execute("""
    SELECT DISTINCT playability_status
    FROM mart_game_discovery_v1
    WHERE playability_status IS NOT NULL
    ORDER BY playability_status
""").fetchall()

recommendation_statuses = con.execute("""
    SELECT DISTINCT recommendation_status
    FROM mart_game_discovery_v1
    WHERE recommendation_status IS NOT NULL
    ORDER BY recommendation_status
""").fetchall()

play_statuses = [row[0] for row in play_statuses]
playability_statuses = [row[0] for row in playability_statuses]
recommendation_statuses = [row[0] for row in recommendation_statuses]

# Sidebar filters
st.sidebar.header("Filters")

selected_play_status = st.sidebar.multiselect(
    "Play Status",
    play_statuses
)

selected_playability = st.sidebar.multiselect(
    "Playability",
    playability_statuses
)

selected_recommendation = st.sidebar.multiselect(
    "Recommendation Status",
    recommendation_statuses
)

# Title search
search_title = st.text_input(
    "Search by game title",
    placeholder="Type part of a game title..."
)

query = """
    SELECT *
    FROM mart_game_discovery_v1
    WHERE 1 = 1
"""

params = []

if search_title:
    query += " AND lower(GameTitle) LIKE lower(?)"
    params.append(f"%{search_title}%")

if selected_play_status:
    placeholders = ",".join(["?"] * len(selected_play_status))
    query += f" AND PlayStatusName IN ({placeholders})"
    params.extend(selected_play_status)

if selected_playability:
    placeholders = ",".join(["?"] * len(selected_playability))
    query += f" AND playability_status IN ({placeholders})"
    params.extend(selected_playability)

if selected_recommendation:
    placeholders = ",".join(["?"] * len(selected_recommendation))
    query += f" AND recommendation_status IN ({placeholders})"
    params.extend(selected_recommendation)

query += """
    ORDER BY final_recommendation_score DESC
    LIMIT 100
"""

df = con.execute(query, params).df()

st.write("### Game Discovery")
st.caption(f"{len(df)} games shown")

st.dataframe(
    df,
    use_container_width=True,
    hide_index=True
)

st.divider()

if not df.empty:
    st.write("### Game Details")

    selected_game = st.selectbox(
        "Select a game",
        df["GameTitle"].tolist()
    )

    game = df[df["GameTitle"] == selected_game].iloc[0]

    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric(
            "Recommendation Score",
            f"{game['final_recommendation_score']:.2f}"
        )

    with col2:
        st.metric(
            "Play Status",
            game["PlayStatusName"]
        )

    with col3:
        st.metric(
            "Playability",
            game["playability_status"]
        )

    st.write("**Recommendation Status**")
    st.write(game["recommendation_status"])

    st.write("**Recommendation Context**")
    st.write(game["recommendation_context"])

con.close()