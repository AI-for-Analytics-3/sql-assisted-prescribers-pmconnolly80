Query 1: Total Cost and Claims by Drug Category and Specialty

SELECT 
    p.specialty_description,
    dcm.drug_category,
    SUM(pr.total_drug_cost) as total_cost,
    SUM(pr.total_claim_count) as total_claims,
    COUNT(DISTINCT p.npi) as provider_count
FROM prescriber p
JOIN prescription pr ON p.npi = pr.npi
JOIN drug_category_mapping dcm ON pr.generic_name = dcm.generic_name
GROUP BY p.specialty_description, dcm.drug_category
ORDER BY total_cost DESC
LIMIT 20;




Query 2: Total Day Supply and Cost for Each Specialty/Drug Category

SELECT 
    p.specialty_description,
    dcm.drug_category,
    SUM(pr.total_day_supply) as total_day_supply,
    SUM(pr.total_drug_cost) as total_cost
FROM prescriber p
JOIN prescription pr ON p.npi = pr.npi
JOIN drug_category_mapping dcm ON pr.generic_name = dcm.generic_name
WHERE pr.total_day_supply > 0
GROUP BY p.specialty_description, dcm.drug_category
ORDER BY total_cost DESC;