-- Lending Club Loan Analysis
-- Step 1: Build a clean, typed table from the raw import (loans_raw)

CREATE TABLE loans_clean AS
SELECT
	CAST(id AS INTEGER) AS loan_id,
	CAST(loan_amnt AS REAL) AS loan_amount,
	CAST(TRIM(REPLACE(term, 'months', ' ')) AS INTEGER) AS term_months,
	CAST(int_rate AS REAL) AS interest_rate,
	CAST(installment AS REAL) AS monthly_payment,
	grade,
	sub_grade,
	emp_length,
	home_ownership,
	CAST(NULLIF(annual_inc, '') AS REAL) AS annual_income,
	verification_status,
	substr(issue_d, 5, 4) || '-' ||
		CASE substr(issue_d, 1, 3)
			WHEN 'Jan' THEN '01'
			WHEN 'Feb' THEN '02'
			WHEN 'Mar' THEN '03'
			WHEN 'Apr' THEN '04'
			WHEN 'May' THEN '05'
			WHEN 'Jun' THEN '06'
			WHEN 'Jul' THEN '07'
			WHEN 'Aug' THEN '08'
			WHEN 'Sep' THEN '09'
			WHEN 'Oct' THEN '10'
			WHEN 'Nov' THEN '11'
			WHEN 'Dec' THEN '12'
		END || '-01' AS issue_date,
	CAST(substr(issue_d, 5, 4) AS INTEGER) AS issue_year,
	loan_status,
	CASE
		WHEN loan_status IN ('Fully Paid', 'Does not meet the credit policy. Status:Fully Paid') THEN 'Good'
		WHEN loan_status IN ('Charged Off', 'Default', 'Does not meet the credit policy. Status:Charged Off') THEN 'Bad'
		ELSE 'Active'
	END AS loan_outcome,
	purpose,
	addr_state AS state,
	CAST(NULLIF(dti, '') AS REAL) AS dti,
	(CAST(fico_range_low AS REAL) + CAST(fico_range_high AS REAL)) / 2 AS fico_score,
	CAST(total_pymnt AS REAL) AS total_paid,
	CAST (recoveries AS REAL) AS recoveries
FROM loans_raw
WHERE LENGTH (loan_status) > 0;

-- Step 2: Analysis views for the Tableau dashboard

DROP VIEW IF EXISTS v_summary;
DROP VIEW IF EXISTS v_by_grade;
DROP VIEW IF EXISTS v_by_year;
DROP VIEW IF EXISTS v_by_purpose;
DROP VIEW IF EXISTS v_by_state;

CREATE VIEW v_summary AS
SELECT
	COUNT(*) AS total_loans,
	ROUND(SUM(loan_amount)) AS total_issued,
	ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
	SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END) AS finished_loans,
	ROUND (100.0 * SUM(CASE WHEN loan_outcome = 'Bad' THEN 1 ELSE 0 END) / SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END), 2) AS default_rate_pct
FROM loans_clean;

CREATE VIEW v_by_grade AS
SELECT
	grade,
	COUNT(*) AS total_loans,
	ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
	SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END) AS finished_loans,
	ROUND(100.0 * SUM(CASE WHEN loan_outcome = 'Bad' THEN 1 ELSE 0 END) / SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END), 2) AS default_rate_pct
FROM loans_clean
GROUP BY grade
ORDER BY grade;

CREATE VIEW v_by_year AS
SELECT
	issue_year,
	COUNT(*) AS total_loans,
	ROUND(SUM(loan_amount)) AS total_issued,
	SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END) AS finished_loans,
	ROUND(100.0 * SUM(CASE WHEN loan_outcome = 'Bad' THEN 1 ELSE 0 END) / SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END), 2) AS default_rate_pct
FROM loans_clean
GROUP BY issue_year
ORDER BY issue_year;

CREATE VIEW v_by_purpose AS
SELECT
	purpose,
	COUNT(*) AS total_loans,
	ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
	ROUND(100.0 * SUM(CASE WHEN loan_outcome = 'Bad' THEN 1 ELSE 0 END) / SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END), 2) AS default_rate_pct
FROM loans_clean
GROUP BY purpose
ORDER BY total_loans DESC;

CREATE VIEW v_by_state AS
SELECT
	state,
	COUNT(*) AS total_loans,
	ROUND(SUM(loan_amount)) AS total_issued,
	ROUND(100.0 * SUM(CASE WHEN loan_outcome = 'Bad' THEN 1 ELSE 0 END) / SUM(CASE WHEN loan_outcome IN ('Good', 'Bad') THEN 1 ELSE 0 END), 2) AS default_rate_pct
FROM loans_clean
GROUP BY state
ORDER BY total_loans DESC;
