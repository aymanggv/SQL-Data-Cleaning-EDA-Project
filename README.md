# SQL Data Cleaning & Exploratory Data Analysis Project

## 📌 Overview
This project involves cleaning and analyzing a dataset using SQL. It’s divided into two major parts:
- **Data Cleaning**: Standardizing and preparing raw data for analysis.
- **Exploratory Data Analysis (EDA)**: Deriving insights and understanding the structure and trends within the dataset.

## 📂 Project Structure
```
data-analysis-sql-project/
│
├── 📁 sql/
│   ├── data_cleaning.sql
│   └── exploratory_analysis.sql
│
├── .gitignore
├── README.md
└── LICENSE              
```

## 🛠️ Tools Used
- SQL (tested in MySQL / PostgreSQL / SQLite) *(mention the actual engine used)*
- Any database GUI: pgAdmin, DBeaver, SSMS, etc.

## 🧹 Data Cleaning Highlights
- Removed duplicate rows
- Fixed inconsistent formatting
- Handled missing values
- Ensured correct data types

## 📊 EDA Highlights
- Performed descriptive statistics (AVG, MAX, etc.)
- Analyzed relationships using JOINs and GROUP BY
- Filtered key subsets for deeper analysis

## 🧾 How to Run
1. Load your dataset into your SQL environment.
2. Run the scripts in order:
   - `sql/data_cleaning.sql`
   - `sql/exploratory_analysis.sql`

## 🧹 Data Cleaning (`data_cleaning.sql`)

The data cleaning script prepares the dataset (`layoffs`) for analysis:

### SQL Steps

- **Duplicate Removal**  
  Uses a `ROW_NUMBER()` window function to identify and remove exact duplicate rows.

- **Create Staging Tables**  
  Creates `layoffs_staging` and `layoffs_staging_2` as intermediate cleaned tables.

- **Standardize Text Fields**  
  Trims whitespace, standardizes capitalization (e.g., lowercase for `industry` and `location`), and fixes known anomalies (like `'Crypto'` → `'Cryptocurrency'`).

- **Handle Null or Blank Values**  
  Replaces blank strings (`''`) with `NULL`.

- **Filter Out Unnecessary Rows**  
  Removes rows where `total_laid_off` or `percentage_laid_off` is null — assumed to be incomplete records.

---

## 📊 Exploratory Data Analysis (`exploratory_analysis.sql`)

The EDA script performs multiple analytical operations on the cleaned data:

### SQL Queries

- **Maximum Layoffs**  
  Returns the max value of `total_laid_off` and `percentage_laid_off`.
  ```sql
  select max(total_laid_off), max(percentage_laid_off)
  from layoffs_staging_2;
  ```

- **Companies with 100% Layoffs**  
  Filters companies where the `percentage_laid_off = 1` and orders by fundraising amount.
  ```sql
  select * 
  from layoffs_staging_2
  where percentage_laid_off = 1
  order by funds_raised_millions desc;
  ```
  

- **Total Layoffs by Company**  
  Aggregates layoffs at the company level to identify the most impacted.
   ```sql
   select company, sum(total_laid_off)
   from layoffs_staging_2
   group by company
   order by 2 desc;
   ```
  

- **Date Range of Layoffs**  
  Finds the earliest and latest dates in the dataset.
  ```sql
  select min(`date`), max(`date`)
  from layoffs_staging_2;
  ```

- **Layoffs by Industry**  
  Groups total layoffs by industry to detect which sectors were hit hardest.
  ```sql
  select industry, sum(total_laid_off)
  from layoffs_staging_2
  group by industry
  order by 2 desc;
  ```
  

- **Layoffs by Country**  
  Summarizes layoffs by geography.
  ```sql
  select country, sum(total_laid_off)
  from layoffs_staging_2
  group by country
  order by 2 desc;  
  ``` 
  

- **Layoffs by Year**  
  Breaks down layoffs annually for temporal analysis.
  ```sql
  select Year(`date`), sum(total_laid_off)
  from layoffs_staging_2
  group by Year(`date`)
  order by 1 desc;
  ``` sql  

- **Layoffs by Funding Stage**  
  Explores which startup stages (e.g., Series A, B, etc.) had the most layoffs.
  ```sql
  select stage, sum(total_laid_off)
  from layoffs_staging_2
  group by stage
  order by 2 desc;
  ```

- **Monthly Layoff Trends**  
  Groups data by month to visualize layoff trends over time.
  ```sql
  select substring(`date`, 1, 7) as `Month`, sum(total_laid_off)
  from layoffs_staging_2
  where substring(`date`, 1, 7) is not null
  group  by `Month`
  order by 1 asc; 
  ```

- **Rolling Total of Layoffs**  
  Uses a window function to compute a running total of layoffs month-by-month.
  ```sql
  with Rolling_Total as(
  select substring(`date`, 1, 7) as `Month`, sum(total_laid_off) as total_off
  from layoffs_staging_2
  where substring(`date`, 1, 7) is not null
  group  by `Month`
  order by 1 asc
  )
  select `Month`, total_off, sum(total_off) over(order by `Month`)
  from Rolling_Total;
  ```

 - **Layoffs by Company**  
  Summarizes layoffs by company.
  ```sql
  select company, sum(total_laid_off)
  from layoffs_staging_2
  group by company
  order by 2 desc;
  ```
 
 - **Layoffs by Company and Year**  
  Summarizes layoffs by company and the year of the layoffs.
  ```sql
  select company, year(`date`), sum(total_laid_off)
  from layoffs_staging_2
  group by company, year(`date`)
  order by 3 desc;
  ```

 - **Top 5 Companies with Most Layoffs Per Year**  
  Identifies the top 5 companies with the highest number of layoffs each year by calculating yearly totals and ranking them using DENSE_RANK().
  ```sql
  with Company_Year(company, years, total_laid_off) as 
  (
  select company, year(`date`), sum(total_laid_off)
  from layoffs_staging_2
  group by company, year(`date`)
  ), Company_Year_Rank as 
  (
  select *, dense_rank() over (partition by years order by total_laid_off desc) as ranking
  from Company_Year
  where years is not null
  )
  select * 
  from Company_Year_Rank
  where ranking <= 5;
  ```

---

## ✅ Results & Insights

- **Top impacted sectors**: Analysis reveals which industries suffered the most.
- **Temporal patterns**: Spikes in layoffs can be seen over time, often aligning with macroeconomic shifts.
- **Startups & layoffs**: Funding stage analysis suggests that even well-funded companies were not immune.
- **Data cleanliness**: Ensures accuracy and reliability of insights with rigorous preprocessing.

