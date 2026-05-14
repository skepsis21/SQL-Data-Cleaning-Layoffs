## Project Overview
SQL project focused on cleaning and standardizing layoffs dataset using MySQL. Includes Data Staging(Safety), Duplicates Removal, Standardization, NULL and Blanks Handling, Final Clean Up.

## Tools Used
* **SQL:** For data cleaning and transformation.
* **Database:** MySQL
* **Dataset:** [layoffs.csv](./Data/layoffs.csv)

## Data Cleaning Steps
In the `Scripts/data_cleaning.sql` file, I performed the following tasks:
1. **Removed Duplicates:** Identified and deleted redundant entries.
2. **Standardized Data:** Fixed naming inconsistencies (e.g., "United States" vs "United States.").
3. **Handled Null Values:** Populated missing data based on other available records.
4. **Modified Schema:** Adjusted data types for columns like `date` for better querying.

## How to Use
1. Clone the repository.
2. Run the SQL scripts located in the `/Scripts` folder in your database environment.

### Data Transformation Example
**Before (Messy Date):** `03/25/2023` (String)  
**After (Clean Date):** `2023-03-25` (Date Type)

**Before (Duplicate Records):** 2 rows for "Amazon" on the same date.  
**After (Unique Records):** 1 row after running `ROW_NUMBER()` partition script.

## Sample Data (Cleaned)
| Company | Location | Industry | Total Laid Off | Date |
| :--- | :--- | :--- | :--- | :--- |
| Casper | New York | Retail | 100 | 2023-09-14 |
| Amazon | Seattle | Retail | 9000 | 2023-01-18 |
| Google | Mountain View | Tech | 12000 | 2023-01-20 |