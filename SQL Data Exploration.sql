--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE continent is not NULL
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying for contracting Covid-19 virus in the country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total Cases Vs Population
--Shows the percentage of population contracted Covid-19 virus

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX ((total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC

--Looking at Countries with Highest Death Count compared to Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Looking at Continents with Highest Death Count compared to Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100  AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

-- Looking At Total Populations Vs Vaccinations

SELECT CD.continent, CD.location, cd.date, cd.population, CV.new_vaccinations
, SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS CD
JOIN PortfolioProject.dbo.CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE

WITH POPvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT CD.continent, CD.location, cd.date, cd.population, CV.new_vaccinations
, SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject.dbo.CovidDeaths AS CD
JOIN PortfolioProject.dbo.CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population) *100 
FROM POPvsVac

--Using TEMP TABLE

DROP TABLE IF EXISTS #PopulationVaccinatedPercentage

CREATE TABLE #PopulationVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PopulationVaccinatedPercentage

SELECT CD.continent, CD.location, cd.date, cd.population, CV.new_vaccinations
, SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject.dbo.CovidDeaths AS CD
JOIN PortfolioProject.dbo.CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
--WHERE CD.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population) *100 
FROM #PopulationVaccinatedPercentage

-- Creating VIEW To Store Data For Visualisation

DROP VIEW PopulationVaccinatedPercentage

CREATE VIEW PopulationVaccinatedPercentage AS

SELECT CD.continent, CD.location, cd.date, cd.population, CV.new_vaccinations
, SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject.dbo.CovidDeaths AS CD
JOIN PortfolioProject.dbo.CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY 2, 3

SELECT * FROM PopulationVaccinatedPercentage