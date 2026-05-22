# dbt Snowflake ETL Pipeline

This dbt project, named `etlpipeline`, is designed to transform TPC-H sample data and raw payment events into analytics-ready marts within a Snowflake data warehouse.

## Overview

The project follows a standard dbt architecture:
- **Staging**: Clean and standardize raw data from sources.
- **Marts**: Business-ready tables for reporting and analysis.

### Data Sources
- **TPC-H**: Standard industry benchmark data sourced from `snowflake_sample_data`.
- **Raw**: Payment events stored in the `RAW` schema.

### Key Models
- **Staging**:
  - `stg_tpch_orders`: Standardizes TPC-H order data.
  - `stg_tpch_line_items`: Standardizes TPC-H line item data.
  - `stg_payment_events`: Standardizes raw payment event data.
- **Marts**:
  - `int_orders_items`: Intermediate model joining orders and line items.
  - `fct_payments`: Fact table for payment analysis.

## Prerequisites

- **Python 3.12+** (Managed via `uv`)
- **Docker & Docker Compose**
- **Snowflake Account** with appropriate permissions and the `snowflake_sample_data` database available.

## Local Development Setup

### 1. Install `uv`
If you don't have `uv` installed, follow the [installation guide](https://github.com/astral-sh/uv).

### 2. Install Dependencies
```bash
uv sync
```

### 3. Configure Environment Variables
Create a `.env` file in the root directory and populate it with your Snowflake credentials:
```env
DBT_SNOWFLAKE_ACCOUNT=your_account
DBT_SNOWFLAKE_USER=your_user
DBT_SNOWFLAKE_PRIVATE_KEY_PATH=/path/to/your/key.p8
DBT_SNOWFLAKE_ROLE=your_role
DBT_SNOWFLAKE_DATABASE=your_db
DBT_SNOWFLAKE_WAREHOUSE=your_wh
DBT_SNOWFLAKE_SCHEMA=your_schema
```

### 4. Install dbt Packages
```bash
uv run dbt deps
```

### 5. Verify Connection
```bash
uv run dbt debug
```

## Docker Usage

The project is containerized for consistent execution.

### Build and Run Debug
```bash
docker-compose up dbt
```

### Run Models
```bash
docker-compose run dbt uv run dbt run
```

## Running dbt Commands

- **Run all models**: `uv run dbt run`
- **Test models**: `uv run dbt test`
- **Generate documentation**: `uv run dbt docs generate && uv run dbt docs serve`

## Project Structure
- `models/staging/`: Source-aligned models.
- `models/marts/`: Business-aligned models.
- `macros/`: Reusable dbt macros.
- `tests/`: Custom data tests.
