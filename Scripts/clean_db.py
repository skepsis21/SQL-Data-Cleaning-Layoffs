import sqlite3

def run_sql_cleaning():
    conn = sqlite3.connect('layoffs.db')
    cursor = conn.cursor()
    # Read the file and execute as one big script
    with open('Scripts/data_cleaning.sql', 'r') as f:
        sql = f.read()
        cursor.executescript(sql)
    conn.commit()
    conn.close()
    print("✅ SQL cleaning script executed successfully.")

if __name__ == "__main__":
    run_sql_cleaning()