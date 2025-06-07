-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. standardize data (issues with spelling, and making everything the same that should be the same)
-- 3. Null Values or blank values
-- 4. remove columns that are unnecessary

-- Zach Colon

-- 1: create a copied table

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- 2.0 Identifying duplicates

SELECT *, row_number() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- 2.1 creating a cte to identify duplicates
-- we are partitioning the rows and identifying duplicates by searching for multiple columns that have the same values
-- the partition labels every row as 1 if it is the first record with unique values, and 2 if there is a duplicate according to the columns

WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- found 5 duplicates

WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1; -- can not delete rows from CTEs


-- creating second table for data safety

CREATE TABLE layoffs_staging2(
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num`  INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

-- inserting data from layoffs_staging (has the row partitions for duplicates) into the layoffs_staging2 so we don't mess up the table that has the partitions
INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data
-- trimming company field
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- trimming industry column

SELECT industry
FROM layoffs_staging2;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- updating similar "Crypto" values in the industry column to "Crypto" with Update and Set 

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- checking and updating Country column
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- or 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- updating Date column to date data type instead of text data type
SELECT 
	`date`,
	str_to_date(`date`, '%m/%d/%Y')
FROM
	layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE
	layoffs_staging2
MODIFY COLUMN
	`date` DATE;

-- handling null values in total_laid_off, percentage_laid_off, and industry

SELECT 
	*
FROM
	layoffs_staging2
WHERE 
	total_laid_off
		IS NULL
	AND
    percentage_laid_off
		IS NULL;

SELECT
	*
FROM
	layoffs_staging2
WHERE
	industry IS NULL
    OR
	industry = '';

-- updating records that started as null or blank values. first, we changed the blank values to null values after joining tables on company and location
-- we would adjust our query to return on a conditional statement on a self join where the first table searches for industry with blank or null values
-- and the second table, t2, would find values based off a matching company and location that were NOT null values 

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- after that, we updated the null values from self joining the layoffs_staging2 tables on Company column and set the industry column on the NOT NULL values from the t2 table

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
	WHERE
		t1.industry IS NULL
	AND
		t2.industry IS NOT NULL;


-- this is how we updated the blank values to null values 
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';


-- validating: complete. You can see the industries are matching vs. the companies and the blank and null values were filled that could be filled, being able to 
-- reference other records to update the values in industry

SELECT company, location, industry
FROM layoffs_staging2
WHERE company = 'Airbnb' OR company = 'Juul' OR company = 'Carvana';

-- 

SELECT
	*
FROM 
	layoffs_staging2;

DELETE
FROM
	layoffs_staging2
WHERE 
	total_laid_off IS NULL
	AND
    percentage_laid_off IS NULL;
    
SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;





