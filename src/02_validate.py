
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parents[1] / "data" / "raw"

orders = pd.read_csv(DATA / "olist_orders_dataset.csv")
items = pd.read_csv(DATA / "olist_order_items_dataset.csv")
reviews = pd.read_csv(DATA / "olist_order_reviews_dataset.csv")
payments = pd.read_csv(DATA / "olist_order_payments_dataset.csv")
customers = pd.read_csv(DATA / "olist_customers_dataset.csv")

print("\n=== 1. ORDER UNIQUENESS ===")
print("Total orders:", len(orders))
print("Unique order IDs:", orders.order_id.nunique())
print("Duplicate order IDs:", orders.order_id.duplicated().sum())

print("\n=== 2. ORDER STATUS ===")
print(orders.order_status.value_counts())

print("\n=== 3. MISSING DELIVERY BY STATUS ===")
print(pd.crosstab(
    orders.order_status,
    orders.order_delivered_customer_date.isna(),
    margins=True
))

print("\n=== 4. ORDER ITEMS ===")
item_counts = items.groupby("order_id").size()
print("Orders with items:", len(item_counts))
print("Orders with multiple items:", (item_counts > 1).sum())
print("Max items per order:", item_counts.max())

print("\n=== 5. MULTIPLE SELLERS ===")
seller_counts = items.groupby("order_id").seller_id.nunique()
print("Orders with multiple sellers:", (seller_counts > 1).sum())
print("Max sellers per order:", seller_counts.max())

print("\n=== 6. REVIEWS ===")
review_counts = reviews.groupby("order_id").size()
print("Orders with reviews:", len(review_counts))
print("Orders with multiple reviews:", (review_counts > 1).sum())
print("Missing review scores:", reviews.review_score.isna().sum())

print("\n=== 7. PAYMENTS ===")
payment_counts = payments.groupby("order_id").size()
print("Orders with multiple payments:", (payment_counts > 1).sum())
print("Max payments per order:", payment_counts.max())

print("\n=== 8. REFERENTIAL INTEGRITY ===")
print(
    "Orders without matching customer:",
    (~orders.customer_id.isin(customers.customer_id)).sum()
)
print(
    "Items without matching order:",
    (~items.order_id.isin(orders.order_id)).sum()
)
print(
    "Reviews without matching order:",
    (~reviews.order_id.isin(orders.order_id)).sum()
)
print(
    "Payments without matching order:",
    (~payments.order_id.isin(orders.order_id)).sum()
)
