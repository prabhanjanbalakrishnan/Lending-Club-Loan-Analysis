# Lending Club Loan Portfolio Analysis

An end-to-end analysis of **2.26 million consumer loans** issued by Lending Club from 2007 to 2018. I cleaned the raw data in SQL (SQLite), built summary views of portfolio risk, and visualized the results in a Tableau dashboard.

**Interactive dashboard:** [View on Tableau Public](ADD-YOUR-TABLEAU-LINK-HERE)

## Key findings

- **About 20% of finished loans charged off** (269,360 of 1,348,099 loans that were either fully paid or charged off).
- **Credit grade clearly separates risk.** Default rates climb steadily from 6% for grade A to 50% for grade G.
- **Pricing doesn't keep pace with risk.** Grade G borrowers pay about 4× grade A's interest rate but default about 8× as often.

| Grade | Loans | Avg interest rate | Default rate |
| --- | --- | --- | --- |
| A | 433,027 | 7.08% | 6.04% |
| B | 663,557 | 10.68% | 13.40% |
| C | 650,053 | 14.14% | 22.44% |
| D | 324,424 | 18.14% | 30.38% |
| E | 135,639 | 21.83% | 38.43% |
| F | 41,800 | 25.45% | 45.15% |
| G | 12,168 | 28.07% | 49.67% |

## Data

[Lending Club accepted loans, 2007–2018 Q4](https://www.kaggle.com/datasets/wordsforthewise/lending-club) from Kaggle: 2,260,701 rows and 151 columns. The raw file (1.68 GB) is not included in this repo because of its size; download it from Kaggle to reproduce the analysis.

## Method

1. **Load:** imported the raw CSV into a SQLite staging table (`loans_raw`) with every column as text, leaving the source data untouched.
2. **Explore:** profiled loan statuses and found 33 junk rows, which were summary totals from the source file rather than real loans.
3. **Clean:** built `loans_clean` (2,260,668 rows, 21 columns) in one `CREATE TABLE AS SELECT`:
   - converted text to numbers and dates (e.g. `" 36 months"` → `36`, `"Dec-2015"` → `2015-12-01`)
   - treated blank values as NULL so they don't skew averages
   - grouped ten inconsistent loan statuses into **Good**, **Bad** and **Active** outcomes
   - averaged the FICO score range into a single score
   - dropped the 33 junk rows
4. **Analyze:** created five views summarizing the portfolio overall and by grade, issue year, loan purpose and state.
5. **Visualize:** exported the views as CSV files and built the Tableau dashboard from them.

**Default rate** is calculated only on finished loans: Bad ÷ (Good + Bad). Loans still being repaid are excluded, because counting them would make the portfolio look safer than it is.

## Files

| File | Description |
| --- | --- |
| `lending_club_analysis.sql` | All SQL: the cleaning query and the five analysis views |
| `v_summary.csv` | Portfolio headline numbers |
| `v_by_grade.csv` | Loans, interest rate and default rate by credit grade |
| `v_by_year.csv` | Loan volume and default rate by issue year |
| `v_by_purpose.csv` | Loans, interest rate and default rate by loan purpose |
| `v_by_state.csv` | Loan volume and default rate by state |

## Tools

SQLite (sqlite3 command line, DB Browser for SQLite) · Tableau Public
