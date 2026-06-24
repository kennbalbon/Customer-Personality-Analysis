-- Rename ID column
ALTER TABLE marketing_campaign
RENAME COLUMN `ï»¿ID` TO ID; 

-- Create a staging table.
CREATE TABLE marketing_staging
LIKE marketing_campaign;

INSERT INTO marketing_staging
SELECT *
FROM marketing_campaign;

SELECT * FROM marketing_staging;

-- Check for duplicates
WITH duplicate_checker AS
(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ID) AS rowNumber
FROM marketing_staging
)
SELECT *
FROM duplicate_checker
WHERE rowNumber < 1
;

-- Standardize the Dt_Customer column because there are 2 existing different date format.
SELECT ID, Dt_Customer,
	CASE 
		WHEN Dt_Customer LIKE '%-%' THEN STR_TO_DATE(Dt_Customer, '%d-%m-%Y')
        WHEN Dt_Customer Like '%/%' THEN STR_TO_DATE(Dt_Customer, '%d/%m/%Y')
        ELSE NULL
	END AS standardized_date
FROM marketing_staging
;

UPDATE marketing_staging
SET Dt_Customer =
CASE 
	WHEN Dt_Customer LIKE '%-%' THEN STR_TO_DATE(Dt_Customer, '%d-%m-%Y')
	WHEN Dt_Customer Like '%/%' THEN STR_TO_DATE(Dt_Customer, '%d/%m/%Y')
	ELSE Dt_Customer
END;

ALTER TABLE marketing_staging
MODIFY COLUMN Dt_Customer DATE;

-- Check for missing or null values
SELECT *
FROM marketing_staging
WHERE Income = '' OR Income IS NULL
;

-- Engineer New Financial Variables (total_spend, customer_age, household_size)
SELECT ID,
	(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS total_spend,
    -- Using 2014 instead of 2026 respecting the time the dataset was created.
    (2014 - Year_Birth) AS age,
    (KidHome + TeenHome) AS total_dependents
FROM marketing_staging
ORDER BY ID
;

ALTER TABLE marketing_staging
ADD COLUMN total_spend INT,
ADD COLUMN customer_age INT,
ADD COLUMN total_dependents INT
;

UPDATE marketing_staging
SET
	total_spend = MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds,
    customer_age = 2014 - Year_Birth,
    total_dependents = KidHome + TeenHome
;

# EDA
-- The Baseline View (Distribution Summary) 
CREATE OR REPLACE VIEW vw_distribution_analysis AS
SELECT
	MIN(Income) AS min_income,
    MAX(Income) AS max_income,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(STDDEV(Income), 2) AS stdDev_income,
    MIN(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS min_spend,
    MAX(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS max_spend,
    ROUND(AVG(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds), 2) AS avg_spend,
    ROUND(STDDEV(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds), 2) AS stdDev_spend
FROM marketing_staging
;

-- The Outlier Audit
CREATE OR REPLACE VIEW vw_outlier_audit AS
SELECT 	
	ID, Year_Birth, (2014 - Year_Birth) AS customer_age, Income,
    (MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS total_spend,
    CASE
		WHEN (2014 - Year_Birth) > 100 THEN 'Age Outlier (>100)'
        WHEN Income > 150000 THEN 'Income Outlier (>$150k)'
        ELSE 'Normal'
	END AS outlier_flag
FROM marketing_staging
WHERE customer_age > 100 OR Income > 150000
ORDER BY outlier_flag, ID
;

-- Marital Status Categorical Profiling
CREATE OR REPLACE VIEW vw_maritalStatus_profiling AS
SELECT Marital_Status, 
	COUNT(ID) AS customer_count,
    ROUND(AVG(MntWines), 2) avg_wine_spend, 
    ROUND(AVG(MntFruits), 2) avg_fruits_spend,
    ROUND(AVG(MntMeatProducts), 2) avg_meat_spend,
    ROUND(AVG(MntFishProducts), 2) avg_fish_spend,
    ROUND(AVG(MntSweetProducts), 2) avg_sweet_spend,
    ROUND(AVG(MntGoldProds), 2) avg_gold_spend,
    ROUND(AVG(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds), 2) AS avg_total_spend
FROM marketing_staging
GROUP BY marital_status
;

-- Education Categorical Profiling
CREATE OR REPLACE VIEW vw_education_profiling AS
SELECT Education, 
	COUNT(ID) AS customer_count,
    ROUND(AVG(MntWines), 2) avg_wine_spend, 
    ROUND(AVG(MntFruits), 2) avg_fruits_spend,
    ROUND(AVG(MntMeatProducts), 2) avg_meat_spend,
    ROUND(AVG(MntFishProducts), 2) avg_fish_spend,
    ROUND(AVG(MntSweetProducts), 2) avg_sweet_spend,
    ROUND(AVG(MntGoldProds), 2) avg_gold_spend,
    ROUND(AVG(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds), 2) AS avg_total_spend
FROM marketing_staging
GROUP BY Education
;

-- The Age Bracket View
CREATE OR REPLACE VIEW vw_age_bracket_profiling AS
WITH age_bracket_calculation AS
(
SELECT 
	ID,
    (MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS total_spend,
    (NumWebPurchases + NumStorePurchases + NumCatalogPurchases) AS total_purchases,
    CASE
		WHEN (2014 - Year_Birth) < 30 THEN '1. Under 30'
        WHEN (2014 - Year_Birth) BETWEEN 30 AND 39 THEN '2. 30-39'
        WHEN (2014 - Year_Birth) BETWEEN 40 AND 49 THEN '3. 40-49'
        WHEN (2014 - Year_Birth) BETWEEN 50 AND 59 THEN '4. 50-59'
        WHEN (2014 - Year_Birth) >= 60 THEN '5. 60+'
	END AS age_bracket
FROM marketing_staging
WHERE (2014 - Year_Birth) <= 100
)
SELECT 
	age_bracket, COUNT(ID) as customer_count,
    ROUND((COUNT(ID) / (SELECT COUNT(ID) FROM age_bracket_calculation)) * 100, 2) AS pct_total_customer,
    ROUND(AVG(total_spend), 2) avg_total_spend,
    ROUND(AVG(total_purchases), 2) avg_total_purchases
FROM age_bracket_calculation
GROUP BY age_bracket
ORDER BY age_bracket ASC
;

-- Channel Preferences Profiling
CREATE OR REPLACE VIEW vw_channel_preference AS
WITH income_calculation AS 
(
SELECT 
	ID, NumWebPurchases, NumStorePurchases, NumCatalogPurchases,
    CASE
		WHEN Income < 30000 THEN '1. Low Income (<$30k)'
        WHEN Income BETWEEN 30000 AND 60000 THEN '2. Medium Income ($30k - $60k)'
        WHEN Income BETWEEN 60001 AND 90000 THEN '3. High Income ($60K - $90k)'
        WHEN Income > 90000 THEN '4. Very High Income (>$90k)'
        ELSE NULL
	END AS income_bracket
FROM marketing_staging
)
SELECT
	income_bracket,
    COUNT(ID) as customer_count,
	ROUND((COUNT(ID) / (SELECT COUNT(ID) FROM income_calculation)) * 100, 2) AS pct_total_customer,
    ROUND(AVG(NumWebPurchases), 2) avg_web_purchases,
    ROUND(AVG(NumStorePurchases), 2) avg_store_purchases,
    ROUND(AVG(NumCatalogPurchases), 2) avg_catalog_purchases
FROM income_calculation
GROUP BY income_bracket
ORDER BY income_bracket ASC
;