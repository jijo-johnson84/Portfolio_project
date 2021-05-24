--Data for project
--Data Source (https://ourworldindata.org/covid-deaths)


--Analyzing imported data

USE Portfolio_Project

SELECT    *
FROM      Portfolio_Project..covid_deaths
ORDER BY  1,3;

SELECT    *
FROM      Portfolio_Project..covid_vaccinations
ORDER BY  1,2 ;


--Altering data type

ALTER TABLE   Portfolio_Project..covid_deaths
ALTER COLUMN  total_deaths int

ALTER TABLE   Portfolio_Project..covid_deaths
ALTER COLUMN  new_deaths int

ALTER TABLE   Portfolio_Project..covid_deaths
ALTER COLUMN  total_deaths_per_million float

ALTER TABLE   Portfolio_Project..covid_deaths
ALTER COLUMN  new_deaths_per_million float


--Creating view for eay access of data

CREATE VIEW   global_death_count
AS
(SELECT       continent,location, MAX(total_deaths) AS total_death_count
 FROM         Portfolio_Project..covid_deaths
 WHERE        continent is not null
 GROUP BY     continent,location);


--Continent with highest death count

SELECT       continent,SUM(total_death_count)AS total_death
FROM         global_death_count
GROUP BY     continent
ORDER BY     2 desc

--Countries with highest death count

SELECT       location,SUM(total_death_count)AS total_death
FROM         global_death_count
GROUP BY     location
ORDER BY     2 desc

--Global death rate to total cases

SELECT     date, SUM(total_cases)total_cases,
                 SUM(total_deaths)total_deaths,
                 SUM(total_deaths)/SUM(total_cases)*100 AS percet_death
FROM       Portfolio_Project..covid_deaths
GROUP BY   date
ORDER BY   date


--Toatal infection rate among population from day 1(Location - India)

SELECT     CAST([date] as date) AS date,
           population, total_cases,
	       total_cases/population*100 AS percent_infected
FROM       Portfolio_Project..covid_deaths
WHERE      location = 'India'
ORDER BY   1,2


--Total Death Rate for each day(Location - India)

SELECT     location, CAST([date] as date) AS date,
           total_cases, total_deaths,
	       (total_deaths/total_cases)*100 AS percent_death
FROM       Portfolio_Project..covid_deaths
WHERE      location = 'India'
ORDER BY   2


--Countries with high infection rate globally.

SELECT     location, population, MAX(total_cases) AS infection_count,
	       MAX((total_cases/population))*100 AS infection_rate
FROM       Portfolio_Project..covid_deaths
WHERE      continent is not null
GROUP BY   location, population
ORDER BY   infection_rate desc


--Covid death rate by countries

SELECT     location AS countries, population, MAX(total_deaths) AS total_death_count,
		    MAX(total_deaths)/population*100 AS death_rate
FROM       Portfolio_Project..covid_deaths
WHERE      continent is not null
GROUP BY   location, population
ORDER BY   4 desc 


--Countries having high death counts in Asia

SELECT     location, population, MAX(total_deaths) AS total_death_count
FROM       Portfolio_Project..covid_deaths
WHERE      continent LIKE '%Asia%'
GROUP BY   location, population
ORDER BY   total_death_count desc 


--Global new cases by date and death_rate(new_deaths/new_cases) 

SELECT     date, SUM(new_cases)new_cases, SUM(new_deaths)new_deaths,
           SUM(new_deaths)/SUM(new_cases+0.01)*100 AS death_rate
FROM       Portfolio_Project..covid_deaths
WHERE      continent is not null
GROUP BY   date
ORDER BY   1,2


--Global overall new cases vs new deaths

SELECT     SUM(new_cases)new_cases, SUM(new_deaths)new_deaths,
           SUM(new_deaths)/SUM(new_cases+0.01)*100 AS death_rate
FROM       Portfolio_Project..covid_deaths
WHERE      continent is not null
ORDER BY   1,2


--Total population vaccinated among countries Joining tables

SELECT     cd.continent, cd.location, cd.date,
		   cd.population,cv.new_vaccinations,
		   SUM(CONVERT(int,cv.new_vaccinations)) OVER 
           (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS Rolling_vacc_count
FROM	   Portfolio_Project..covid_deaths cd
     JOIN  Portfolio_Project..covid_vaccinations cv
ON		   cd.location = cv.location
     AND   cd.date     = cv.date
WHERE      cd.continent is not null
ORDER BY   2,3


-- CTE for calculating total percentage of population vacccinated

WITH p_vaccinated(continent, location, date,
		          population,new_vaccinations,rolling_vacc_count)
AS
    (SELECT  cd.continent, cd.location, cd.date,
		     cd.population,cv.new_vaccinations,
		     SUM(CONVERT(int,cv.new_vaccinations)) OVER 
             (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS rolling_vacc_count
    FROM     Portfolio_Project..covid_deaths cd
       JOIN  Portfolio_Project..covid_vaccinations cv
    ON		 cd.location = cv.location
       AND   cd.date     = cv.date
WHERE        cd.continent is not null)

Select *,(rolling_vacc_count/population)*100 AS percent_vaccinated
FROM P_vaccinated


--Creating table by collating data for population _ vaccinated

CREATE TABLE population_vaccinated
( continent nvarchar(225),
  location  nvarchar(225),
  date datetime,
  population float,
  new_vaccinations float,
  rolling_vacc_count numeric null
)
INSERT INTO population_vaccinated
SELECT       cd.continent, cd.location, cd.date,
		     cd.population,cv.new_vaccinations,
		     SUM(CONVERT(float,cv.new_vaccinations)) OVER 
             (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS rolling_vacc_count
    FROM     Portfolio_Project..covid_deaths cd
       JOIN  Portfolio_Project..covid_vaccinations cv
    ON		 cd.location = cv.location
       AND   cd.date     = cv.date

Select *,(rolling_vacc_count/population)*100 AS percent_vaccinated
FROM population_vaccinated

-- Dropping table

DROP TABLE population_vaccinated


--Creating view to easily access data

CREATE VIEW  population_vaccinated 
AS 
SELECT       cd.continent, cd.location, cd.date,
		     cd.population,cv.new_vaccinations,
		     SUM(CONVERT(float,cv.new_vaccinations)) OVER 
             (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS rolling_vacc_count
FROM         Portfolio_Project..covid_deaths cd
       JOIN  Portfolio_Project..covid_vaccinations cv
ON		     cd.location = cv.location
       AND   cd.date     = cv.date
WHERE        cd.continent is not null


