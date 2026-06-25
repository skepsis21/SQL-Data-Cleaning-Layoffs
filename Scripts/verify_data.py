import sqlite3

def verify_data():
    db_name = 'layoffs.db'
    print(f"--- Verifying {db_name} ---")
    
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()

    # Check for NULLs or empty strings
    cursor.execute("SELECT COUNT(*) FROM layoffs WHERE industry IS NULL OR industry = ''")
    null_count = cursor.fetchone()[0]

    if null_count == 0:
        print("✅ PASS: No NULL or empty industries found.")
    else:
        print(f"❌ FAIL: Found {null_count} rows with invalid industry data.")

    conn.close()

if __name__ == "__main__":
    verify_data()