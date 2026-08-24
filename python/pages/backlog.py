import streamlit as st


def render(con):
    st.write("## Backlog")

    backlog_df = con.execute("""
        SELECT *
        FROM mart_backlog_analysis
        ORDER BY CuratedUserScore DESC NULLS LAST, GameTitle
    """).df()

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