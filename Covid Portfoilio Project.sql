SELECT * 
FROM PortfoilioProject.dbo.CovidDeaths
where continent is not NULL


--Select the data we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfoilioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


--Looking at Total Cases VS. Total Deaths
--shows likelihood of dying if you contact Covid in your country

SELECT Location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfoilioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent is not NULL
ORDER BY 1,2 


--looking at Total cases vs Population
--what percentage of population got covid

SELECT Location, date, Population, total_cases,  
	(total_cases/population)* 100 as PercentPopulationInfected
FROM PortfoilioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent is not NULL
ORDER BY 1,2 


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  
	MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM PortfoilioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent is not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


--Showing Countries with highest DeathCount per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount  
FROM PortfoilioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


--Breaking down by Continent 

----Showing Continents with the highest death count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount  
FROM PortfoilioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent is  NULL
	AND Location not LIKE '%income%'
GROUP BY Location
ORDER BY TotalDeathCount desc


--For visualization drill only

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount  
FROM PortfoilioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--Golbal Numbers

SELECT date, SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfoilioProject.dbo.CovidDeaths
where continent is not NULL
group by date
ORDER BY date

--total DeathPercent

SELECT SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfoilioProject.dbo.CovidDeaths
where continent is not NULL


--Looking at Total Population vs New_Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfoilioProject.dbo.CovidDeaths dea
JOIN PortfoilioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


--Use CTE 
WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations,RolingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfoilioProject.dbo.CovidDeaths dea
JOIN PortfoilioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (RolingPeopleVaccinated/Population)*100 
FROM PopVsVac


--Creating Views to store data for future visualizations

Create View RollingPeopleVaccinated 
as 
SELECT dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfoilioProject.dbo.CovidDeaths dea
JOIN PortfoilioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL


SELECT *
FROM RollingPeopleVaccinated