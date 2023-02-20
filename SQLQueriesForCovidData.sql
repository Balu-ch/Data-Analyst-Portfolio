
/*------------------- Covid Death Data ------------*/

-- Selecting the fields.
select Location, Date,Population, new_cases, Total_Cases, Total_Deaths
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null
order by 1,2

-- Total deaths compared to total Cases Percentage.
select Location, Date,Population, Total_Cases, Total_Deaths, (Total_deaths/Total_cases)* 100 as Death_Percentage
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null
order by 1,2


-- Death percentage of Indian Cases.
select Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)* 100 as Death_Percentage
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null and  location ='india'
order by 1,2


--	Infection rate of Indian Population.
select Location, Date, Population, Total_Cases, (Total_Cases/Population)* 100 as Infection_Rate
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null and location ='india'
order by 1,2

--	Total population compared to total deaths.
select  Location, Date, Total_Cases, Total_Deaths, Population, (total_deaths/population)* 100 as death_percentage
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null and location ='india'
order by 1,2


--	Highest Infection Rate Compared to Population.
select  Location,Population, MAX(Total_Cases) As HighestCases, MAX((total_cases/population))* 100 as Highest_Infection_Rate
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null
group by location,population
order by Highest_Infection_Rate desc


--	Highest Death Rate Compared to Population.
select  Location,Population, MAX(Total_deaths) As Highestdeaths, MAX((total_deaths/population))* 100 as Highest_Death_Rate
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null
group by location,population
order by Highest_Death_Rate desc


-- Top 5 Countries with Highest Infection Rate Compared to Population.
select top 5 * From(
select  Location,Population, MAX(Total_Cases) As HighestCases, MAX(total_cases/population)* 100  as Highest_Infection_Rate
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not Null
group by location,population) Demo
order by Demo.Highest_Infection_Rate desc


-- Top 5 Countries with Highest Death Rate Compared to Population.
Select Top 5 *  from(
select location, population, MAX(total_deaths) As HighestDeaths , Max((total_deaths/population))*100 As Highest_Death_Rate
from CovidDeaths
where continent is not null
group by location , population ) Demo
order by Demo.Highest_Death_Rate desc



/*-------------- Lets Check The Continent Death Ratio ----------------*/

-- Total Death count of Each Continent.
-- The data type of deaths is nvarchar.
Select Continent, Max(cast(total_deaths as bigint)) As Total_Death_Count  
from CovidPortfolioProject.dbo.CovidDeaths
Where continent is not null 
group by continent 
order by Total_Death_Count desc


-- Total Death count of Additional locations.
Select location, Max(cast(total_deaths as bigint)) As Total_Death_Count  
from CovidPortfolioProject.dbo.CovidDeaths
Where continent is null and location not like '%income%'
group by location 
order by Total_Death_Count desc



-- Global Index
Select date, Sum(new_cases) As DailyCases , Sum(cast (new_deaths as int)) as DailyDeaths ,
Sum(cast (new_deaths as int))/Sum(new_cases) *100 as DailyDeathPercentage
from CovidPortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by date


/* ------------- Covid Vaccination Data ------------------*/

--Global Deaths and Cases
select   Sum(Convert(bigint,new_deaths)) as globalDeaths , Sum(new_cases) as globalCases,
Sum(Convert(bigint,new_Deaths))/Sum(new_cases)*100	as GlobalDeathRatio
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccines  vac 
on dea.location =vac.location and dea.date =vac.date
where dea.continent is not null 



-- Total vaccinations for each Country 

Select dea.continent,dea.location, dea.date, new_vaccinations,
SUM(cast (new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as Total_Vaccinations_Data
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccines  vac 
on dea.location =vac.location and dea.date =vac.date
where dea.continent is not null 
order by 1,2,3


/*---------------------------- CTE's ----------------*/

--Total vaccinations VS Population Using CTE

With PopVsVac as
(
Select dea.continent,dea.location, dea.date, dea.population, new_vaccinations,
SUM(cast (new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as Total_Vaccinations_Data
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccines  vac 
on dea.location =vac.location and dea.date =vac.date
where dea.continent is not null 
--order by 1,2,3
)

Select *, (Total_Vaccinations_Data/population)*100 as Per_Vac_People
from PopVsVac where location = 'India'
order by 1,2,3



---- Raw data of indian vaccination 
--Select dea.location, dea.date,total_deaths, total_cases, new_vaccinations,
--sum(Convert(int,new_vaccinations)) over(partition by dea.location order by dea.location , dea.date)	TotalVaccinesTillday
--from CovidPortfolioProject..CovidDeaths dea
--join CovidPortfolioProject..CovidVaccines  vac 
--on dea.location =vac.location and dea.date =vac.date
--where dea.location ='india'
--order by 1,2

--Select  location,date, new_vaccinations, total_vaccinations, total_boosters,
--sum(Convert(int,new_vaccinations))  over(partition by location order by location,date) as VaccinationsSum  
--from CovidVaccines	where location ='india' 

--select * from CovidVaccines where location ='india' order by date




/*-------------------------- Temp Table -----------------*/

Drop table if Exists #PercentageVaccinatedPopulation
Create Table #PercentageVaccinatedPopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
Total_Vaccinations_Data numeric,
)

Insert into #PercentageVaccinatedPopulation

Select dea.continent,dea.location, dea.date, dea.population, new_vaccinations,
SUM(cast (new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as Total_Vaccinations_Data
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccines  vac 
on dea.location =vac.location and dea.date =vac.date
--where dea.continent is not null 
--order by 1,2,3


Select *, (Total_Vaccinations_Data/population)*100 as Per_Vac_People
from #PercentageVaccinatedPopulation
order by 1,2,3


/*-------------------- Views -----------------------*/

--Creating Views to store data for Visualizations later

Create View	PercentageVaccinatedPopulation as
Select dea.continent,dea.location, dea.date, dea.population, new_vaccinations,
SUM(cast (new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as Total_Vaccinations_Data
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccines  vac 
on dea.location =vac.location and dea.date =vac.date
where dea.continent is not null 
--order by 1,2,3


select * from PercentageVaccinatedPopulation order by Location