-- date cleaning
-- 1. Remove duplicates
-- 2. Standardize data
-- 3. Null values/blank values
-- 4. Remove any columns or rows that not necessary


select * 
from layoffs;

create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

insert into layoffs_staging
select *
from layoffs;




with duplicate_cte as
(
select *,
row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * 
from duplicate_cte
where row_num > 1;

select * 
from layoffs_staging
where company = 'Casper';


with duplicate_cte as
(
select *,
row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
Delete  
from duplicate_cte
where row_num > 1;




CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging_2;


insert into layoffs_staging_2
select *,
row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

Delete 
from layoffs_staging_2
where row_num > 1;


-- standardizing data
select company, trim(company)
from layoffs_staging_2;

update layoffs_staging_2
set company = trim(company);

select distinct(industry)
from layoffs_staging_2;

update layoffs_staging_2
set indusrtry = 'Crypto'
where industry like 'Crypto%';

select distinct country, trim(trailing '.' from country)
from layoffs_staging_2
order by 1;

update layoffs_staging_2
set country = trim(trailing '.' from country)
where country like 'United States%';

select `date`
from layoffs_staging_2;

update layoffs_staging_2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

Alter table layoffs_staging_2
modify column `date` DATE;

select *
from layoffs_staging_2
where total_laid_off IS NULL 
AND percentage_laid_off IS null
;

update layoffs_staging_2
set industry = null
where industry = '';

select distinct *
from layoffs_staging_2
where industry is null 
or industry = '';

select  *
from layoffs_staging_2
where company = "Bally's Interactive"
;

select * 
from layoffs_staging_2 t1
join layoffs_staging_2 t2
	on t1.company = t2.company
    AND t1.location = t2.location
where (t1.industry is null or t1.industry = ''
and t2.industry is not null);

update layoffs_staging_2 t1
join layoffs_staging_2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;


select  *
from layoffs_staging_2;

select *
from layoffs_staging_2
where total_laid_off IS NULL 
AND percentage_laid_off IS null
;


Delete
from layoffs_staging_2
where total_laid_off IS NULL 
AND percentage_laid_off IS null
;

alter table layoffs_staging_2
drop column row_num



