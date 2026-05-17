-- DATA CLEANING

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data and Fix Errors
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

-- Make a copy of the table you're working with
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Populate the new table
INSERT layoffs_staging
SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 'date' separates the unique rows from the duplicates

SELECT *
FROM world_layoffs.layoffs_staging;

-- Create a column that shows unique rows: (1) - unique, (2+) - duplicate

SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- CTE to check if row_num > 1
WITH duplicate_cte AS (
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT * FROM layoffs_staging
WHERE company = 'Cazoo';


-- layoffs - Copy To ClipBoard - Create Statement - Paste HERE - change the name
-- You CANNOT run a DELETE/UPDATE with a CTE thats why creating 2nd table with 10 columns

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2
WHERE row_num > 1;

-- Populate the new table with added `row_num`
INSERT INTO layoffs_staging2
SELECT 
    company, 
    location, 
    industry, 
    total_laid_off, 
    percentage_laid_off, 
    `date`, 
    stage, 
    country, 
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
        percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

-- Using row_num column as a filter
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2 
WHERE company = 'Casper';

-- 2. Standardizing Data

-- Remove white space of every text column you plan on using
SELECT *
FROM layoffs_staging2
WHERE LENGTH(company) != LENGTH(TRIM(company))
   OR LENGTH(location) != LENGTH(TRIM(location))
   OR LENGTH(industry) != LENGTH(TRIM(industry))
   OR LENGTH(country) != LENGTH(TRIM(country))
   OR LENGTH(stage) != LENGTH(TRIM(stage));
   
   UPDATE layoffs_staging2
SET company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    country = TRIM(country),
    stage = TRIM(stage)
WHERE LENGTH(company) != LENGTH(TRIM(company))
   OR LENGTH(location) != LENGTH(TRIM(location))
   OR LENGTH(industry) != LENGTH(TRIM(industry))
   OR LENGTH(country) != LENGTH(TRIM(country))
   OR LENGTH(stage) != LENGTH(TRIM(stage));
   
-- Check The INT based columns
SELECT * FROM layoffs_staging2 WHERE percentage_laid_off > 1;

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 0;

-- Ensure total_laid_off is an INT (Whole numbers only)
ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

-- Ensure percentage_laid_off is a FLOAT or DECIMAL (For precision)
ALTER TABLE layoffs_staging2
MODIFY COLUMN percentage_laid_off DECIMAL(6, 2);


-- Standardize (Industry)
SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean Punctuation
SELECT DISTINCT country
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert TEXT format to DATE format
SELECT `date` ,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Verification Scan
SELECT DISTINCT company FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT location FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT stage FROM layoffs_staging2 ORDER BY 1;

-- 3. Checking for NULLs and ' ' column by column

-- Identify
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
   OR industry = '';
   
   -- Convert
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Self-Join - First, run a SELECT to verify what you are about to update
SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Now, perform the actual UPDATE
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Check how many rows you are about to lose
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- 4.Delete the useless rows
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Remove the temporary column - row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- CLEAN DATA
SELECT * FROM layoffs_staging2;



