

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1, 2


--Looking at Total cases vs Total Deaths


--shows likelihood of dying if you contract covid in Canada


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Canada'
Order by 1, 2


--Looking at Total cases vs Population
--Shows what percentage of population got Covid(could be used for viz)


Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Canada'
Order by 1, 2

--Looking at Countries with highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Canada'
Group by Location, population
Order by PercentPopulationInfected desc


--Showing Countries with the highest death count per population


Select Location, Max(cast(Total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Canada'
where continent is not null
Group by Location
Order by TotalDeathCount desc


--Lets break things down by continent

--Showing the continents with the highest death count per population


Select continent, Max(cast(Total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Canada'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Canada'
where continent is not null
Group by date
Order by 1, 2


--Total Global Numbers percentage


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Canada'
where continent is not null
--Group by date
Order by 1, 2

--Looking at total population vs Vaccinations

--Using CTE


With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as INT)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsVac


--Using Temp Table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as INT)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


--Creating View to store data for later Viz


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as INT)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From #PercentPopulationVaccinated