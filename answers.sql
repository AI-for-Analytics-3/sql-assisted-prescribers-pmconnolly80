-- =====================================================
-- AI-Assisted Prescribers Project: SQL Answers
-- Using Claude to assist with SQL query development
-- =====================================================

-- =====================================================
-- PART 1: Simple Queries to Test Database Understanding
-- =====================================================

-- Query 1: Test Query - Count prescriptions by specialty (CLAUDE)
SELECT
  specialty_description,
  COUNT(*) as prescription_count,
  SUM(total_claim_count) as total_claims
FROM prescriber p
JOIN prescription pr ON p.npi = pr.npi
GROUP BY specialty_description
ORDER BY total_claims DESC
LIMIT 5;

-- =====================================================
-- PART 1: Question 1 - Specialty with Highest/Lowest Cost Per Day
-- =====================================================

-- Query 2a: Specialty with highest and lowest prescription cost per day
WITH specialty_cost_per_day AS (
  SELECT
    p.specialty_description,
    SUM(pr.total_drug_cost) as total_cost,
    SUM(pr.total_day_supply) as total_days,
    SUM(pr.total_drug_cost) / NULLIF(SUM(pr.total_day_supply), 0) as cost_per_day
  FROM prescriber p
  JOIN prescription pr ON p.npi = pr.npi
  GROUP BY p.specialty_description
)
SELECT
  'HIGHEST' as metric,
  specialty_description,
  total_cost,
  total_days,
  cost_per_day
FROM specialty_cost_per_day
WHERE cost_per_day = (SELECT MAX(cost_per_day) FROM specialty_cost_per_day)

UNION ALL

SELECT
  'LOWEST' as metric,
  specialty_description,
  total_cost,
  total_days,
  cost_per_day
FROM specialty_cost_per_day
WHERE cost_per_day = (SELECT MIN(cost_per_day) FROM specialty_cost_per_day)
ORDER BY metric DESC;

-- =====================================================
-- PART 1: Question 2 - Providers per Specialty
-- =====================================================

-- Query 3: How many providers are assigned to each specialty
SELECT
  specialty_description,
  COUNT(DISTINCT npi) as provider_count
FROM prescriber
GROUP BY specialty_description
ORDER BY provider_count DESC;

-- Query 4: Providers per specialty WITH prescription status (TRUE/FALSE)
SELECT
  p.specialty_description,
  COUNT(DISTINCT p.npi) as provider_count,
  CASE
    WHEN COUNT(pr.npi) > 0 THEN 'TRUE'
    ELSE 'FALSE'
  END as has_prescriptions
FROM prescriber p
LEFT JOIN prescription pr ON p.npi = pr.npi
GROUP BY p.specialty_description
ORDER BY provider_count DESC;

-- =====================================================
-- PART 1: Question 3 - Specialty with Most/Least Prescribing Providers
-- =====================================================

-- Query 5: Specialty with most providers that have written prescriptions
SELECT
  p.specialty_description,
  COUNT(DISTINCT p.npi) as provider_count
FROM prescriber p
INNER JOIN prescription pr ON p.npi = pr.npi
GROUP BY p.specialty_description
ORDER BY provider_count DESC
LIMIT 1;

-- Query 6: Specialty with most providers where NONE has written a prescription
SELECT
  p.specialty_description,
  COUNT(DISTINCT p.npi) as provider_count
FROM prescriber p
LEFT JOIN prescription pr ON p.npi = pr.npi
GROUP BY p.specialty_description
HAVING COUNT(pr.npi) = 0
ORDER BY provider_count DESC
LIMIT 1;

-- =====================================================
-- PART 2: Extract Distinct Generic Drugs
-- =====================================================

-- Query 7: Get list of each distinct generic_name (1727 drugs)
-- Output: Saved to CSV file 'part 2.csv'
SELECT DISTINCT generic_name
FROM drug
ORDER BY generic_name;

-- =====================================================
-- PART 3: Drug Categories Analysis
-- =====================================================

-- Query 8: Total day supply and total cost for each specialty/drug category
-- This query uses the drug_category_mapping table created by categorizing drugs
SELECT
    p.specialty_description,
    dcm.drug_category,
    SUM(pr.total_day_supply) as total_day_supply,
    SUM(pr.total_drug_cost) as total_cost,
    COUNT(DISTINCT p.npi) as provider_count
FROM prescriber p
JOIN prescription pr ON p.npi = pr.npi
JOIN drug d ON pr.drug_name = d.drug_name
JOIN drug_category_mapping dcm ON d.generic_name = dcm.generic_name
GROUP BY p.specialty_description, dcm.drug_category
HAVING SUM(pr.total_day_supply) > 0
ORDER BY total_cost DESC;

-- Query 9: Drug category distribution by specialty (Top 20)
SELECT
    p.specialty_description,
    dcm.drug_category,
    SUM(pr.total_day_supply) as total_day_supply,
    SUM(pr.total_drug_cost) as total_cost,
    COUNT(DISTINCT p.npi) as provider_count
FROM prescriber p
JOIN prescription pr ON p.npi = pr.npi
JOIN drug d ON pr.drug_name = d.drug_name
JOIN drug_category_mapping dcm ON d.generic_name = dcm.generic_name
GROUP BY p.specialty_description, dcm.drug_category
HAVING SUM(pr.total_day_supply) > 0
ORDER BY total_cost DESC
LIMIT 20;
