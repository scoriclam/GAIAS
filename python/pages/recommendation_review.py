import streamlit as st


def render(con):
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