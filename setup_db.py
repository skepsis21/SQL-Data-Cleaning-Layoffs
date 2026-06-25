import pandas as pd
import sqlite3
import os

def setup_database():
    # Ensure pathing is relative to root, regardless of where script is called from
    base_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(base_dir, 'Data', 'layoffs.csv')
    db_name = os.path.join(base_dir, 'layoffs.db')
    
    print(f"--- Starting Ingestion from: {csv_path} ---")
    
    # 1. Load data
    if not os.path.exists(csv_path):
        print(f"❌ Error: File not found at {csv_path}")
        return

    df = pd.read_csv(csv_path, na_values=['', ' ', 'NULL'])
    
    # 2. Safely trim whitespace
    # Explicitly include=['object'] to prevent future version warnings
    df_obj = df.select_dtypes(include=['object'])
    
    if not df_obj.empty:
        df[df_obj.columns] = df_obj.apply(lambda x: x.str.strip())
    
    # 3. Connect and save
    conn = sqlite3.connect(db_name)
    df.to_sql('layoffs', conn, if_exists='replace', index=False)
    conn.close()
    
    print(f"--- Success: {len(df)} rows imported to {db_name} ---")

if __name__ == "__main__":
    setup_database()