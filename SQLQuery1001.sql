--select *
--from PortfolioProject.dbo.CovidDeaths$
--order by 3,4


--select data that we are going to be using 

select location ,date, total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths 

select location ,date, total_cases,total_deaths,(total_deaths/total_cases*100) as Deathpercentage
from PortfolioProject.dbo.CovidDeaths$
where location like'%india%'
order by 1,2

--Looking at total cases vs population 

select location ,date, total_cases,population ,(total_cases/population)*100 as Infectedpercentage
from PortfolioProject.dbo.CovidDeaths$
where location like'%india%'
order by 1,2

--countries with highest infection rate compared to poopulation 

select location ,max(total_cases) as HighestInfectioncount ,population ,MAX((total_cases/population))*100 as Infectedpercentage
from PortfolioProject.dbo.CovidDeaths$
GROUP BY location,population
order by Infectedpercentage desc


--showing countries with highest death count per population 

select location ,max(total_deaths) as deathpercentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
GROUP BY location
order by deathpercentage desc


--Showing continent with highest death count 

select continent ,max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
GROUP BY continent
order by Totaldeathcount desc

--global numbers

select date, sum(new_cases ),sum(cast(new_deaths as int)) as Totaldeaths ,SUM(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2



select * 
from PortfolioProject.dbo.Covidvaccinations$


--Joining two tables

select *
from PortfolioProject.dbo.CovidDeaths$ AS dea
join PortfolioProject.dbo.Covidvaccinations$ as vac
	on dea.location=vac.location
	and dea.date=vac.date


--total people vs tota vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject.dbo.CovidDeaths$ AS dea
join PortfolioProject.dbo.Covidvaccinations$ as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 4


--WITH CTE

WITH Popvsvac (Continent,Location,Date,Population ,New_Vaccinations,RollingPeopleVaccinated )
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location ,dea.date) as RollingPeopleVaccianted
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated/Population)*100
from Popvsvac


--WITH TEMP TABLE 


drop if table exists #Percentpopulationvaccinated 
Create table #Percentpopulationvaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric,
)

Insert into #Percentpopulationvaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location ,dea.date) as RollingPeopleVaccianted
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #Percentpopulationvaccinated 

--Creating view to store data for visualizations 

Create View Percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location ,dea.date) as RollingPeopleVaccianted
from PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from Percentpopulationvaccinated