
import os
from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator

AIRFLOW_CRON = os.getenv("AIRFLOW_CRON", "0 * * * *")
INGEST_FILE = os.getenv("INGEST_FILE", "/opt/ingest/telecom_customers.csv")
HASH_SALT = os.getenv("HASH_SALT", "changeme-secret-salt")
PSQL_CONN = os.getenv("PSQL_CONN")

default_args = {"owner": "data-eng", "retries": 0}

with DAG(
    dag_id="sql_elt_pipeline",
    default_args=default_args,
    schedule_interval=AIRFLOW_CRON,
    start_date=datetime(2024,1,1),
    catchup=False,
    tags=["elt","sql"],
) as dag:

    # Set a runtime setting for hash salt (session-local)
    set_salt = PostgresOperator(
        task_id="set_runtime_salt",
        postgres_conn_id=None,
        sql=f"SELECT set_config('app.hash_salt', '{HASH_SALT}', false);",
    )

    init_db = PostgresOperator(
        task_id="init_db",
        postgres_conn_id=None,
        sql="/opt/sql/00_init.sql"
    )

    create_staging = PostgresOperator(
        task_id="create_staging_table",
        postgres_conn_id=None,
        sql="/opt/sql/10_create_staging.sql"
    )

    truncate = PostgresOperator(
        task_id="truncate_staging",
        postgres_conn_id=None,
        sql="TRUNCATE TABLE staging.telecom_raw;"
    )

    load_csv = BashOperator(
        task_id="load_csv",
        bash_command="psql ${PSQL_CONN} -v ON_ERROR_STOP=1 -c "\\copy staging.telecom_raw FROM '${INGEST_FILE}' WITH (FORMAT csv, HEADER true)"",
        env={"PSQL_CONN": PSQL_CONN, "INGEST_FILE": INGEST_FILE}
    )

    transform_clean = PostgresOperator(
        task_id="transform_clean",
        postgres_conn_id=None,
        sql="/opt/sql/20_transform_clean.sql"
    )

    build_dim_fact = PostgresOperator(
        task_id="build_dim_fact",
        postgres_conn_id=None,
        sql="/opt/sql/30_build_dim_fact.sql"
    )

    set_salt >> init_db >> create_staging >> truncate >> load_csv >> transform_clean >> build_dim_fact
