--Select *
--from PortfolioProject..CovidDeaths
--order by 3,4

Select *
from PortfolioProject.dbo.owiddeaths
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- modifica del formato colonna 
Alter table PortfolioProject.dbo.covidvaccinations
ALTER Column new_vaccinations float

-- Looking at Total Cases vs Total Deaths


--SELECT NULLIF(total_deaths, 0) AS total_deaths FROM PortfolioProject..CovidDeaths

update PortfolioProject.dbo.CovidVaccinations set new_vaccinations = null where new_vaccinations = '';

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject.dbo.owiddeaths
--order by Location, date

-- Looking at Total Cases vs Population
--Select Location, date, Population, total_cases, (total_cases/population)*100 as Infection
--from PortfolioProject.dbo.owiddeaths
--where location like 'Italy'
--order by Location, date


-- Looking at Countries with highest infection rate compared to population

--Select Location, Population, MAX(total_cases) as HighestInfectionCountry, MAX(total_cases/population)*100 as PercentPopulationInfected
--from PortfolioProject.dbo.owiddeaths
----where location like 'Italy'
--Group by Location, Population
--order by PercentPopulationInfected DESC

-- Showing Countries with Highest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.owiddeaths
--where location like 'Italy'
where continent is not null
Group by Location
order by TotalDeathCount DESC

-- Breaking down by continent
-- Showing continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.owiddeaths
--where location like 'Italy'
where continent is not null
Group by Continent
order by TotalDeathCount DESC

-- Global Numbers

Select date, SUM(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject.dbo.owiddeaths
where continent is not null
group by date
order by date, Sum(new_cases)

-- Lookint at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinated,
(RollingVaccinated/dea.population)*100
from PortfolioProject.dbo.owiddeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by dea.continent, dea.location, dea.date

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--,(RollingVaccinated/dea.population)*100
from PortfolioProject.dbo.owiddeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by dea.continent, dea.location, dea.date
)
Select *, (RollingVaccinated/Population)*100 VaccinatedPercentage
From PopvsVac

-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--,(RollingVaccinated/dea.population)*100
from PortfolioProject.dbo.owiddeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by dea.continent, dea.location, dea.date

Select *, (RollingPeopleVaccinated/Population)*100 VaccinatedPercentage
From #PercentPopulationVaccinated
order by Location, date

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
--,(RollingVaccinated/dea.population)*100
from PortfolioProject.dbo.owiddeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by dea.continent, dea.location, dea.date