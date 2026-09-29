import pandas as pd
import os
from sqlalchemy import create_engine

# Settings for Postgres.app
# Replace 'charishmakatta' with your exact Mac username if different
DB_USER = os.getlogin()  
DB_PASS = ""             # Postgres.app defaults to no password for local user
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "guidewire_analytics"

# Connection string
connection_string = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_string)

# Load CSV files into DataFrames
df_policies = pd.read_csv("pc_policy.csv")
df_claims = pd.read_csv("cc_claim.csv")
df_transactions = pd.read_csv("cc_transaction.csv")

# Load to PostgreSQL
df_policies.to_sql("pc_policy", engine, if_exists="replace", index=False)
df_claims.to_sql("cc_claim", engine, if_exists="replace", index=False)
df_transactions.to_sql("cc_transaction", engine, if_exists="replace", index=False)

print("Success! All 3 Guidewire datasets loaded into PostgreSQL.")

