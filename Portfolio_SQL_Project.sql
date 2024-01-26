-- QUERIES FOR PORTFOLIO PROJECT

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%states%' and continent is not null
order by 1, 2


-- Total Cases vs Population
-- Shows what percentage of population got covid

select Location, date, Population, total_cases, (total_cases/Population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where Location like '%states%' and where continent is not null
order by 1, 2

-- Countries with Highest Infection Rate compared to population

select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/Population))*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population
order by CovidPercentage desc

-- Countries with Highest Death Count per Population

select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Continent with Highest Death Count per Population

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

--Total Cases

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

--JOIN

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date

-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order 2, 3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order 2, 3

-- Using CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativeVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)
select *
from PopvsVac

select *, (CummulativeVaccinations/Population)*100
from PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated

create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
CummulativeVaccinations numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

select *, (CummulativeVaccinations/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
