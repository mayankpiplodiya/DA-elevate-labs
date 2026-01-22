Data Cleaning Steps Applied

1. Loaded the Titanic dataset using pandas.
2. Inspected structure and missing values using  '.info()' and '.isnull().sum()'.
3. Dropped the 'Cabin' column due to excessive missing values.
4. Filled missing 'Age' values using median and 'Embarked' using mode.
5. Removed duplicate rows to ensure data quality.
6. Converted data types where required for accurate computation.
7. Created new features such as Age Category and Fare Band for better analysis.
8. Saved the cleaned dataset for reproducibility and further modeling.
