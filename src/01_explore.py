
from pathlib import Path
import pandas as pd

DATA_DIR = Path(__file__).resolve().parents[1] / "data" / "raw"

files = sorted(DATA_DIR.glob("*.csv"))

if not files:
    raise FileNotFoundError(
        f"No CSV files found in {DATA_DIR}"
    )

for file in files:
    df = pd.read_csv(file)

    print(f"\n{'=' * 60}")
    print(f"FILE: {file.name}")
    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns)}")

    print("\nMissing values:")
    print(
        df.isna().sum()
        .loc[lambda s: s > 0]
        .sort_values(ascending=False)
        .head(10)
    )

    print("\nDuplicate rows:", df.duplicated().sum())
    print("\nColumn names:")
    print(df.columns.tolist())
