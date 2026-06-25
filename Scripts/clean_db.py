import pandas as pd
import sqlite3

def clean_database():
    conn = sqlite3.connect('layoffs.db')
    
    # Load data
    df = pd.read_sql('SELECT * FROM layoffs', conn)
    
    # 1. Remove Duplicates
    df.drop_duplicates(inplace=True)
    
    # 2. Standardize
    df['company'] = df['company'].str.strip()
    df['industry'] = df['industry'].replace('', None)
    
    # 3. Handle NULL industries (fill with same company's industry)
    df['industry'] = df.groupby('company')['industry'].ffill().bfill()
    
    # 4. Cleanup
    df.dropna(subset=['total_laid_off', 'percentage_laid_off'], how='all', inplace=True)
    
    # Save back
    df.to_sql('layoffs', conn, if_exists='replace', index=False)
    conn.close()
    print("✅ Cleaning complete. Data is now professional-grade.")

if __name__ == "__main__":
    clean_database()