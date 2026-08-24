import streamlit as st
import duckdb

st.set_page_config(
    page_title="GAIAS",
    layout="wide"
)

st.title("GAIAS")
st.subheader("Game Assessment, Inventory, and Analytics System")
st.sidebar.title("GAIAS")
st.sidebar.caption("Game Assessment, Inventory, and Analytics System")

page = st.sidebar.radio(
    "Navigation",
    [
        "Home",
        "Discovery",
        "Play Next",
        "Backlog",
        "Recommendation Review"
    ]
)

con = duckdb.connect("gaias.duckdb", read_only=True)

if page == "Home":
    st.write("## Dashboard")

    summary = con.execute("""
        SELECT
            COUNT(DISTINCT GameID) AS total_games,
            SUM(CASE WHEN PlayStatusName = 'Unplayed' THEN 1 ELSE 0 END) AS unplayed_games,
            SUM(CASE WHEN PlayStatusName = 'In Progress' THEN 1 ELSE 0 END) AS in_progress_games,
            SUM(CASE WHEN PlayStatusName = 'Completed' THEN 1 ELSE 0 END) AS completed_games
        FROM mart_backlog_analysis
    """).df().iloc[0]

    recommendation_summary = con.execute("""
        SELECT
            AVG(final_recommendation_score) AS avg_recommendation_score,
            MAX(final_recommendation_score) AS top_recommendation_score
        FROM mart_recommendation_final_v1
    """).df().iloc[0]

    col1, col2, col3, col4 = st.columns(4)

    with col1:
        st.metric("Total Games", int(summary["total_games"]))

    with col2:
        st.metric("Unplayed", int(summary["unplayed_games"]))

    with col3:
        st.metric("In Progress", int(summary["in_progress_games"]))

    with col4:
        st.metric("Completed", int(summary["completed_games"]))

    st.divider()

    col5, col6 = st.columns(2)

    with col5:
        st.metric(
            "Average Recommendation Score",
            f"{recommendation_summary['avg_recommendation_score']:.2f}"
        )

    with col6:
        st.metric(
            "Top Recommendation Score",
            f"{recommendation_summary['top_recommendation_score']:.2f}"
        )

    st.divider()

    st.write("### Recommendation Score Distribution")

    score_distribution = con.execute("""
        SELECT
            ROUND(final_recommendation_score, 1) AS score_band,
            COUNT(*) AS games
        FROM mart_recommendation_final_v1
        WHERE final_recommendation_score IS NOT NULL
        GROUP BY 1
        ORDER BY 1
    """).df()

    st.bar_chart(
        score_distribution,
        x="score_band",
        y="games"
    )

    st.divider()

    st.write("### Top 10 Recommended Games")

    top_games = con.execute("""
        SELECT
            GameTitle,
            final_recommendation_score,
            recommendation_status,
            playability_status
        FROM mart_recommendation_final_v1
        ORDER BY final_recommendation_score DESC
        LIMIT 10
    """).df()

    st.dataframe(
        top_games,
        use_container_width=True,
        hide_index=True
    )

    st.divider()

    st.write("### Suggested Next Actions")

    col9, col10, col11 = st.columns(3)

    with col9:
        st.info(
            "Use Discovery to search and filter the full game inventory."
        )

    with col10:
        st.info(
            "Use Play Next to review the strongest candidates for your next game."
        )

    with col11:
        st.info(
            "Use Recommendation Review to understand why games received their scores."
        )

    st.write("### Application Areas")

    col7, col8 = st.columns(2)

    with col7:
        st.markdown("""
        **Discovery**  
        Search and filter the game inventory.

        **Play Next**  
        Review the strongest candidates for what to play next.
        """)

    with col8:
        st.markdown("""
        **Backlog**  
        Analyze unplayed, in-progress, and completed games.

        **Recommendation Review**  
        Inspect recommendation scores and scoring context.
        """)

elif page == "Discovery":
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

    discovery_display = df[
        [
            "GameTitle",
            "PlayStatusName",
            "final_recommendation_score",
            "recommendation_status",
            "playability_status",
            "recommendation_context"
        ]
    ].copy()

    discovery_display = discovery_display.rename(
        columns={
            "GameTitle": "Game",
            "PlayStatusName": "Play Status",
            "final_recommendation_score": "Recommendation Score",
            "recommendation_status": "Recommendation",
            "playability_status": "Playability",
            "recommendation_context": "Why"
        }
    )

    st.dataframe(
        discovery_display,
        use_container_width=True,
        hide_index=True,
        column_config={
            "Recommendation Score": st.column_config.NumberColumn(
                format="%.2f"
            )
        }
    )

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

