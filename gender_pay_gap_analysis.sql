-- ============================================================
-- UK Gender Pay Gap Analysis (2021-2022)
-- ============================================================
-- This file contains all SQL queries used to analyze the UK
-- Government's Gender Pay Gap dataset for the 2021-22 period.
-- ============================================================

-- ============================================================
-- SECTION 1: DATA QUALITY ASSESSMENT
-- ============================================================

-- 1. Count total companies in the dataset
SELECT COUNT(employerid) AS total_companies
FROM gender_pay_gap_21_22;
-- Result: 10,174

-- 2. How many companies submitted data after the deadline?
SELECT COUNT(SubmittedAfterTheDeadline) AS late_submissions
FROM gender_pay_gap_21_22
WHERE SubmittedAfterTheDeadline = TRUE;
-- Result: 361

-- 3. How many companies have not provided a URL?
SELECT COUNT(companylinktogpginfo) AS missing_url
FROM gender_pay_gap_21_22
WHERE companylinktogpginfo = '0';
-- Result: 3,700

-- 4. Check for missing values in pay gap columns
SELECT 
    COUNT(*) - COUNT(diffmeanhourlypercent) AS mean_hourly_nulls,
    COUNT(*) - COUNT(diffmedianhourlypercent) AS median_hourly_nulls,
    COUNT(*) - COUNT(diffmeanbonuspercent) AS mean_bonus_nulls,
    COUNT(*) - COUNT(diffmedianbonuspercent) AS median_bonus_nulls
FROM gender_pay_gap_21_22;
-- Note: Bonus columns have significant missing data (4,019 and 2,837)
-- and should not be used for primary analysis


-- ============================================================
-- SECTION 2: UK-WIDE PAY GAP CALCULATION
-- ============================================================

-- 5 & 6. Calculate the average gender pay gap using median hourly percent
-- Using median to minimize impact of executive salary outliers
SELECT ROUND(AVG(diffmedianhourlypercent), 2) AS uk_avg_pay_gap
FROM gender_pay_gap_21_22;
-- Result: 12.31%


-- ============================================================
-- SECTION 3: LARGEST PAY GAPS ANALYSIS
-- ============================================================

-- 8. Top 10 companies with largest pay gaps (skewed towards men)
SELECT 
    employername,
    ROUND(AVG(diffmedianhourlypercent), 2) AS pay_gap,
    employersize,
    siccodes
FROM gender_pay_gap_21_22
GROUP BY employername, employersize, siccodes
ORDER BY pay_gap DESC
LIMIT 10;

-- 10. Filter for most significant companies (20,000+ employees)
-- This narrows to 63 companies for more meaningful analysis
SELECT 
    employername,
    ROUND(AVG(diffmedianhourlypercent), 2) AS pay_gap,
    employersize,
    siccodes
FROM gender_pay_gap_21_22
WHERE employersize = '20,000 or more'
GROUP BY employername, employersize, siccodes
ORDER BY pay_gap DESC;


-- ============================================================
-- SECTION 4: GEOGRAPHIC DIFFERENCES
-- ============================================================

-- 12. Average pay gap: London vs Outside London
SELECT 
    AVG(CASE WHEN address LIKE '%London%' 
        THEN diffmedianhourlypercent END) AS london_avg,
    AVG(CASE WHEN address NOT LIKE '%London%' 
        THEN diffmedianhourlypercent END) AS outside_london_avg
FROM gender_pay_gap_21_22;
-- Result: London 13.63% | Outside London 11.94%

-- 13. Average pay gap: London vs Birmingham
SELECT 
    AVG(CASE WHEN address LIKE '%London%' 
        THEN diffmedianhourlypercent END) AS london_avg,
    AVG(CASE WHEN address LIKE '%Birmingham%' 
        THEN diffmedianhourlypercent END) AS birmingham_avg
FROM gender_pay_gap_21_22;
-- Result: London 13.63% | Birmingham 10.81%


-- ============================================================
-- SECTION 5: INDUSTRY DIFFERENCES
-- ============================================================

-- 14. Average pay gap within schools (using SIC codes)
-- SIC codes for education: 85100 (pre-primary), 85200 (primary), 
-- 85310 (general secondary), 85320 (technical secondary), 85410 (post-secondary)
SELECT ROUND(AVG(diffmedianhourlypercent), 2) AS schools_pay_gap
FROM gender_pay_gap_21_22
WHERE siccodes IN ('85100', '85200', '85310', '85320', '85410');
-- Result: 26.96%

-- 15. Average pay gap within banks (SIC code 64191)
SELECT ROUND(AVG(diffmedianhourlypercent), 2) AS banking_pay_gap
FROM gender_pay_gap_21_22
WHERE siccodes = '64191';
-- Result: 31.72%


-- ============================================================
-- SECTION 6: COMPANY SIZE CORRELATION
-- ============================================================

-- 16. Relationship between company size and average pay gap
SELECT 
    employersize,
    ROUND(AVG(diffmedianhourlypercent), 2) AS avg_pay_gap
FROM gender_pay_gap_21_22
GROUP BY employersize
ORDER BY avg_pay_gap DESC;

-- Results:
-- 250-499:       12.78%
-- 500-999:       12.65%
-- 1000-4999:     11.56%
-- Less than 250: 11.35% (voluntary reporters - potential selection bias)
-- 5000-19,999:   10.25%
-- 20,000+:       9.73%

-- Conclusion: Larger companies tend to have smaller gender pay gaps


-- ============================================================
-- BONUS: ADDITIONAL ANALYSIS QUERIES
-- ============================================================

-- Count companies by employer size
SELECT 
    employersize,
    COUNT(*) AS company_count
FROM gender_pay_gap_21_22
GROUP BY employersize
ORDER BY company_count DESC;

-- Top 10 industries by average pay gap (using first 2 digits of SIC code)
SELECT 
    LEFT(siccodes, 2) AS industry_code,
    ROUND(AVG(diffmedianhourlypercent), 2) AS avg_pay_gap,
    COUNT(*) AS company_count
FROM gender_pay_gap_21_22
WHERE siccodes IS NOT NULL AND siccodes != ''
GROUP BY LEFT(siccodes, 2)
HAVING COUNT(*) >= 50  -- Only include industries with sufficient sample size
ORDER BY avg_pay_gap DESC
LIMIT 10;

-- Companies with pay gaps favouring women (negative values)
SELECT 
    COUNT(*) AS companies_favouring_women,
    ROUND(AVG(diffmedianhourlypercent), 2) AS avg_gap
FROM gender_pay_gap_21_22
WHERE diffmedianhourlypercent < 0;
