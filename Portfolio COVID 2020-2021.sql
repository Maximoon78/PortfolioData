select location, AVG(total_deaths/total_cases *100) as death_percentage
from CovidDeaths
where location = 'Indonesia'
group by location
order by 1,2

select top 10 location, population,MAX(total_cases) as cases_percentage, MAX(total_cases/population *100) as population_infected
from CovidDeaths
--where location = 'Indonesia'
group by location, population
order by population_infected desc


-- top 20 location with the most death
select*, (x.deaths/x.population *100) as death_percentage
from(
select top 20 location, population,MAX(cast(total_deaths as int)) as deaths
from CovidDeaths
where continent is not null
group by location, population
order by deaths desc) x




-- Date with the higest death_percentage
select top 1 date, sum(new_cases)as new_case, sum(cast(new_deaths as int))as new_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidDeaths
where continent is not null
group by date
order by death_percentage desc

-- month with the highest death_percentage
Select 
    year,
    month,
    MAX(death_percentage) AS highest_death_percentage
FROM (
    SELECT
        YEAR(date) AS year,
        MONTH(date) AS month,
        sum(new_cases)as new_case,
        sum(cast(new_deaths as int))as new_death,
        sum(cast(new_deaths as int)) / NULLIF(SUM(new_cases) *100, 0) AS death_percentage
    FROM
        CovidDeaths
    GROUP BY
        YEAR(date), MONTH(date)
)x
GROUP BY x.year, x.month
 order by highest_death_percentage DESC
 

 -- total vaccinations per day
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 sum(cast (cv.new_vaccinations as int)) over (partition by cd.location order by cd.date) as total_vaccinations
 from CovidDeaths cd
 left join CovidVaccinations cv
 on cd.location = cv.location
 and cd. date = cv. date
 where cd.continent is not null
 order by 2,3


  -- total vaccinations per day (variation 1st subquery)
 select 
	*,(x.total_vaccinations / x.population *100) as vaccination_percentage
 from(
	select 
		cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		sum(cast (cv.new_vaccinations as int)) over (partition by cd.location order by cd.date) as total_vaccinations
	from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
 --order by 2,3
	)x


	 -- total vaccinations per day (variation 2nd cte)
 with VacvsPop as(
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(CONVERT (int, cv.new_vaccinations)) over (partition by cd.location order by cd.date) as total_vaccinations
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
 --order by 2,3
 )
 select 
	*, (total_vaccinations/population *100) as vaccinations_percentage
 from VacvsPop
 order by 2,3
 

 -- number of days before the first vaccination
 with FirstNonNullDate as (
    select
        location,
        MIN(date) AS first_non_null_date
    from
        CovidDeaths
    where
        new_vaccinations IS NOT NULL
    group by
        location
)
select
    cd.location,
    COUNT(*) AS days_before_vaccination
from
    CovidDeaths cd
	JOIN FirstNonNullDate fnd
		on cd.location = fnd.location
	where
		cd.new_vaccinations IS NULL
    AND cd.date < fnd.first_non_null_date
group by
    cd.location
	order by 2 desc


 -- Creating temp table
 drop table if exists PercentPopulationVaccinated
 create table PercentPopulationVaccinated(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_vaccinations numeric,
)

 insert into PercentPopulationVaccinated
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(CONVERT (int, cv.new_vaccinations)) over (partition by cd.location order by cd.date) as total_vaccinations
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	--where cd.continent is not null
 --order by 2,3
 
 select 
	*, (total_vaccinations/population *100) as vaccinations_percentage
 from 
	PercentPopulationVaccinated








	-- creating view for data visualization
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(CONVERT (int, cv.new_vaccinations)) over (partition by cd.location order by cd.date) as total_vaccinations
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
 --order by 2,3

 create view HighestDeathinMonth as
 Select 
    year,
    month,
    MAX(death_percentage) AS highest_death_percentage
FROM (
    SELECT
        YEAR(date) AS year,
        MONTH(date) AS month,
        sum(new_cases)as new_case,
        sum(cast(new_deaths as int))as new_death,
        sum(cast(new_deaths as int)) / NULLIF(SUM(new_cases) *100, 0) AS death_percentage
    FROM
        CovidDeaths
    GROUP BY
        YEAR(date), MONTH(date)
)x
GROUP BY x.year, x.month
 --order by highest_death_percentage DESC

  create view Location_with_most_death as
select*, (x.deaths/x.population *100) as death_percentage
from(
select location, population,MAX(cast(total_deaths as int)) as deaths
from CovidDeaths
where continent is not null
group by location, population
) x

create view days_before_vaccination as
WITH FirstNonNullDate AS (
    SELECT
        location,
        MIN(date) AS first_non_null_date
    FROM
        CovidDeaths
    WHERE
        new_vaccinations IS NOT NULL
    GROUP BY
        location
)

SELECT
    cd.location,
    COUNT(*) AS days_before_vaccination
FROM
    CovidDeaths cd
JOIN
    FirstNonNullDate fnd
ON
    cd.location = fnd.location
WHERE
    cd.new_vaccinations IS NULL
    AND cd.date < fnd.first_non_null_date
GROUP BY
    cd.location
	










select cd.location, cd.date, cd.total_cases,cd.total_deaths, cd.median_age, cd.aged_65_older,cd.aged_70_older
 from CovidDeaths cd
	left join CovidVaccinations cv
	on cd.location = cv.location
	and cd. date = cv. date
	where cd.continent is not null
	order by cd.median_age desc

	select * from CovidDeaths