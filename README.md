# PortfolioProjects
--select *
--from [Portfolio Project]..['Covid Deaths (Revised data)']
--order by 3,4

--select *
--from [Portfolio Project]..['CovidVaccinations (Revised data']
--order by 3,4

select location, date ,total_cases, new_cases, total_deaths, population
from [Portfolio Project]..['Covid Deaths (Revised data)']
order by 1,2

--total cases V/S total deaths
--chances of dying with covid
SELECT location, date, total_cases, total_deaths, ((cast(total_deaths as float))/total_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Deaths (Revised data)']
where location = 'India'
ORDER BY 1, 2

--total cases V/S Population
SELECT location, date, Population,total_cases,((cast(total_cases as float))/Population)*100 as PercentageInfected
from [Portfolio Project]..['Covid Deaths (Revised data)']
--where location = 'India'
ORDER BY 1, 2

--countries with highest infection rate (rate ie, percentage)

SELECT location, Population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as float))/Population)*100 as PercentagePopulationInfected
from [Portfolio Project]..['Covid Deaths (Revised data)']
--where location = 'India'
group by location, Population
ORDER BY PercentagePopulationInfected desc

--countries with highest death count
--SELECT location, Population, max(total_deaths) as HighestDeathCount, max((cast(total_deaths as float))/Population)*100 as PercentageofDeaths
--from [Portfolio Project]..['Covid Deaths (Revised data)']
--where Continent is not null 
--group by location, Population
--ORDER BY PercentageofDeaths desc

--countries with highest death count (count ie, total)
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..['Covid Deaths (Revised data)']
where Continent is not null 
group by location
ORDER BY TotalDeathCount desc

--Highest Death Count by Continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..['Covid Deaths (Revised data)']
where Continent is not null 
group by continent
ORDER BY TotalDeathCount desc

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Deaths (Revised data)']
--where location = 'India'
WHERE continent is not null
ORDER BY 1, 2

--COVID VACCINATION 

select *
from [Portfolio Project]..['CovidVaccinations (Revised data']

--Total amount of people got vaccinated in the world ie, vaccinations V/S Population

with popVSvacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
sum (cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid Deaths (Revised data)'] dea
join [Portfolio Project]..['CovidVaccinations (Revised data'] vacc
  on dea.location = vacc.location
  and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as percentagepeoplevaccinated
from popVSvacc


--CTEs TABLE

DROP Table if exists #PercentPopulationVaccinated


Create Table #PercentPopulationVaccinated

(

continent nvarchar(255),

location nvarchar(255),

date datetime,

population numeric,

new_vaccinations numeric,

RollingPeopleVaccinated numeric

)

Insert into #PercentPopulationVaccinated

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations , SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated

from [Portfolio Project]..['Covid Deaths (Revised data)'] deaths
join [Portfolio Project]..['CovidVaccinations (Revised data'] vaccinations

ON deaths.location = vaccinations.location

AND deaths.date = vaccinations.date

SELECT * , (RollingPeopleVaccinated/population)*100

FROM #PercentPopulationVaccinated



--creating view to store the data for later visualization


USE [Portfolio Project]
GO
CREATE VIEW Percent_Population_Vaccinated as

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations , SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated

-- , (RollingPeopleVaccinated/population)*100

from [Portfolio Project]..['Covid Deaths (Revised data)'] deaths
join [Portfolio Project]..['CovidVaccinations (Revised data'] vaccinations
ON deaths.location = vaccinations.location

AND deaths.date = vaccinations.date

WHERE deaths.continent is not null

select * 
from Percent_Population_Vaccinated





