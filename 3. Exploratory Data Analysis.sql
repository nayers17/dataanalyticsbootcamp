-- Exploratory Data Analysis

SELECT sum(total_laid_off), max(percentage_laid_off), count(total_laid_off)
FROM layoffs_staging2;

SELECT stage, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT month(`date`) AS `MONTH`, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY sum(total_laid_off) DESC;

-- better way to group by datE

SELECT
	SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM 
	layoffs_staging2
WHERE 
	substring(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1
;

WITH Rolling_Total AS
(
SELECT
	SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM 
	layoffs_staging2
WHERE 
	substring(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1
)
SELECT 
	`MONTH`,
    total_off,
    SUM(total_off) 
		OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (Company, Years, Total_Laid_Off) AS
(
SELECT company,
	   YEAR(`date`),
       SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT 
	*,
    DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE Years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
