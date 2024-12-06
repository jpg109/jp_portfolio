-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging2;

-- total company laid off ranking
SELECT company, industry, total_laid_off 
FROM layoffs_staging2
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company;

WITH total_company_laid_off_rank AS
(
SELECT company, SUM(total_laid_off) AS total_company_laid_off
FROM layoffs_staging2
GROUP BY company
)
SELECT 
company, total_company_laid_off, DENSE_RANK() OVER(ORDER BY total_company_laid_off DESC) AS company_rank
FROM total_company_laid_off_rank;

SELECT 
company, industry, total_laid_off, DENSE_RANK() OVER(ORDER BY total_laid_off DESC) AS total_laid_off_rank
FROM layoffs_staging2;

-- total country laid off ranking
SELECT country, SUM(total_laid_off) AS total_country_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_country_laid_off DESC;

WITH country_laid_off AS
(
SELECT country, SUM(total_laid_off) AS total_country_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY country
)
SELECT country, total_country_laid_off,
DENSE_RANK() OVER(ORDER BY total_country_laid_off DESC) AS country_laid_off_rank
FROM country_laid_off
ORDER BY country_laid_off_rank;



-- industry total laid off ranking
WITH total_industry_laid_off_rank AS
(
SELECT industry, SUM(total_laid_off) AS total_industry_laid_off
FROM layoffs_staging2
GROUP BY industry
)
SELECT 
industry, total_industry_laid_off, DENSE_RANK() OVER(ORDER BY total_industry_laid_off DESC) AS industry_rank
FROM total_industry_laid_off_rank
WHERE industry IS NOT NULL;


-- industry total laid off each year ranking


-- top 5 companies each year
SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY company ASC;

WITH company_laid_off AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL AND YEAR(`date`) IS NOT NULL
GROUP BY company, years
),
company_ranking AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_laid_off
)
SELECT *
FROM company_ranking
WHERE ranking <= 5
ORDER BY years;







 