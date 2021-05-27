--India Covid-19 data as on 2021-05-23

USE covid_india


SELECT *
FROM covid_19;

SELECT*
FROM vaccinations;

ALTER TABLE covid_19 
ALTER COLUMN date date;


-- Overall data

WITH       Overall_count (region,confirmed_cases,active_cases,cured_discharged,death,total_doses)
AS          (
SELECT      v.region           AS  Region,
            c.confirmed_cases  AS  Total_infection,
	        c.active_cases     AS  Active,
	        c.cured_discharged AS  Cured,
	        c.death            AS  Deaths,
		    v.Total_Doses      AS  Total_Doses
FROM        vaccinations v
      JOIN  covid_19     c
ON          v.region = c.region
WHERE       c.region NOT IN ('India','World')
      AND   date    ='2021-05-23' 
GROUP BY    c.confirmed_cases, c.active_cases,c.cured_discharged,
            c.death,v.Total_Doses,v.Region
			)
SELECT      SUM(confirmed_cases)  AS  Total_cases,
	        SUM(active_cases)     AS  Active,
	        SUM(cured_discharged) AS  Cured,
	        SUM(death)            AS  Deaths,
  	        SUM(Total_Doses)      AS  Total_Vaccinated
FROM        overall_count;	   


-- Region wise total infections and deaths

SELECT     region, confirmed_cases     AS  confirmed_caess, death,
		   (death/confirmed_cases)*100 AS death_perent
FROM       covid_19
WHERE      region  NOT IN  ('World','India')
GROUP BY   date,region,confirmed_cases,death
HAVING     date = '2021-05-23'
ORDER BY   confirmed_caess DESC;


--TOP 5 region with most active cases

SELECT     TOP 5 region, active_cases
FROM       covid_19
WHERE      region NOT IN ('World','India')
GROUP BY   date, region, active_cases
HAVING     date = '2021-05-23'
ORDER BY   active_cases DESC;


--Top 5 union territories with most active cases

SELECT     Top 5 region, active_cases
FROM       covid_19
WHERE      region IN ('Delhi','Puducherry','Chandigarh',
                      'Dadra and Nagar Haveli and Daman and Diu',
                      'Andaman and Nicobar Islands',
                      'Lakshadweep',
                      'Ladakh',
                      'Jammu and Kashmir')
GROUP BY   date, region, active_cases
HAVING     date = '2021-05-23'
ORDER BY   active_cases DESC;


--Percent population infected state wise

UPDATE     vaccinations
SET        Region = 'Jammu and Kashmir'
WHERE      Region = 'Jammu & Kashmir';


SELECT     v.region, v.population, MAX(c.confirmed_cases) AS max_cases,
	       c.confirmed_cases/population*100               AS percent_infected
FROM       covid_19 c
LEFT JOIN  vaccinations v
ON         v.Region = c.region
WHERE      c.region !='world'
AND        c.region !='india'
AND        date    ='2021-05-23'
GROUP BY   date,v.Region, v.Population, c.confirmed_cases
ORDER BY   percent_infected DESC;


--Population fully vaccinated

SELECT     Region, Population, [2nd_Dose],
		   ([2nd_Dose]/Population)*100    AS population_vaccinated
FROM       vaccinations
WHERE      Population is not null
GROUP BY   Region,Population,[2nd_Dose]
ORDER BY   population_vaccinated DESC;

