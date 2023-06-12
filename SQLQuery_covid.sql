select * from COVID..covid_deaths
where continent is not null
order by 3,4

select * from COVID..covid_vaccinations
order by 3,4

--Selecting the data that we'll be using

select location,date,total_cases,new_cases,total_deaths,population 
from COVID..covid_deaths
order by 1,2


--Total cases vs Total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from COVID..covid_deaths
order by 1,2


--Total cases vs Total deaths in US (shows the likelihood of dying by covid)

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from COVID..covid_deaths
where location like '%states%'
order by 1,2

--Total cases vs Total deaths in India (shows the likelihood of dying by covid)

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from COVID..covid_deaths
where location = 'India'
order by 1,2


--Total cases vs Population in US (shows % of people that got covid)

select location,date,total_cases,population,(total_cases/population)*100 as percentage_population_infected
from COVID..covid_deaths
where location like '%states%'
order by 1,2


--Total cases vs Population in India (shows % of people that got covid)

select location,date,total_cases,population,(total_cases/population)*100 as percentage_population_infected
from COVID..covid_deaths
where location = 'India'
order by 1,2


--Country having highest infection rate compared to population

select location,population,max(total_cases) as highest_infection_count,max((total_cases/population))*100 
as percentage_population_infected
from COVID..covid_deaths
group by location, population
order by percentage_population_infected desc


--Countries with highest death count per population

select location,population,max(total_deaths) as highest_death_count,max((total_deaths/population))*100 
as percentage_population_death
from COVID..covid_deaths
where continent is not null
group by location, population
order by highest_death_count desc


--Continents with highest death count per population

select continent,max(total_deaths) as highest_death_count,max((total_deaths/population))*100 
as percentage_population_death
from COVID..covid_deaths
where continent is not null
group by continent
order by highest_death_count desc


--Continents with highest death count per population

select location,max(total_deaths) as highest_death_count,max((total_deaths/population))*100 
as percentage_population_death
from COVID..covid_deaths
where continent is null
group by location
order by highest_death_count desc


--Global death_percentage

select SUM(new_cases) as new_covid_cases,SUM(new_deaths) as new_death_cases,
SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
from COVID..covid_deaths
where continent is not null 
order by 1,2


--Joining the tables together

select * from COVID..covid_deaths dea
join COVID..covid_vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date

 --Total population vs vaccination

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
 as people_vaccinated
 from COVID..covid_deaths dea
join COVID..covid_vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
order by 1,2



--Use of CTE

with popvsvac (continent,location,date, population,new_vaccinations,people_vaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
 as people_vaccinated
 from COVID..covid_deaths dea
join COVID..covid_vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
)
select *, (people_vaccinated/population) as vaccinated from popvsvac


--Temp Table
drop table if exists #percentpeoplevaccinated
create table #percentpeoplevaccinated
(continent nvarchar(255) ,location nvarchar(255),date datetime, 
population numeric,new_vaccinations numeric,people_vaccinated numeric
)
insert into #percentpeoplevaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
 as people_vaccinated
 from COVID..covid_deaths dea
join COVID..covid_vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
order by 1,2

select *, (people_vaccinated/population) as vaccinated from #percentpeoplevaccinated


-- Creating view to store data for visualization


create view percentpeoplevaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum (vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
 as people_vaccinated
 from COVID..covid_deaths dea
join COVID..covid_vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 

 select * from percentpeoplevaccinated




 /*
Queries used for Power BI Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From COVID..covid_deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2




--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From COVID..covid_deaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From COVID..covid_deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From COVID..covid_deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc





