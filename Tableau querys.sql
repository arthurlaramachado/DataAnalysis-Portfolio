-- Tableau Table 1 
Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From FirstPortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Tableau Table 2
Select location, SUM(cast(new_deaths as float)) as TotalDeathCount
From FirstPortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International') and location not like '%income'
Group by location
order by TotalDeathCount desc


-- Tableau Table 3
Select Location, Population, MAX(cast(total_cases as float)) as HighestInfectionCount,  Max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From FirstPortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Tableau Table 4
Select Location, Population,date, MAX(cast(total_cases as float)) as HighestInfectionCount, Max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From FirstPortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc