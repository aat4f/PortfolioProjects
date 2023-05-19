SELECT *
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not null
order by 3,4


SELECT *
FROM PortfolioProject1.dbo.CovidVaccinations
Where continent is not null
order by 3,4


-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2


-- Looking at Total Cases vs Population
-- shows what percentage of population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count
-- using MAX with 'nvarchar' datatype gives wrong answer. so we use 'cast' to convert it to int
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- Showing Continents with Highest Death Count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is null
Group by Location
Order by TotalDeathCount desc


-- Global Deaths
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not null
Group by Date
Order by 1,2


-- Global Deaths minus date
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Population vs Vaccinations
-- (1/3)-RollingPeopleVaccinated in one query
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- (2/3)-RollingPeopleVaccinated using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentedVaccinated
From PopvsVac
Order by 2,3


-- (3/3)-RollingPeopleVaccinated using TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentedVaccinated
From #PercentPopulationVaccinated
Order by 2,3


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated
Order by 2,3