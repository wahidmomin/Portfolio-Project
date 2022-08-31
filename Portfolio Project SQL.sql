SELECT *
FROM CovidDeaths_csv
WHERE continent is not null
order by 3, 4;

-- Select Data that we are going to be using --


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths_csv 
order by 1, 2 ;


-- Looking at Total Cases vs Total Deaths--
SELECT location, date, total_cases,total_deaths, CAST (total_deaths as REAL)/ total_cases *100 as DeathPercentage
FROM CovidDeaths_csv 
WHERE location LIKE '%states%'
order by 1, 2 ;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid--
SELECT location, date, total_cases, population , CAST (total_cases as REAL)/ population *100 as PercentagePopulationInfected
FROM CovidDeaths_csv 
WHERE location LIKE '%states%'
order by 1, 2 


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location ,population , MAX(total_cases) as HighestInfectionCount, Max (CAST (total_cases as REAL)/ population) *100 as PercentagePopulationInfected
FROM CovidDeaths_csv 
Group by location, population 
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population--

SELECT location , MAX(cast(total_deaths as bigint))  as TotalDeathCount
FROM CovidDeaths_csv 
WHERE continent is not null  
Group by location
order by TotalDeathCount desc 

--Breaking things by Continent--
SELECT location  , MAX(cast(total_deaths as bigint))  as TotalDeathCount
FROM CovidDeaths_csv 
WHERE continent is not null 
Group by location  
order by TotalDeathCount desc 

--without world--

SELECT continent , MAX(cast(total_deaths as bigint))  as TotalDeathCount
FROM CovidDeaths_csv 
where continent is not NULL 
Group by continent  
order by TotalDeathCount desc 

-- Showing Continents with Highest Death Count 

SELECT continent  , MAX(cast(total_deaths as bigint))  as TotalDeathCount
FROM CovidDeaths_csv 
WHERE continent is not null 
Group by continent  
order by TotalDeathCount desc 



-- Global Numbers--
SELECT  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/ Sum(new_cases) *100  as DeathPercentage
FROM CovidDeaths_csv 
--wHERE location like '%states%'
WHERE continent is not null 
--Group by date 
order by 1 , 2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations
, SUM(CAST (cv.new_vaccinations as int)) Over (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from CovidDeaths_csv dea  
Join CovidVaccinations cv  
	On dea.location  = cv.location 
	and dea.date = cv. date 
where dea.continent is not null 
order by  2, 3 

-- USE CTE 

WITH PopvsVac (continent , location , Date, Population, new_vaccinations , RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations
, SUM(CAST (cv.new_vaccinations as int)) Over (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths_csv dea  
Join CovidVaccinations cv  
	On dea.location  = cv.location 
	and dea.date = cv. date 
where dea.continent is not null 
--order by  2, 3 
)
SELECT *, ( RollingPeopleVaccinated / population) *100
FROM PopvsVac 

-- Temp Table--


CREATE Temp TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into  PercentPopulationVaccinated
WITH PopvsVac (continent , location , Date, Population, new_vaccinations ,RollingPeopleVaccinated  )
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations, SUM(CAST (cv.new_vaccinations as int)) Over (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 

from CovidDeaths_csv dea  
Join CovidVaccinations cv  
	On dea.location  = cv.location 
	and dea.date = cv. date 
where dea.continent is not null 

)
SELECT *, ( RollingPeopleVaccinated / population ) *100
FROM PercentPopulationVaccinated 


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations
, SUM(CAST (cv.new_vaccinations as int)) Over (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths_csv dea  
Join CovidVaccinations cv  
	On dea.location  = cv.location 
	and dea.date = cv. date 
where dea.continent is not null 
--order by  2, 3 

SELECT *

From PercentPopulationVaccinated 