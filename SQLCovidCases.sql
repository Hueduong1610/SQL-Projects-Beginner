
Select * from [Portfolio Project]..CovidDeaths
order by 3,4

--Select * from [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
Select Location, date, total_cases, total_deaths, round((total_deaths/total_cases),2) as death_rate
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

--Total cases vs Population
Select Location, date, total_cases, population,round((total_deaths/population)*100,2) as death_percentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as highestcount,round(max(total_cases/population)*100,2) as highest_percentage
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
group by Location, Population
order by highest_percentage desc

-- Break things down to continent
Select continent, Max(cast(total_deaths as int)) as highestcount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by highestcount desc

--Showing countries with highest death count per population
Select Location, Max(cast(total_deaths as int)) as highestcount
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
group by location
order by highestcount desc


-- Showing continents with highest death count per population
Select continent, Max(cast(total_deaths as int)) as highestcount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by highestcount desc

-- Global numbers
Select Sum(new_cases) as total_new_cases, sum(cast (new_deaths as int)) as total_new_deaths, round(sum(cast(new_deaths as int)) / sum(new_cases),2) as newdeathrate
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- CovidVaccination Data Exploration: Total Population vs vaccinations
-- Use CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, Sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rollingPeopleVaccinated

from [Portfolio Project]..CovidDeaths cd
join [Portfolio Project]..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2, 3
)
Select *, round((RollingPeopleVaccinated / population),2) from popvsvac


--Create a TEMP Table
Drop table if exists #PercentPopulationVaccinated
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
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, Sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rollingPeopleVaccinated

from [Portfolio Project]..CovidDeaths cd
join [Portfolio Project]..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2, 3

Select *, round((RollingPeopleVaccinated / population),2) from #PercentPopulationVaccinated

--Create View to store data for later visualization

Create view PercentPopulationVaccinated as

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, Sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rollingPeopleVaccinated

from [Portfolio Project]..CovidDeaths cd
join [Portfolio Project]..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2, 3
