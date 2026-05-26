FROM quay.io/astronomer/astro-runtime:12.6.0

# Install uv if you want to use it for dbt management, 
# but for simple dbt-cosmos setup, requirements.txt is usually enough.
# However, if the DAG expects a specific dbt path in .venv, we might need to recreate that.

# The DAG says: dbt_executable_path=f"{DBT_PROJECT_PATH}/.venv/bin/dbt"
# So we SHOULD use uv to create that .venv inside the container.

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

USER astro
WORKDIR /usr/local/airflow

# Copy project files for uv
COPY pyproject.toml uv.lock ./

# Install dependencies into a virtualenv that Cosmos can use
RUN uv sync --frozen --no-dev

# Ensure dbt deps are installed
RUN uv run dbt deps

# Set environment variables for dbt
ENV DBT_PROFILES_DIR=/usr/local/airflow
