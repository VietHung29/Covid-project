
# Problem 3: Providing a projection for the number of fatalities expected to result from the COVID-19 pandemic in the future. 


```
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn import model_selection
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

```

```
from google.colab import drive
drive.mount('/content/drive')
```
```
from google.colab import files
uploaded = files.upload()
```
```
data = pd.read_excel('/content/CovidDeathsdata.xlsx')

```
```
data.dropna(subset=['total_vaccinations'], inplace=True)
data.dropna(subset=['new_cases'], inplace=True)
data.dropna(subset=['stringency_index'], inplace=True)
data.dropna(subset=['human_development_index'], inplace=True)
data.dropna(subset=['new_deaths'], inplace=True)
```
```
# Choose relevant features (independent variables) for prediction
# Here, we select 'total_cases', 'total_deaths', 'icu_patients', 'total_vaccinations', 'hosp_patients', 'population', 'population_density'
#features = ['total_cases', 'total_deaths', 'icu_patients', 'total_vaccinations', 'hosp_patients', 'population', 'population_density']
features = ["new_cases","total_vaccinations","stringency_index","human_development_index"]
X = data[features]
print(X.shape)



# Target variable (dependent variable) is 'new_deaths'
y = data['new_deaths']

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Create a linear regression model
model = LinearRegression()

# Train the model
model.fit(X_train, y_train)

# Make predictions on the test set
y_pred = model.predict(X_test)

# Evaluate the model
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f'Mean Squared Error: {mse}')
print(f'R-squared: {r2}')

# Visualize predicted vs actual values
plt.scatter(y_test, y_pred)
plt.xlabel('Actual New Cases')
plt.ylabel('Predicted New Deaths')
plt.title('Actual vs Predicted New Deaths')
plt.show()
```