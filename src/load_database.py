
from pathlib import Path
from getpass import getpass

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data" / "raw"

FILES = {
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "customers": "olist_customers_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "products": "olist_products_dataset.csv",
}

TIMESTAMP_COLUMNS = {
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date",
    "shipping_limit_date",
    "review_creation_date",
    "review_answer_timestamp",
}

username = input("PostgreSQL username [postgres]: ") or "postgres"
password = getpass("PostgreSQL password: ")

url = URL.create(
    "postgresql+psycopg2",
    username=username,
    password=password,
    host="localhost",
    port=5432,
    database="supplyflow",
)

engine = create_engine(url)

# This rebuilds the project's raw and analytical schemas.
# Use ONLY for your local SupplyFlow database.
with engine.begin() as conn:
    conn.execute(text("DROP SCHEMA IF EXISTS analytics CASCADE"))
    conn.execute(text("DROP SCHEMA IF EXISTS raw CASCADE"))
    conn.execute(text("CREATE SCHEMA raw"))
    conn.execute(text("CREATE SCHEMA analytics"))

for table_name, filename in FILES.items():
    df = pd.read_csv(DATA_DIR / filename)

    # Convert all known timestamp columns.
    for col in TIMESTAMP_COLUMNS.intersection(df.columns):
        df[col] = pd.to_datetime(
            df[col],
            errors="raise"
        )

    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists="fail",
        index=False,
        chunksize=5000,
        method="multi",
    )

    print(f"Loaded raw.{table_name}: {len(df):,} rows")

print("\nDatabase rebuilt successfully!")
