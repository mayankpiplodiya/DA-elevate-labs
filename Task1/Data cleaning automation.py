import pandas as pd
import numpy as np

# Load dataset
df = pd.read_csv("netflix_titles.csv")

# Make RAW backup
raw_backup = df.copy()


# STEP 3 – Missing Values

missing_report = df.isnull().sum()

# Replace missing based on context
df['director'] = df['director'].fillna("Unknown")
df['cast'] = df['cast'].fillna("Not Available")
df['country'] = df['country'].fillna("Not Specified")

# Drop rows where title is missing (critical column)
df = df.dropna(subset=['title'])


# STEP 4 – Remove Duplicates

df_before = len(df)
df = df.drop_duplicates(subset=['title'])
df_after = len(df)


# STEP 5 – Text Standardization

text_columns = ['title', 'director', 'country', 'rating', 'type']

for col in text_columns:
    df[col] = df[col].astype(str).str.strip()
    df[col] = df[col].str.title()


# STEP 6 – Format Validation


# Convert date_added to YYYY-MM-DD
df['date_added'] = pd.to_datetime(df['date_added'], errors='coerce')

# Convert release_year to numeric
df['release_year'] = pd.to_numeric(df['release_year'], errors='coerce')

# Fix rating inconsistencies
df['rating'] = df['rating'].replace({
    "Tv-Ma": "TV-MA",
    "Tv-14": "TV-14"
})


# STEP 7 – Cleaned Data Sheet

cleaned_df = df.copy()


# STEP 8 – Data Quality Notes

notes = []

if raw_backup['director'].isnull().sum() > 0:
    notes.append("Missing director names present")

if raw_backup.duplicated(subset=['title']).sum() > 0:
    notes.append("Duplicate titles found and removed")

if raw_backup['rating'].nunique() != cleaned_df['rating'].nunique():
    notes.append("Rating values inconsistent")

cleaned_df['Data_Quality_Notes'] = "; ".join(notes)


# STEP 9 – Save Outputs

# Save Excel with multiple sheets
with pd.ExcelWriter("Cleaned_dataset.xlsx", engine='openpyxl') as writer:
    raw_backup.to_excel(writer, sheet_name="Raw_Data", index=False)
    cleaned_df.to_excel(writer, sheet_name="Cleaned_Data", index=False)

# Save CSV
cleaned_df.to_csv("cleaned_dataset.csv", index=False)

print(" Data Cleaning Completed Successfully")
print(" Files Created:")
print(" - Cleaned_dataset.xlsx")
print(" - cleaned_dataset.csv")
