
# Problem 1: Determining the correlation between the number of people vaccinated and the number of people dying each day from covid-19

To solve this problem, I will using SQL to query to get data comparing the trend of the number of vaccines administered and the number of new deaths each day.
By December 2020, the new covid-19 vaccine was licensed and started to be used in some countries. However, by querying, I found that 198 countries have been affected by the epidemic.

```
SELECT location, total_cases
FROM PortfolioProject..CovidDeaths
WHERE	date = '2020-12-30'
		AND total_cases != 0
		AND location is not NULL
GROUP BY location, total_cases

```
Therefore, getting data from all countries will not be accurate. So I'll do a query to identify the top 5 most vaccinated countries and compare.

First I will create a temporary table to import data from the two tables CovidDeaths and CovidVaccinations together.
```
WITH deavac AS (SELECT dea.date, dea.location,
				CASE WHEN total_cases is NULL THEN 0
				ELSE total_cases END AS total_cases,
				CASE WHEN new_deaths is NULL THEN 0
				 ELSE new_deaths END AS new_deaths,
				CASE WHEN total_vaccinations is NULL THEN 0
				ELSE total_vaccinations END AS total_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL)

```
Subsequently, a query will be executed to ascertain the top 5 countries leading in vaccination rates.

```
SELECT location, MAX(total_vaccinations) AS total_vaccinations
FROM deavac
GROUP BY location
ORDER BY total_vaccinations DESC

```

![Screenshot 2023-12-26 213959](https://github.com/VietHung29/Covid-project/assets/90827309/b6e47b2f-f8f5-4f0d-a4b7-8f486a4861e6)
The findings revealed that the top 5 countries in terms of vaccination are "China, United States, India, United Kingdom, Brazil." Following this, a query will be conducted to extract data encompassing the date, country, daily new death figures, and the cumulative total of daily vaccinated individuals.

```
SELECT date, location, new_deaths, total_vaccinations
FROM deavac
WHERE location IN ('China', 'United States', 'India', 'United Kingdom','Brazil')
ORDER BY location, date

```
Next I will import this data into Microsoft Excel, then Import into Power BI.
![Screenshot 2023-12-26 215339](https://github.com/VietHung29/Covid-project/assets/90827309/b2384dfd-70d5-4008-b026-9a4621d64577)
![Screenshot 2023-12-26 221316](https://github.com/VietHung29/Covid-project/assets/90827309/01cab86b-77de-4c10-a155-9f7bb831f3a8)
![Screenshot 2023-12-26 221413](https://github.com/VietHung29/Covid-project/assets/90827309/755d1b41-0c2f-488f-887a-3c25d57252cc)
![Screenshot 2023-12-26 221523](https://github.com/VietHung29/Covid-project/assets/90827309/341ea98b-c8d2-4683-862a-86ae4f89764d)
![Screenshot 2023-12-26 221610](https://github.com/VietHung29/Covid-project/assets/90827309/44026e6d-db92-4282-8ceb-ac27dd9bb6a1)

Examination of the resultant chart indicates a negative correlation in the United Kingdom and the United States. Conversely, in China, there appears to be no discernible correlation, while in Brazil and India, a positive correlation is evident. This observation prompted an exploration of historical data. The results showed that the main reason why the daily death toll in India increased was because many people stopped following the COVID-19 protocols, such as wearing masks, maintaining social distance, and avoiding large gatherings. The festival season, the election campaigns, and the religious events also contributed to the spread of the virus. The same reason also causes the death toll in Brazil to increase

In conclusion, there is a negative correlation between the number of vaccines administered and the number of new deaths per day. However, that is not the biggest impact factor in reducing the number of deaths
