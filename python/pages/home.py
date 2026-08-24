import streamlit as st


def render(con):
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

    col1, col2, col3, col4, col5, col6 = st.columns(6)

    with col1:
        st.metric(
            "Total Games",
            int(summary["total_games"])
        )

    with col2:
        st.metric(
            "Unplayed",
            int(summary["unplayed_games"])
        )

    with col3:
        st.metric(
            "In Progress",
            int(summary["in_progress_games"])
        )

    with col4:
        st.metric(
            "Completed",
            int(summary["completed_games"])
        )

    with col5:
        st.metric(
            "Avg Recommendation",
            f"{recommendation_summary['avg_recommendation_score']:.2f}"
        )

    with col6:
        st.metric(
            "Top Recommendation",
            f"{recommendation_summary['top_recommendation_score']:.2f}"
        )

    st.divider()

    featured_game = con.execute("""
        SELECT
            GameTitle,
            final_recommendation_score,
            recommendation_status,
            playability_status,
            affinity_path
        FROM mart_recommendation_final_v1
        WHERE final_recommendation_score IS NOT NULL
        ORDER BY final_recommendation_score DESC
        LIMIT 1
    """).df().iloc[0]

    st.write("### Featured Recommendation")

    featured_col1, featured_col2, featured_col3, featured_col4 = st.columns(
        [2.5, 1, 1.5, 1.5]
    )

    with featured_col1:
        st.subheader(featured_game["GameTitle"])
        st.caption(featured_game["recommendation_status"])

    with featured_col2:
        st.metric(
            "Score",
            f"{featured_game['final_recommendation_score']:.2f}"
        )

    with featured_col3:
        st.metric(
            "Playability",
            featured_game["playability_status"]
        )

    with featured_col4:
        st.metric(
            "Affinity",
            featured_game["affinity_path"]
        )

    st.divider()

    st.write("### Recommendation Score Distribution")

    score_distribution = con.execute("""
        SELECT
            CASE
                WHEN final_recommendation_score < 10 THEN '0–9'
                WHEN final_recommendation_score < 20 THEN '10–19'
                WHEN final_recommendation_score < 30 THEN '20–29'
                WHEN final_recommendation_score < 40 THEN '30–39'
                WHEN final_recommendation_score < 50 THEN '40–49'
                WHEN final_recommendation_score < 60 THEN '50–59'
                WHEN final_recommendation_score < 70 THEN '60–69'
                WHEN final_recommendation_score < 80 THEN '70–79'
                WHEN final_recommendation_score < 90 THEN '80–89'
                ELSE '90–100'
            END AS score_band,
            COUNT(*) AS games
        FROM mart_recommendation_final_v1
        WHERE final_recommendation_score IS NOT NULL
        GROUP BY score_band
        ORDER BY
            CASE score_band
                WHEN '0–9' THEN 1
                WHEN '10–19' THEN 2
                WHEN '20–29' THEN 3
                WHEN '30–39' THEN 4
                WHEN '40–49' THEN 5
                WHEN '50–59' THEN 6
                WHEN '60–69' THEN 7
                WHEN '70–79' THEN 8
                WHEN '80–89' THEN 9
                WHEN '90–100' THEN 10
            END
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

    top_games_display = top_games.rename(
        columns={
            "GameTitle": "Game",
            "final_recommendation_score": "Recommendation Score",
            "recommendation_status": "Recommendation",
            "playability_status": "Playability"
        }
    )

    st.dataframe(
        top_games_display,
        use_container_width=True,
        hide_index=True,
        column_config={
            "Recommendation Score": st.column_config.ProgressColumn(
                "Recommendation Score",
                min_value=0,
                max_value=100,
                format="%.2f"
            )
        }
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