elif page == "Play Next":
    st.write("## Play Next")

    play_next_df = con.execute("""
        SELECT *
        FROM mart_play_next_v2
        ORDER BY final_recommendation_score DESC
        LIMIT 50
    """).df()

    if not play_next_df.empty:
        top_game = play_next_df.iloc[0]

        st.write("### Top Recommendation")

        col1, col2, col3 = st.columns(3)

        with col1:
            st.metric(
                "Game",
                top_game["GameTitle"]
            )

        with col2:
            st.metric(
                "Recommendation Score",
                f"{top_game['final_recommendation_score']:.2f}"
            )

        with col3:
            st.metric(
                "Playability",
                top_game["playability_status"]
            )

        st.divider()

        st.write("### Ranked Play Next List")
    st.caption(f"{len(play_next_df)} games shown")

    play_next_display = play_next_df[
        [
            "GameTitle",
            "final_recommendation_score",
            "playability_status",
            "recommendation_status",
            "recommendation_context"
        ]
    ].copy()

    play_next_display = play_next_display.rename(
        columns={
            "GameTitle": "Game",
            "final_recommendation_score": "Recommendation Score",
            "playability_status": "Playability",
            "recommendation_status": "Recommendation",
            "recommendation_context": "Why"
        }
    )

    st.dataframe(
        play_next_display,
        use_container_width=True,
        hide_index=True,
        column_config={
            "Recommendation Score": st.column_config.NumberColumn(
                format="%.2f"
            )
        }
    )

elif page == "Backlog":
    st.write("## Backlog")

    backlog_df = con.execute("""
        SELECT *
        FROM mart_backlog_analysis
        ORDER BY CuratedUserScore DESC NULLS LAST, GameTitle
    """).df()

    # Summary metrics
    total_games = len(backlog_df)
    unplayed_games = int(backlog_df["UnplayedCount"].sum())
    in_progress_games = int(backlog_df["InProgressCount"].sum())
    completed_games = int(backlog_df["CompletedCount"].sum())

    col1, col2, col3, col4 = st.columns(4)

    with col1:
        st.metric("Games in Analysis", total_games)

    with col2:
        st.metric("Unplayed", unplayed_games)

    with col3:
        st.metric("In Progress", in_progress_games)

    with col4:
        st.metric("Completed", completed_games)

    st.divider()

    # Play-status distribution
    st.write("### Backlog by Play Status")

    status_summary = (
        backlog_df.groupby("PlayStatusName")
        .size()
        .reset_index(name="Games")
    )

    st.bar_chart(
        status_summary,
        x="PlayStatusName",
        y="Games"
    )

    st.divider()

        # Largest time commitments
    st.write("### Largest Time Commitments")

    longest_games = (
        backlog_df[
            [
                "GameTitle",
                "PlayStatusName",
                "CompletionHours",
                "DifficultyScore",
                "CuratedUserScore"
            ]
        ]
        .sort_values(
            "CompletionHours",
            ascending=False,
            na_position="last"
        )
        .head(10)
    )

    longest_games_display = longest_games.rename(
        columns={
            "GameTitle": "Game",
            "PlayStatusName": "Play Status",
            "CompletionHours": "Completion Hours",
            "DifficultyScore": "Difficulty",
            "CuratedUserScore": "User Score"
        }
    )

    st.dataframe(
        longest_games_display,
        use_container_width=True,
        hide_index=True,
        column_config={
            "Completion Hours": st.column_config.NumberColumn(
                format="%.1f"
            ),
            "Difficulty": st.column_config.NumberColumn(
                format="%.2f"
            ),
            "User Score": st.column_config.NumberColumn(
                format="%.2f"
            )
        }
    )

    st.divider()

    # Full backlog
    st.write("### Full Backlog")

    st.caption(f"{len(backlog_df)} games shown")

    backlog_display = backlog_df[
        [
            "GameTitle",
            "PlayStatusName",
            "CompletionHours",
            "DifficultyScore",
            "PersonalRating",
            "CuratedUserScore",
            "LastPlayedDate"
        ]
    ].copy()

    backlog_display = backlog_display.rename(
        columns={
            "GameTitle": "Game",
            "PlayStatusName": "Play Status",
            "CompletionHours": "Completion Hours",
            "DifficultyScore": "Difficulty",
            "PersonalRating": "Personal Rating",
            "CuratedUserScore": "User Score",
            "LastPlayedDate": "Last Played"
        }
    )

    st.dataframe(
        backlog_display,
        use_container_width=True,
        hide_index=True
    )

