USE FirstPortfolioProject

SELECT *
FROM FirstPortfolioProject..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, total_deaths/cast(total_cases as float)*100 as DeathsPerCasesPercentage
FROM FirstPortfolioProject..CovidDeaths
WHERE Location='Brazil'
ORDER BY date

--Comparison beetwen Brazil and United States
SELECT Location, MAX(cast(total_deaths as float)) as TotalDeathsPerLocation
FROM FirstPortfolioProject..CovidDeaths
WHERE Location='Brazil' or Location='United States'
GROUP BY Location

SELECT Location, MAX(total_deaths/cast(total_cases as float)*100) as MaxDeathPerCase
FROM FirstPortfolioProject..CovidDeaths
WHERE Location='Brazil' or Location='United States'
GROUP BY Location

--Looking at Total Cases vs Population
SELECT Location, date, total_cases, Population, ROUND((total_cases/cast(population as float))*100, 2) as PercentPopInfected
FROM FirstPortfolioProject..CovidDeaths
WHERE Location='Brazil'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/cast(population as float)))*100, 2) as PercentPopInfected
FROM FirstPortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT Location, population, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM FirstPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
from FirstPortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
SELECT date, SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as NewDeaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentagePerDay
FROM FirstPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths,  SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as TotalDeathPercentage
FROM FirstPortfolioProject..CovidDeaths
WHERE continent is not null

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
FROM FirstPortfolioProject..CovidDeaths dea
JOIN FirstPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
FROM FirstPortfolioProject..CovidDeaths dea
JOIN FirstPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/cast(population as float)*100) as PercentagePeoplePerPopVaccinated
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date nvarchar(255),
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
FROM FirstPortfolioProject..CovidDeaths dea
JOIN FirstPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/cast(population as float)*100) as PercentagePeoplePerPopVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
FROM FirstPortfolioProject..CovidDeaths dea
JOIN FirstPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated