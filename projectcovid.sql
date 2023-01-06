

SELECT *
FROM portfolio..CovidDeaths
where continent is not null
order by 3,4

SELECT *
FROM portfolio..CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From portfolio..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases VS Total deaths
-- Show likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio..CovidDeaths
--where location like '%states%' 
where continent is not null
order by 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid


Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfected
From portfolio..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at Countries with highest Infection Rate Compared to Population


Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From portfolio..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolio..CovidDeaths
--where location like '%states%' 
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccinations



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated

From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

DROP table if exists #PercentPopulationVacinnated
Create Table #PercentPopulationVacinnated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVacinnated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated

From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVacinnated


--Creating View to Store data for later visualizations

DROP VIEW PercentPopulationVacinnated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated

From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null