elif page == "Recommendation Review":
    st.write("## Recommendation Review")

    recommendation_df = con.execute("""
        SELECT
            f.GameTitle,
            f.PlayStatusName,
            f.taste_affinity_score,
            f.conditional_affinity_percentile,
            f.affinity_path,
            f.playability_status,
            f.playability_adjustment,
            f.hard_exclusion_flag,
            f.exclusion_reason,
            f.avg_quality_rating,
            f.quality_percentile,
            f.quality_coverage_status,
            f.quality_adjustment,
            f.affinity_playability_score,
            f.final_recommendation_score,
            f.recommendation_status,
            c.recommendation_context
        FROM mart_recommendation_final_v1 f
        LEFT JOIN mart_recommendation_context_v1 c
            ON f.GameKey = c.GameKey
        ORDER BY f.final_recommendation_score DESC
    """).df()

    st.caption(f"{len(recommendation_df)} games evaluated")

    search_recommendation = st.text_input(
        "Search recommendation results",
        placeholder="Type part of a game title..."
    )

    if search_recommendation:
        filtered_df = recommendation_df[
            recommendation_df["GameTitle"]
            .str.contains(
                search_recommendation,
                case=False,
                na=False
            )
        ]
    else:
        filtered_df = recommendation_df

        st.write("### Ranked Recommendations")

    recommendation_display = filtered_df[
        [
            "GameTitle",
            "final_recommendation_score",
            "recommendation_status",
            "playability_status",
            "affinity_path"
        ]
    ].copy()

    recommendation_display = recommendation_display.rename(
        columns={
            "GameTitle": "Game",
            "final_recommendation_score": "Final Score",
            "recommendation_status": "Recommendation",
            "playability_status": "Playability",
            "affinity_path": "Affinity Path"
        }
    )

    st.dataframe(
        recommendation_display,
        use_container_width=True,
        hide_index=True,
        column_config={
            "Final Score": st.column_config.NumberColumn(
                format="%.2f"
            )
        }
    )

    st.divider()

    if not filtered_df.empty:
        st.write("### Recommendation Details")

        selected_recommendation_game = st.selectbox(
            "Select a game to review",
            filtered_df["GameTitle"].tolist()
        )

        game = filtered_df[
            filtered_df["GameTitle"] == selected_recommendation_game
        ].iloc[0]

        col1, col2, col3, col4 = st.columns(4)

        with col1:
            st.metric(
                "Final Score",
                f"{game['final_recommendation_score']:.2f}"
            )

        with col2:
            st.metric(
                "Taste Affinity",
                f"{game['taste_affinity_score']:.2f}"
            )

        with col3:
            st.metric(
                "Quality",
                (
                    f"{game['avg_quality_rating']:.2f}"
                    if game["avg_quality_rating"] is not None
                    else "Unknown"
                )
            )

        with col4:
            st.metric(
                "Playability",
                game["playability_status"]
            )

        st.write("**Recommendation Status**")
        st.write(game["recommendation_status"])

        st.write("**Affinity Path**")
        st.write(game["affinity_path"])

        st.write("**Recommendation Context**")
        st.write(game["recommendation_context"])

        if game["hard_exclusion_flag"]:
            st.warning(
                f"Hard exclusion: {game['exclusion_reason']}"
            )

        with st.expander("Scoring Details"):
            st.write(
                f"Conditional affinity percentile: "
                f"{game['conditional_affinity_percentile']}"
            )

            st.write(
                f"Playability adjustment: "
                f"{game['playability_adjustment']}"
            )

            st.write(
                f"Quality percentile: "
                f"{game['quality_percentile']}"
            )

            st.write(
                f"Quality coverage: "
                f"{game['quality_coverage_status']}"
            )

            st.write(
                f"Quality adjustment: "
                f"{game['quality_adjustment']}"
            )

            st.write(
                f"Affinity + playability score: "
                f"{game['affinity_playability_score']}"
            )
con.close()