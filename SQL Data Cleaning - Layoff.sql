-- Data cleaning


SELECT * 
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standarize the data
-- 3. Null values or blanck values
-- 4. Remove any columns

SELECT *,
ROW_NUMBER()OVER(
PARTITION BY
company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY
company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)

SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- Create staging2 table
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

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY
company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standarizing data

-- company
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- industry
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- location
SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1;

-- country
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

SELECT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- date
SELECT date, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Null values or blanck values

SELECT * 
FROM layoffs_staging2;
  
SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL;

SELECT * 
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
  
SELECT st1.company, st1.industry, st2.company, st2.industry
FROM layoffs_staging2 st1
JOIN layoffs_staging2 st2
	ON st1.company = st2.company
WHERE st1.industry IS NULL
AND st2.industry IS NOT NULL;
    
UPDATE layoffs_staging2 st1
JOIN layoffs_staging2 st2
	ON st1.company = st2.company
SET st1.industry = st2.industry
WHERE  st1.industry IS NULL
AND st2.industry IS NOT NULL;
    
  
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
  
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
  
-- 4 Assess unecessary culumns
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
  
  
  


