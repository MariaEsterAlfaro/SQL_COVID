Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select Data that will be used
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows probability to die from covid in Brazil
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%Brazil%'
order by 1,2

--Looking at Total Cases vs Population
--Shows population percentage that got COVID
Select location, date, population, total_cases, (total_cases/population)*100 as cases_percentage
From PortfolioProject..CovidDeaths
Where location like '%Brazil%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as cases_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by cases_percentage desc

--Showing countries with highest death count per population
Select location, MAX(total_deaths) as highest_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by highest_death_count desc

--Ordering continents regarding highest death count
Select continent, MAX(total_deaths) as highest_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by highest_death_count desc

-- Global numbers per date
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

-- Global total
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Total population vs vaccination
-- using CTE
With PopVsVac(Continent, Location, Date, Population, New_Vaccinations, Cumulative_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as cumulative_people_vaccinated
--, cumulative_people_vaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (Cumulative_People_Vaccinated/Population)*100 as Cumulative_Percentage_Vaccinated
From PopVsVac



--using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cumulative_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as cumulative_people_vaccinated
--, cumulative_people_vaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (Cumulative_People_Vaccinated/Population)*100 as Cumulative_Percentage_Vaccinated
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as cumulative_people_vaccinated
--, cumulative_people_vaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated