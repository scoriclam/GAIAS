import streamlit as st


def render(con):
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