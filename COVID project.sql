-------------------------------------------------------------------------
-----USING SQL TO COLLECT, CLEAN AND ANALYZING BASIC INFORMATION---------
-------------------------------------------------------------------------

--- STEP 1: Check Data
---

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2



SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--- STEP 2: Analyzing basic information
---

-- Shows likelihood of dying if you contract COVID in your country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2

-- Looking at Totalcases vas Population
-- Shows what percentage of population get COVID
SELECT location, date, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location AS Continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL AND location not IN ('World','International','European Union')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, 
		SUM(CAST(new_deaths as int)) AS total_deaths, 
		SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1
	

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE to perform Calculation on PARTITION BY in previous way

WITH PopvsVac AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedvsPop
FROM PopvsVac


-- Using Temp Table to Perform calculation on PARTITIION BY in previous way
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date



-- Creating View to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

ORDER BY 2,3




----------- COLLECT TABLE TO IMPORT DATA TO POWER BI
-----------


--Table 1: Calculating total cases, total deaths and death percentage in the world 
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1




--Table 2: Calculating total deaths in each continent
SELECT location AS continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL AND location not IN ('World','International','European Union')
GROUP BY location
ORDER BY TotalDeathCount DESC





--Table 3: calculating the number of infections and the percentage of population infected in each country
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Table 4: calculating the number of infections and the percentage of the population infected in each country day by day
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date, continent
ORDER BY PercentPopulationInfected DESC



--------------------
---Problem 1: Determine the correlation between two variables: vaccination and mortality rates
--------------------	

-- Identify the 5 countries with the most vaccinations in the world
WITH deavac AS (SELECT dea.date, dea.location,
				CASE WHEN total_cases is NULL THEN 0
				ELSE total_cases END AS total_cases,
				CASE WHEN new_deaths is NULL THEN 0
				 ELSE new_deaths END AS new_deaths,
				CASE WHEN total_vaccinations is NULL THEN 0
				ELSE total_vaccinations END AS total_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL)

SELECT location, MAX(total_vaccinations) AS total_vaccinations
FROM deavac
GROUP BY location
ORDER BY total_vaccinations DESC

--- Create a data table analyzing the correlation between these two variables
WITH deavac AS (SELECT dea.date, dea.location,
				CASE WHEN total_cases is NULL THEN 0
				ELSE total_cases END AS total_cases,
				CASE WHEN new_deaths is NULL THEN 0
				 ELSE new_deaths END AS new_deaths,
				CASE WHEN total_vaccinations is NULL THEN 0
				ELSE total_vaccinations END AS total_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL)

SELECT date, location, new_deaths, total_vaccinations
FROM deavac
WHERE location IN ('China', 'United States', 'India', 'United Kingdom','Brazil')
ORDER BY location, date

