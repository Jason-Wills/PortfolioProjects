/* Covid Data Exploration */

SELECT *
FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3,4

-- Looking at Total deaths vs Total Cases
--CovidDeathPercentage indicates the chance of dying from covid 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS CovidDeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location = 'uganda'
ORDER BY 1,2

--Looking at Total cases vs Population
--Indicates the percentage of the population with covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 5 DESC

--Countries with highest inferction rate per population
SELECT location, MAX(total_cases) AS MaxTotalCases, population, MAX((total_cases/population)*100) AS InfectedPopulationPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--Looking at countries with the highest number of deaths
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Looking at the number of deaths per continent
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths 
WHERE continent IS  NULL
GROUP BY location
ORDER BY 2 DESC

--Looking at number of deaths globally
SELECT SUM(new_cases)as totalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Populations vs vaccinations
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int)) OVER (PARTITION BY DEA.Location ORDER BY 
DEA.LOCATION, DEA.DATE) AS RollingVaccinations
FROM PortfolioProjects..CovidDeaths AS DEA
JOIN PortfolioProjects..CovidVaccinations AS VAC
	ON DEA.date = VAC.date
	AND DEA.location = VAC.location
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

--Looking at the people vaccinated per population
--(a) Using CTE

WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int)) OVER (PARTITION BY DEA.Location ORDER BY 
DEA.LOCATION, DEA.DATE) AS RollingVaccinations
FROM PortfolioProjects..CovidDeaths AS DEA
JOIN PortfolioProjects..CovidVaccinations AS VAC
	ON DEA.date = VAC.date
	AND DEA.location = VAC.location
WHERE DEA.continent IS NOT NULL
)
SELECT *, (RollingVaccinations/Population)*100 as PercentageVaccinated
FROM PopVsVac

--(b) Using Temp Table

DROP TABLE IF EXISTS #PercentagePeopleVaccinated
CREATE TABLE #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)

INSERT INTO #PercentagePeopleVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int)) OVER (PARTITION BY DEA.Location ORDER BY 
DEA.LOCATION, DEA.DATE) AS RollingVaccinations
FROM PortfolioProjects..CovidDeaths AS DEA
JOIN PortfolioProjects..CovidVaccinations AS VAC
	ON DEA.date = VAC.date
	AND DEA.location = VAC.location
WHERE DEA.continent IS NOT NULL
ORDER BY 1,2

SELECT *, (RollingVaccinations/Population)*100 as PercentageVaccinated
FROM #PercentagePeopleVaccinated


--Creating a view 
CREATE VIEW PercentagePeopleVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int)) OVER (PARTITION BY DEA.Location ORDER BY 
DEA.LOCATION, DEA.DATE) AS RollingVaccinations
FROM PortfolioProjects..CovidDeaths AS DEA
JOIN PortfolioProjects..CovidVaccinations AS VAC
	ON DEA.date = VAC.date
	AND DEA.location = VAC.location
WHERE DEA.continent IS NOT NULL

SELECT *
FROM PercentagePeopleVaccinated
