# Telecom Customer Churn ELT (SQL-First)

This project is an **open-source ELT pipeline** that ingests a CSV dataset (e.g., [Telecom Customer Churn](https://www.kaggle.com/datasets/abdullah0a/telecom-customer-churn-insights-for-analysis)), stages it in Postgres, cleans and anonymizes sensitive data with **SQL transformations**, and makes the processed data available for reporting in **Metabase**.  

The pipeline is orchestrated with **Apache Airflow** and runs fully containerized with **Docker Compose**, making it easy to run locally on a laptop.  

---

## Features
- **Ingestion**: Loads a CSV into Postgres staging tables every hour (configurable).  
- **Transformation (SQL-only)**:
  - Handles **missing values** with defaults using `COALESCE`.  
  - **Anonymizes PII** (`customerID`) using salted SHA-256 via Postgres `pgcrypto`.  
- **Data Warehouse Layer**: Creates `dim_customers` (anonymized customer dimension) and `fact_churn_signals` (churn metrics).  
- **Reporting**: Metabase connected to Postgres for analytics dashboards.  
- **Open-source stack**: Postgres, Airflow, Metabase, Docker.  

---

## Architecture
```
CSV → Staging (Postgres) → Transform (SQL) → Analytics DB → Metabase Dashboard
                ^                      |
                |                      v
              Airflow (orchestration & scheduling)
```

---

## Tech Stack
- **Database**: Postgres  
- **Orchestration**: Apache Airflow  
- **Reporting**: Metabase  
- **Containers**: Docker Compose  
- **Scripts**: SQL only (no Python logic in pipeline)  

---

## Project Structure
```
.
├─ docker-compose.yml              # Services: Postgres, Airflow, Metabase
├─ .env.example                    # Configurable variables (copy to .env)
├─ data/
│  └─ telecom_customers.csv        # Place your dataset here
├─ sql/
│  ├─ 00_init.sql                  # pgcrypto + schema creation
│  ├─ 10_create_staging.sql        # staging table definition
│  ├─ 20_transform_clean.sql       # cleaning & missing value handling
│  └─ 30_build_dim_fact.sql        # anonymized dim + churn fact
└─ airflow/
   └─ dags/sql_elt_pipeline.py     # Airflow DAG (SQL-first orchestration)
```

---

## Getting Started

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine + Compose plugin  
- CSV dataset (e.g., `telecom_customers.csv`)  

### 2. Setup
1. Clone this repository:  
   ```bash
   git clone https://github.com/<your-org>/hgi-elt-sql.git
   cd hgi-elt-sql
   ```
2. Copy environment template:  
   ```bash
   cp .env.example .env
   ```
3. Place your CSV file in `./data/telecom_customers.csv`.  

### 3. Configure
Edit `.env` if needed:
```env
AIRFLOW_CRON=0 * * * *          # hourly (default)
INGEST_FILE=/opt/ingest/telecom_customers.csv
HASH_SALT=changeme-secret-salt  # rotate for anonymization
```

### 4. Run
```bash
docker compose up --build
```

### 5. Access
- **Airflow UI** → [http://localhost:8080](http://localhost:8080)  
  (username: `airflow`, password: `airflow`)  
- **Metabase UI** → [http://localhost:3000](http://localhost:3000)  
  Configure new DB connection:  
  - Host: `postgres`  
  - DB: `warehouse`  
  - User/pass from `.env`  

---

## Pipeline Flow
1. **Airflow DAG** runs hourly:
   - Creates schemas + extensions (`00_init.sql`).  
   - Creates/ensures staging table (`10_create_staging.sql`).  
   - Truncates and reloads CSV into staging.  
   - Cleans + defaults missing values (`20_transform_clean.sql`).  
   - Builds anonymized dimension + fact table (`30_build_dim_fact.sql`).  

2. **Metabase** queries the `analytics` schema for churn insights.  

---

## Customization
- **Change schedule**: Update `AIRFLOW_CRON` in `.env`.  
- **Use another dataset**: Adjust `sql/10_create_staging.sql` to match new columns.  
- **Anonymization**: Change `HASH_SALT` in `.env` to re-salt IDs.  
- **Incremental loads**: Replace `TRUNCATE` with `UPSERT` in the DAG.  

---

## Example Queries
```sql
-- Churn rate by contract type
SELECT contract, 
       ROUND(100.0 * SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate
FROM analytics.clean_customers
GROUP BY contract;

-- Average monthly charges by churn status
SELECT churn, AVG(monthlycharges) AS avg_monthly_charge
FROM analytics.clean_customers
GROUP BY churn;
```

---

## License
This project is released under the **MIT License**.  
