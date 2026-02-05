# UK Gender Pay Gap Analysis (2021-2022)

An SQL-based analysis of the UK Gender Pay Gap dataset, examining pay disparities across 10,174 companies by geography, industry, and company size.

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Dataset](https://img.shields.io/badge/Dataset-UK%20Gov-green)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## Overview

This project analyzes the UK government's mandatory gender pay gap reporting data to uncover patterns in pay inequality. The analysis reveals that the average median hourly pay gap across UK companies is **12.31%** in favour of men, with significant variations by location, industry, and company size.

### Key Findings

| Metric | Finding |
|--------|---------|
| **UK Average Pay Gap** | 12.31% |
| **London vs Outside London** | 13.63% vs 11.94% |
| **London vs Birmingham** | 13.63% vs 10.81% |
| **Banking Sector** | 31.72% |
| **Education Sector** | 26.96% |

**Company Size Pattern:** Larger companies (20,000+ employees) show smaller pay gaps (9.73%) compared to mid-sized companies (250-499 employees) at 12.78%.

## Dataset

- **Source:** UK Government Gender Pay Gap Service
- **Period:** 2021-2022 reporting year
- **Records:** 10,174 companies
- **Mandatory Reporting:** Companies with 250+ employees

### Data Quality Notes

- 361 companies submitted data after the deadline
- 3,700 companies did not provide a URL to their gender pay gap information
- Bonus data columns (`DiffMedianBonusPercent`, `DiffMeanBonusPercent`) contain significant missing values (4,019 and 2,837 respectively) and were excluded from analysis

## Analysis Sections

### 1. Data Quality Assessment

Evaluated the dataset for completeness and identified appropriate metrics for analysis. The `DiffMedianHourlyPercent` column was selected over `DiffMeanHourlyPercent` to minimize the impact of executive salary outliers.

```sql
-- Count total companies in dataset
SELECT COUNT(employerid) FROM gender_pay_gap_21_22;
-- Result: 10,174

-- Identify late submissions
SELECT COUNT(SubmittedAfterTheDeadline)
FROM gender_pay_gap_21_22
WHERE SubmittedAfterTheDeadline = TRUE;
-- Result: 361
```

### 2. UK-Wide Pay Gap Calculation

Calculated the national average using median hourly pay differences to account for salary distribution skewness.

```sql
SELECT AVG(diffmedianhourlypercent) FROM gender_pay_gap_21_22;
-- Result: 12.31%
```

### 3. Largest Pay Gaps Analysis

Identified companies with extreme pay gaps and filtered for statistical significance using employer size criteria.

```sql
-- Top 10 companies with largest pay gaps (20,000+ employees)
SELECT employername, 
       ROUND(AVG(diffmedianhourlypercent), 2) AS pay_gap,
       employersize, 
       siccodes
FROM gender_pay_gap_21_22
WHERE employersize = '20,000 or more'
GROUP BY employername, employersize, siccodes
ORDER BY pay_gap DESC
LIMIT 10;
```

### 4. Geographic Analysis

Compared pay gaps between London and other UK regions using address-based filtering.

```sql
SELECT 
    AVG(CASE WHEN address LIKE '%London%' THEN diffmedianhourlypercent END) AS London,
    AVG(CASE WHEN address NOT LIKE '%London%' THEN diffmedianhourlypercent END) AS outside_london
FROM gender_pay_gap_21_22;
-- Result: London 13.63% | Outside London 11.94%
```

### 5. Industry Analysis

Analyzed pay gaps by sector using Standard Industrial Classification (SIC) codes.

```sql
-- Education sector (SIC codes for schools)
SELECT ROUND(AVG(diffmedianhourlypercent), 2)
FROM gender_pay_gap_21_22
WHERE siccodes IN ('85100', '85200', '85310', '85320', '85410');
-- Result: 26.96%

-- Banking sector
SELECT ROUND(AVG(diffmedianhourlypercent), 2)
FROM gender_pay_gap_21_22
WHERE siccodes = '64191';
-- Result: 31.72%
```

### 6. Company Size Correlation

Investigated the relationship between employer size and pay gap magnitude.

```sql
SELECT ROUND(AVG(diffmedianhourlypercent), 2) AS avg_pay_gap, 
       employersize
FROM gender_pay_gap_21_22
GROUP BY employersize
ORDER BY avg_pay_gap DESC;
```

| Employer Size | Average Pay Gap |
|---------------|-----------------|
| 250-499 | 12.78% |
| 500-999 | 12.65% |
| 1000-4999 | 11.56% |
| Less than 250* | 11.35% |
| 5000-19,999 | 10.25% |
| 20,000+ | 9.73% |

*Note: Companies under 250 employees report voluntarily, potentially introducing selection bias.

## Technical Approach

### Methodology Decisions

**Why Median over Mean?**  
Executive compensation creates significant outliers. Using median hourly pay differences provides a more representative picture of typical employee experiences.

**Why Average of Medians?**  
While taking the median of medians would be more statistically pure, averaging allows comparison across different company sizes and provides actionable insights for policy recommendations.

### SQL Techniques Used

- Aggregate functions (`AVG`, `COUNT`, `ROUND`)
- Conditional aggregation with `CASE WHEN`
- Pattern matching with `LIKE`
- Filtering with `WHERE` and `IN`
- Grouping and sorting (`GROUP BY`, `ORDER BY`)
- Result limiting (`LIMIT`)

## Limitations & Caveats

1. **Voluntary Reporting Bias:** Companies under 250 employees self-select, potentially skewing results toward better performers
2. **Aggregate Data:** Company-level reporting cannot identify individual pay discrimination within departments
3. **Single Period:** Analysis covers 2021-2022 only; trends over time would require multi-year data
4. **Excluded Workers:** Agency workers are not included in company payrolls
5. **Geographic Approximation:** Location analysis uses address text matching, which may miss some variations

## Policy Recommendations

Based on the analysis findings:

1. **Strengthen Compliance:** Implement stricter penalties for late reporting
2. **Expand Coverage:** Consider mandatory reporting for companies with 100+ employees
3. **Sector-Specific Interventions:** Target banking and finance sectors where pay gaps exceed 30%
4. **Data Granularity:** Collect role-level data to identify same-job pay discrimination
5. **Transparency:** Require companies to disclose action plans alongside gap metrics

## Repository Structure

```
├── README.md
├── sql/
│   └── gender_pay_gap_analysis.sql    # All SQL queries
├── data/
│   └── data_source_info.md            # Dataset documentation
└── presentation/
    └── Gender_Pay_Gap.pptx            # Project presentation
```

## How to Reproduce

1. Download the UK Gender Pay Gap dataset from [GOV.UK](https://gender-pay-gap.service.gov.uk/)
2. Import into PostgreSQL as `gender_pay_gap_21_22`
3. Run queries from `sql/gender_pay_gap_analysis.sql`

## Tools Used

- **Database:** PostgreSQL
- **Analysis:** SQL
- **Presentation:** Microsoft PowerPoint

## About

This project was completed as part of the General Assembly Data Analytics Bootcamp, demonstrating SQL proficiency in data exploration, aggregation, and insight generation.

## License

This project uses publicly available UK government data. Analysis and code are available under the MIT License.

---

*Analysis completed February 2025*
