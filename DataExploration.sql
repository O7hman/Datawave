SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2; 


SELECT location, date, population, total_cases, (total_cases/population)*100 AS TotalCasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%malay%'
ORDER BY 1, 2;


SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS HighestInfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent <> ''
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC;


SELECT location, MAX(total_cases) AS HighestInfectionCount
FROM PortfolioProject..CovidDeaths
WHERE Continent <> ''
GROUP BY location
ORDER BY HighestInfectionCount DESC;


SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent <> ''
GROUP BY location
ORDER BY HighestDeathCount DESC;


SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent = ''
GROUP BY location
ORDER BY HighestDeathCount DESC;

WITH Popvs (continent, Location, Date, population, new_vaccinations, RollingCount) AS
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
 OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
 FROM dbo.CovidDeaths dea
 JOIN dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date =  vac.date
 WHERE dea.continent <> ''
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

INSERT INTO #VaccinationRollingCount
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
 OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
 FROM dbo.CovidDeaths dea
 JOIN dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date =  vac.date
 WHERE dea.continent <> '';

SELECT *
FROM #VaccinationRollingCount;


CREATE VIEW CovidDeathsCount AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
 OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
 FROM dbo.CovidDeaths dea
 JOIN dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date =  vac.date
 WHERE dea.continent <> ''
);



CREATE PROCEDURE Example @continent nvarchar(20) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int))
 OVER (PARTITION BY dea.location ORDER BY dea.date) RollingCount
 FROM dbo.CovidDeaths dea
 JOIN dbo.CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date =  vac.date
 WHERE dea.continent = @continent
);


EXEC Example 'Africa'

