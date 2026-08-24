import duckdb


def get_connection():
    return duckdb.connect(
        "gaias.duckdb",
        read_only=True
    )