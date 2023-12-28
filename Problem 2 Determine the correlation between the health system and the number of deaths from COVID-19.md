
# Problem 2: determine the correlation between the health system and the number of deaths from COVID-19

To handle this problem, I will use two columns in the dataset, icu_patients and hosp_patients. Icu_patients is Number of COVID-19 patients in intensive care units (ICUs) on a given day, and hosp_patients is Number of COVID-19 patients in hospital on a given day.
When looking at the data overview, I noticed that only a few countries collect data on these two variables. So I will use SQL to write a query to get data from these countries, and also get data about the number of new deaths per day, and the time.

```
#SQL
SELECT date, location, new_deaths, icu_patients, hosp_patients
FROM PortfolioProject..CovidDeathsdata
WHERE (icu_patients is not NULL
	OR hosp_patients is not NULL)
	AND continent is not NULL
ORDER BY location, date

```
Then to verify the impact of the two variables icu_patients and hosp_patients on the variable new_deaths. I will import the data into Rstudio and then write the code
```
#R
library(readxl)
Covid_problem2 <- read_excel("C:/Users/User/Documents/Covid_problem2.xlsx")



# Fit a multiple regression model
model <- lm(new_deaths ~ icu_patients + hosp_patients, data = Covid_problem2)

# Print the summary of the regression model
summary(model)
```
![Screenshot 2023-12-28 235105](https://github.com/VietHung29/Covid-project/assets/90827309/e2d7633f-2c68-4795-86fe-f9bd27bb2d96)
```
# Extract coefficients and p-values
coefficients <- coef(model)
p_values <- summary(model)$coefficients[, 4]

# Print coefficients and p-values
cat("Coefficients:\n")
print(coefficients)
```
![Screenshot 2023-12-28 235147](https://github.com/VietHung29/Covid-project/assets/90827309/5f709cd2-0fe6-4d13-b3c1-11a424d00c94)
```
cat("\nP-values:\n")
print(p_values)
```
![Screenshot 2023-12-28 235156](https://github.com/VietHung29/Covid-project/assets/90827309/5d5c4dac-1b07-4f2e-a9c1-4b8a92848f3a)

The p-values for each coefficient ((Intercept), icu_patients, hosp_patients) are extracted and printed separately.

In this case, the p-values for icu_patients and hosp_patients are very close to zero (scientific notation: <2e-16), indicating that both variables are highly statistically significant in predicting new_deaths.

The p-value for the (Intercept) is 0.2548, which is greater than the commonly used significance level of 0.05. This suggests that the intercept is not statistically significant.

In conclusion, based on these results, both icu_patients and hosp_patients are strongly associated with new_deaths.