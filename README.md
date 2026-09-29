
README_guidewire_policy_claims.md
Guidewire Policy & Claims Analytics
P&C insurance analytics on synthetic datasets modeled on Guidewire PolicyCenter and ClaimCenter schemas — SQL KPI queries, a PostgreSQL ETL pipeline, and Tableau visualizations.

Overview
This project practices the core analytics workflow of a P&C insurance data analyst: generate realistic policy/claim data, model it relationally, load it into a warehouse, and compute the KPIs that claims managers and executives actually track — loss ratio, claim severity, and claim cycle time.

Tech Stack
Python (pandas, Faker, SQLAlchemy) — synthetic data generation + ETL
PostgreSQL — relational warehouse (guidewire_analytics)
SQL — CTEs and aggregations for KPI queries
Tableau — interactive worksheets for claims and executive reporting
Data
All data is synthetically generated with scripts/generate_guidewire_data.py (seeded with Faker for reproducibility). It mirrors Guidewire's relational structure — no real policyholder information is included.

Table

Rows

Contents

pc_policy

1,000

Policies across Personal Auto, Commercial Property, General Liability, Homeowners: policy number, type, effective/expiration dates, written & earned premium, status

cc_claim

1,200

Claims linked to policies: claim number, type, loss/reported/close dates, status (Closed, Open, Under Investigation)

cc_transaction

2,380

Financial transactions per claim: Loss Payment, Expense Payment, Reserve Increase with amounts and dates

Schema
pc_policy (policy_id PK)
    │ 1
    │ *
cc_claim (claim_id PK, policy_id FK)
    │ 1
    │ *
cc_transaction (transaction_id PK, claim_id FK)
Joins: pc_policy.policy_id = cc_claim.policy_id → cc_claim.claim_id = cc_transaction.claim_id

Key Metrics
Metric

Definition

Loss Ratio

SUM of Loss Payment amounts ÷ SUM of earned premium

Claim Severity

AVG loss payment amount per claim

Claim Cycle Time

AVG(close_date − reported_date) in days, closed claims only

The SQL for each metric lives in sql/guidewire_metrics.sql.

Tableau
tableau/Project-1.twbx is a packaged workbook (data bundled inside, no local file paths):

Loss ratio by policy type — loss ratio broken down across the four policy types
Claim Severity and Cycle Time — severity and cycle-time analysis with drill-down filters
Project Structure
guidewire-policy-claims-analytics/
├── README.md
├── data/
│   ├── pc_policy.csv
│   ├── cc_claim.csv
│   └── cc_transaction.csv
├── scripts/
│   ├── generate_guidewire_data.py   # synthetic data generation (Faker, seed 42)
│   └── load_to_postgres.py          # CSV → PostgreSQL ETL (SQLAlchemy)
├── sql/
│   └── guidewire_metrics.sql        # loss ratio, severity, cycle time queries
└── tableau/
    └── Project-1.twbx               # packaged workbook with bundled data
How to Run
Install dependencies:
   pip install pandas faker sqlalchemy psycopg2-binary
Generate the synthetic datasets (run from the repo root):
   python scripts/generate_guidewire_data.py
   This writes the three CSVs — move them into data/.

Create the database:
   CREATE DATABASE guidewire_analytics;
Load the CSVs into PostgreSQL:
   python scripts/load_to_postgres.py
   > load_to_postgres.py is written for Postgres.app on macOS (local OS user, no password). Adjust DB_USER, DB_PASS, and DB_HOST for your own setup.

Open tableau/Project-1.twbx in Tableau Desktop to explore the worksheets.


Future Improvements
Add dbt models and tests around the KPI transformations
Switch the ETL from full replace to incremental loads
More KPIs: claim frequency, combined ratio, reserve development
Publish the dashboard to Tableau Public on a refresh schedule
Author
Charishma Katta

