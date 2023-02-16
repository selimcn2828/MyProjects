select * from CovidDeaths
order by 3,4

select * from CovidVaccinations
order by 3,4

-- Selecting data that I am going to use

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at Total cases vs Total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) as death_ratio
from CovidDeaths
order by 1,2

-- Looking at Total cases vs Total deaths in Turkey

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) as death_ratio
from CovidDeaths
where location like '%Turkey%'
order by 1,2

-- Looking at Total Cases vs Population

select Location, date, total_cases, population, (total_cases/population) as Case_ratio
from CovidDeaths
order by 1,2

--Looking at Countries with highest infectionrate compared to population

select Location, max(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as Covid_Ratio
from CovidDeaths
group by population, location
order by Covid_Ratio desc


-- Showing the countries with highest death count per population

select Location, max(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

-- Showing the continents with highest death count per population

select continent, max(CAST(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create TAble #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
