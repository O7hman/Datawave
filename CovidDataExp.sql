--IN THIS QUERY SET, WE EXPLORE COVID 19 DATA FOR KEY BITS OF INFORMATION

-- Total number of Deaths per location population (Death Percentage)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2; 

-- Total number of cases per location population (Infection Percentage)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS TotalCasePercentage
FROM Portfolio..CovidDeaths
WHERE location like '%malay%'
ORDER BY 1, 2;

-- The highest Total Infection per location (Highest Infection Percentage)
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS HighestInfectionPercentage
FROM Portfolio..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC;

-- Highest total Cases per Location (Country)
SELECT location, MAX(total_cases) AS HighestInfectionCount
FROM Portfolio..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY HighestInfectionCount DESC;

-- Highest Death Count per Location (Country)
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM Portfolio..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

--Highest Death Count per Continent
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM Portfolio..CovidDeaths
WHERE Continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

--Rolling Count of Total vaccinations per Location (Country) Using CTE
WITH Popvs (continent, Location, Date, population, new_vaccinations, RollingCount) AS
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
 OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
 FROM Portfolio..CovidDeaths dea
 JOIN Portfolio..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date =  vac.date
 WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingCount/population)*100 AS percentage
FROM Popvs;


DROP TABLE IF EXISTS #VaccinationRollingCount
CREATE TABLE #VaccinationRollingCount
(
Continent nvarchar(50),
Location nvarchar(50),
Date date,
Population numeric,
new_vaccinations nvarchar(50),
RollingCount numeric
)

--Rolling Count of Total vaccinations per Location (Country) Using Temporary Table
INSERT INTO #VaccinationRollingCount
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
 OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
 FROM Portfolio..CovidDeaths dea
 JOIN Portfolio..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date =  vac.date
 WHERE dea.continent IS NOT NULL;

SELECT *
FROM #VaccinationRollingCount;

GO
--View Creating for Target Query Data
CREATE VIEW CovidDeathsCount AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
 OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
 FROM Portfolio..CovidDeaths dea
 JOIN Portfolio..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date =  vac.date
 WHERE dea.continent IS NOT NULL
);

GO

--CREATE PROCEDURE Example @continent nvarchar(20) AS
--(
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
-- OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
-- FROM Portfolio..CovidDeaths dea
-- JOIN Portfolio..CovidVaccinations vac
-- ON dea.location = vac.location
-- AND dea.date =  vac.date
-- WHERE dea.continent = @continent
--);


EXEC sp_help 'Portfolio..CovidDeaths'