SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, total_deaths, new_cases, population
FROM PortfolioCovidProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Presents likelihood of dying if you contract COVID in Australia
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPct
FROM PortfolioCovidProject..CovidDeaths
WHERE Location = 'Australia'
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows percentage of population has COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 CovidPerCapita
FROM PortfolioCovidProject..CovidDeaths
WHERE Location = 'Australia'
ORDER BY 1,2

-- What countries have the highest infection rates?

SELECT location, population,  max(total_cases) HighestInfectionCount,  max((total_cases/population))*100 CovidPerCapita
FROM PortfolioCovidProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Shows the countries with the highest death rate

SELECT location, population,  max(cast(total_deaths as int)) TotalDeaths,  max((cast(total_deaths as int)/population))*100 DeathsPerCapita
FROM PortfolioCovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 DESC

-- CONTINENT

SELECT continent,  max(cast(total_deaths as int)) TotalDeaths
FROM PortfolioCovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent

-- GLOBAL STATISTICS

SELECT date, SUM(new_cases) NewCases, SUM(cast(new_deaths as int)) NewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 DeathPct
FROM PortfolioCovidProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- VACCINATIONS TABLE JOINED


-- Total Population vs. Vaccinations

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dth.location ORDER BY 
dth.location, dth.Date) RollingVaxCount
, 
FROM PortfolioCovidProject..CovidDeaths dth
JOIN PortfolioCovidProject..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
ORDER BY 2,3

-- Population count using CTE

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaxCount)
as
(
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dth.location ORDER BY 
dth.location, dth.Date) RollingVaxCount
FROM PortfolioCovidProject..CovidDeaths dth
JOIN PortfolioCovidProject..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
)

SELECT *, (RollingVaxCount/Population)*100 PctVacced
FROM PopVsVac


-- Creating View to store data for later visualisations

CREATE VIEW PctPopVaxxed as 
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaxCount)
as
(
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dth.location ORDER BY 
dth.location, dth.Date) RollingVaxCount
FROM PortfolioCovidProject..CovidDeaths dth
JOIN PortfolioCovidProject..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
)

SELECT *, (RollingVaxCount/Population)*100 PctVacced
FROM PopVsVac