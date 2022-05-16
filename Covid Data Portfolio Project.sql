USE PortfolioProject

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- SELECT DATA that I will be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' 
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what peracentage of populatuion got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
ORDER BY TotalDeathCount DESC


-- Breaking Things Down By Continent


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount DESC


-- Global Numbers 

SELECT
	 SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create or Alter View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated