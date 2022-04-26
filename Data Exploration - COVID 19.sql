/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT * FROM PortfolioProject..CovidDeaths;
SELECT * FROM PortfolioProject..CovidVaccinations;

--Select Data That Is Going To Be Used

SELECT location,date, total_cases, new_cases, total_deaths,population 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--Looking At Total Deaths  Vs Total Cases
--Shows Likelihood Of Dying If You Contract Covid In India

SELECT location,date, total_deaths, total_cases,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'India'
and continent is not null
ORDER BY 1,2;


--Looking At The Total Cases Vs Population
--Shows What % Of Population Got Covid

SELECT location,date, population, total_cases,(total_cases/population)*100 as PercentagePouplationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India'
ORDER BY 1,2;


--Looking At Countries With Highest Infection Rate Compared To The Population

SELECT location, population, MAX(total_cases) as HighestInfectedCount,MAX((total_cases/population))*100 as PercentagePouplationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentagePouplationInfected DESC;


--Showing Countries With Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


--BREAKING THINGS DOWN BY CONTINENT

--Showing The Continents With The Highest Death Count Per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;



--GLOBAL NUMBERS

--The % Of People Who Died Out Of The % Of People Who Got Infected
SELECT date, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases) as total_cases, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;



--JOINING THE TABLES

--Looking at Vaccinations Vs Total Population
--Shows % Of Population That Has Received At Least One Covid Vaccine

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Two Ways To Look At RollingPopulation


--1] By Creating A CTE To Perform Calculation On Partition By In Previous Query 

WITH PopVsVacc (Continent, Location, Date,Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as Percentage
FROM PopVsVacc;


--2] By Creating a Temp Table To Perform Calculation On Partition By In Previous Query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as Percentage
FROM #PercentPopulationVaccinated;



--Creating Views To Store Data For Later Visualizations

CREATE VIEW PercentagePopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated