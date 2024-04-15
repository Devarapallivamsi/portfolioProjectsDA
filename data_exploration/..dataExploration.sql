--SELECT * FROM portfolioProject..CovidDeaths ORDER BY 3,4

--SELECT * FROM portfolioProject..CovidVaccinations ORDER BY 3,4



--ALTER TABLE portfolioProject..CovidDeaths
--ALTER COLUMN total_cases float;


--Likelihood of dying when covid contracts.
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100.0 AS DeathPercentage
FROM portfolioProject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--percentage of people got affected on the basis of date
SELECT location,date,total_cases,population,(total_cases/population)*100.0 AS percentPopInfected
FROM portfolioProject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) AS highestInfectionCount,MAX((total_cases/population))*100.0 AS 
percentPopInfected
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY percentPopInfected DESC

--Countries with highest death count
SELECT location,MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC


--continent wise death count
SELECT location,MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY totalDeathCount DESC


-- Gloabal numbers (without any borders)
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


