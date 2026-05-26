import os
from datetime import datetime
from pathlib import Path

from airflow import DAG
from cosmos import DbtDag, ExecutionConfig, ProfileConfig, ProjectConfig, RenderConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# The path to the dbt project relative to this DAG file
DBT_PROJECT_PATH = Path(__file__).parent.parent

# Profile configuration for Snowflake
profile_config = ProfileConfig(
    profile_name="etlpipeline",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_default",
        profile_args={
            "database": os.getenv("DBT_SNOWFLAKE_DATABASE", "DBT_DB"),
            "schema": os.getenv("DBT_SNOWFLAKE_SCHEMA", "STAGING"),
        },
    ),
)

# Define different schedules for different tags
# This allows models with specific tags to run at different frequencies
tag_schedules = {
    "raw": "*/30 * * * *",      # Every 30 minutes
    "staging": "0 * * * *",     # Every hour
    "marts": "0 2 * * *",       # Daily at 2 AM
}

for tag, schedule in tag_schedules.items():
    # Dynamically create a DAG for each tag
    dag_id = f"dbt_snowflake_{tag}"
    globals()[dag_id] = DbtDag(
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        operator_args={
            "install_deps": True,
        },
        profile_config=profile_config,
        execution_config=ExecutionConfig(
            dbt_executable_path=f"{DBT_PROJECT_PATH}/.venv/bin/dbt",
        ),
        render_config=RenderConfig(
            select=[f"tag:{tag}"],
        ),
        schedule=schedule,
        start_date=datetime(2024, 1, 1),
        catchup=False,
        dag_id=dag_id,
        tags=["dbt", "snowflake", tag],
    )
