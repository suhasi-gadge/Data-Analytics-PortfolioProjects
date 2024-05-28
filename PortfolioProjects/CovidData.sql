SELECT *
FROM [PortfolioProject].[dbo].[CovidDeathToll]
WHERE continent is NOT NULL
ORDER BY 3, 4


--SELECT *
--FROM [PortfolioProject].[dbo].[CovidVaccinations]
--WHERE continent is NOT NULL
--ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeathToll]
WHERE continent is NOT NULL
ORDER BY 1, 2

--Looking at Total Cases Vs Total Deaths
--Likelihood of dying by contracting covid in particular country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeathToll]
--WHERE continent is NOT NULL
WHERE location like '%states%'
ORDER BY 1, 2

--Looking at Total Cases Vs Population
--Shows the percentage of population that got covid!

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM [PortfolioProject].[dbo].[CovidDeathToll]
--WHERE location like '%states%'
ORDER BY 1, 2

--Looking at Countries with Higher Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeathToll]
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Looking at Countries with Higher Death Count Per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeathToll]
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Doesn't consider all the countires in the continent (don't use NOT NULL in this case)
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeathToll]
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Improvised version of the above query

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeathToll]
--WHERE location like '%states%'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT  date, SUM(new_cases), SUM(cast(new_deaths as int)) AS DeathPercentage --, (total_deaths/total_cases)*100
FROM [PortfolioProject].[dbo].[CovidDeathToll]
WHERE continent is NOT NULL
--and location like '%states%'
GROUP BY date
ORDER BY 1, 2


SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage --, (total_deaths/total_cases)*100
FROM [PortfolioProject].[dbo].[CovidDeathToll]
WHERE continent is NOT NULL
--and location like '%states%'
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage --, (total_deaths/total_cases)*100
FROM [PortfolioProject].[dbo].[CovidDeathToll]
WHERE continent is NOT NULL
--and location like '%states%'
--GROUP BY date
ORDER BY 1, 2


--STARTING WITH TABLE COVIDVACCINATIONS

SELECT *
FROM [PortfolioProject].[dbo].[CovidVaccinations]
--WHERE continent is NOT NULL
--ORDER BY 3, 4

--Joining Two Tables (CovidDeathToll + CovidVaccinations)
SELECT *
FROM [PortfolioProject].[dbo].[CovidDeathToll] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
	and dea.date = vac.date


--Looking for Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM [PortfolioProject].[dbo].[CovidDeathToll] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1, 2, 3


--Rolling Count of Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  AS RollingCount
FROM [PortfolioProject].[dbo].[CovidDeathToll] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3


--USE CTE 

--Rolling Count of Vaccinations

WITH PopVsVac (continent, Location, date, population, new_vaccinations, RollingCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  AS RollingCount
FROM [PortfolioProject].[dbo].[CovidDeathToll] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingCount/population)*100 AS RollingPercentVaccinated
FROM  PopVsVac


--USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  AS RollingCount
FROM [PortfolioProject].[dbo].[CovidDeathToll] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingCount/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to Store Data For Later Visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  AS RollingCount
FROM [PortfolioProject].[dbo].[CovidDeathToll] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2, 3