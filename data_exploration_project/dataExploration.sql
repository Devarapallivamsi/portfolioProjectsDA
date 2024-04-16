--1.Data regarding covid-19 deaths and vaccinations is explored on myriad ways considering the continents, countries etc.,
--2.This project is done using SQL SERVER 
--3.Cautions like appropriate dtypes of columns were taken care of before diving into the exploration part. For eg., wherever mathematical operatins like computing percentage etc.,
-- is carried out,columns are casted to float type to not miss out on accuracy.
--4. The following query helps one view the dtypes of all columns in the table
--  SELECT COLUMN_NAME, DATA_TYPE
--  FROM INFORMATION_SCHEMA.COLUMNS
--  WHERE TABLE_NAME = 'CovidDeaths'; (or CovidVaccinations)



--Exploration:

--Likelihood of dying when covid contracts.
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100.0 AS DeathPercentage
FROM portfolioProject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--Percentage of people affected on the basis of date.
SELECT location,date,total_cases,population,(total_cases/population)*100.0 AS percentPopInfected
FROM portfolioProject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--Countries with highest infection rate relative to their population.
--Note: Population is same throughout all the rows i.e, not updated with respect to deaths.(Deaths has it's own column)
SELECT location,MAX(total_cases) AS highestInfectionCount,MAX((total_cases/population))*100.0 AS 
percentPopInfected
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY percentPopInfected DESC

--Countries with highest death count.
SELECT location,MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC


--Continent wise death count.
SELECT location,MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY totalDeathCount DESC


-- Gloabal numbers (without any borders).
SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths,
(SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases))*100 AS percentOfDeaths
FROM 
portfolioProject..CovidDeaths
where continent is not null
GROUP BY date
order by 1,2

--Looking at total populations(Continent wise) vs vaccinations

with popsVac (continent,location,date,population,new_vaccinations,cumulVaccinations)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dea.continent,dea.location ORDER BY dea.date) AS cumulVaccinations
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac
ON dea.date= vac.date
AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
)
SELECT *,(CONVERT(float,cumulVaccinations)/population)*100 AS percentVaccinated FROM popsVac


