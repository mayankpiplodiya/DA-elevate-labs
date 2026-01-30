Insights:

1-The dataset was first loaded and inspected using shape, info, and head functions to understand the number of records, data types, and overall structure of the data.

2-Descriptive statistics were generated to analyze central tendency and dispersion, helping identify the range, average values, and variability of numerical features.

3-Missing values were calculated as percentages for each column to assess data quality and determine whether imputation or removal would be required.

4-Data distributions were visualized using histograms and boxplots to observe skewness, spread, and the presence of extreme values.

5-Outliers were detected using the Interquartile Range (IQR) method, which is effective for identifying anomalies in both symmetric and skewed distributions.

6-The number of outliers in each numerical column was calculated to identify features most affected by extreme values.

7-An outlier flag column was created to mark records containing at least one outlier, enabling easier tracking and analysis of anomalous observations.

8-Outliers were handled using capping rather than removal to prevent data loss while maintaining the overall statistical characteristics of the dataset.

9-A correlation matrix was generated to identify strong relationships between numerical variables and to detect potential multicollinearity issues.

10-The cleaned dataset was exported for further analysis or machine learning tasks, ensuring a reproducible and well-documented data preprocessing workflow.
