SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

--Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--looking at Total Cases VS Total Deaths
--show likelihood of dying if you contract covid in your country

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_deaths float;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location like 'egypt'
ORDER BY 1,2

--looking at the Total Cases VS Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percent_Population_Infected
FROM CovidDeaths
--WHERE location like 'egypt'
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at countries with highest infection rate VS popultaion

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS Percent_Population_Infected
FROM CovidDeaths
--WHERE location like 'egypt'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY Percent_Population_Infected DESC

--Showing the countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL -- Because some records in Country is a continent
GROUP BY Location
ORDER BY Total_Death_Count DESC


--Showing the continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL -- Because some records in Country is a continent
GROUP BY continent
ORDER BY Total_Death_Count DESC


--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--join the two tables

SELECT *
FROM CovidDeaths
JOIN CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   AND CovidDeaths.date = CovidVaccinations.date

 --Looking at Total Population VS Vaccination
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
FROM CovidDeaths
JOIN CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   AND CovidDeaths.date = CovidVaccinations.date
 WHERE CovidDeaths.continent is NOT NULL
 ORDER by 2,3



 SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
 SUM(CAST(CovidVaccinations.new_vaccinations as float)) OVER (Partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS Rolling_People_Vaccinated
FROM CovidDeaths
JOIN CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   AND CovidDeaths.date = CovidVaccinations.date
 WHERE CovidDeaths.continent is NOT NULL
 ORDER by 2,3

 -- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
 SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
 SUM(CAST(CovidVaccinations.new_vaccinations as float)) OVER (Partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS Rolling_People_Vaccinated
FROM CovidDeaths
JOIN CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is NOT NULL
 --ORDER by 2,3
 )
 SELECT *, (Rolling_People_Vaccinated/Population)*100
 FROM PopvsVac