select *
from [portfolio project].dbo.[covid deaths]
where continent is not null
order by 3,4

select *
from [portfolio project].dbo.[covid vaccinations]
where continent is not null
order by 3,4

select Location,date,population,total_cases,new_cases,total_deaths
from [portfolio project].dbo.[covid deaths]
where continent is not null
order by 1,2
 
-- Total cases vs Total death

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [portfolio project].dbo.[covid deaths]
where location like '%india%'
and continent is not null
order by 1,2

--total cases vs population

select Location,date,total_cases,population,(total_cases/population)*100 as infectedpercentage
from [portfolio project].dbo.[covid deaths]
where location like '%india%'
where continent is not null
order by 1,2

--countries with highest infection rate compared to population

select Location,max(total_cases) as highestcount,population,max(total_cases/population)*100 as populationinfected
from [portfolio project].dbo.[covid deaths]
group by location,population
order by populationinfected desc
 
 --countries with highest deathcount with population

 select Location,max(total_deaths) as totaldeathcount
from [portfolio project].dbo.[covid deaths]
where continent is not null
group by location
order by totaldeathcount desc

-- death count by continent

 select continent, max(total_deaths) as totaldeathcount
from [portfolio project].dbo.[covid deaths]
where continent is not null
Group by continent
order by totaldeathcount desc

--continent with highest death rate by population

 select continent,location, max(total_deaths) as totaldeathcount,population,((max(total_deaths))/population)*100 as deathcountrate
from [portfolio project].dbo.[covid deaths]
where continent is not null
Group by continent,population,location
order by deathcountrate desc

--global
select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeath,(sum(cast(new_deaths as int))/(sum(new_cases)))*100 as deathpercentage
from [portfolio project].dbo.[covid deaths]
where  continent is not null
order by deathpercentage desc

-- total vaccinations vs population

select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date) as rollingpeoplevaccinated
from [portfolio project].dbo.[covid deaths] dea
join [portfolio project].dbo.[covid vaccinations] vac
 on  dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 --total population vs vaccinations

 select dea.date,dea.location,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) 
 over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [portfolio project].dbo.[covid deaths] dea
join [portfolio project].dbo.[covid vaccinations] vac
 on  dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3
  
  --using cte
with PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [portfolio project].dbo.[covid deaths] dea
join [portfolio project].dbo.[covid vaccinations] vac
 on  dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select*, (rollingpeoplevaccinated/population)*100
 from PopvsVac

 --Temp table
drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
( continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [portfolio project].dbo.[covid deaths] dea
join [portfolio project].dbo.[covid vaccinations] vac
 on  dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 select*, (rollingpeoplevaccinated/population)*100
 from #percentpopulationvaccinated

 --creating view
drop view ppv
create view ppv as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [portfolio project].dbo.[covid deaths] dea
join [portfolio project].dbo.[covid vaccinations] vac
 on  dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 --select*, (rollingpeoplevaccinated/population)*100
 --from #percentpopulationvaccinated
 select * from ppv






