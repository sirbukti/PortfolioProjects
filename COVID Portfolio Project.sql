select *
from PortfolioProject..covidDeaths
order by 3, 4

--select *
--from PortfolioProject..covidVaccinations
--order by 3, 4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying If you contract vocid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location like '%donesia%'
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%donesia%'
and continent is not null
order by 1,2

--Looking at country wit highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfection, Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%donesia%'
Group by location, population
order by PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
Group by location
order by TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..covidDeaths
--where continent is null
--Group by location
--order by TotalDeathCount DESC

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
Group by continent
order by TotalDeathCount DESC

--Showing continent with the Highest Death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
Group by continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths
Where continent is not null
Group By date
Order By 1,2

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths
Where continent is not null
Order By 1,2



--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


Select *
From PercentPopulationVaccinated