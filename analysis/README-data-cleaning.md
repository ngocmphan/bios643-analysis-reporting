This document outlines the systematic cleaning and processing of the longitudinal health study datasets, including cohort demographics, clinical outcomes (ICD codes), and residential history.

# Environment and Data Initialization
The analysis utilizes the tidyverse ecosystem for data manipulation, rio for versatile file importing, and janitor for automated column name standardization.

Software Dependencies: rio, here, tidyverse, janitor. 

Source Files:

cohort-data.csv: Primary participant demographics and study entry dates.

icd-data.csv: Longitudinal Electronic Health Records (EHR) containing diagnosis codes.

residential-data.csv: Historical residential periods for exposure assessment.

# Cohort Data Cleaning
The cohort data underwent significant transformation to ensure categorical consistency and to handle technical data artifacts (e.g., Excel date serials).

Schema Standardization: Variables were renamed for clarity (e.g., SEX (1=MALE) to sex) and converted to snake_case.

Deduplication: Applied a strict distinct() filter to remove any identical record repeats across the ID variable.

Date Normalization: Handled inconsistent date formatting by:

- Parsing standard MM/DD/YYYY strings.

- Converting numeric Excel serial dates using the established study origin (1959-05-17).

Outlier Management: An "Age" value of 345 was identified as a data entry error and recoded to NA to prevent skewing statistical models.

Feature Engineering:

- Sex: Recoded from 1/0 to "Male"/"Female".

- Age Category: Grouped into bins: Under 40, 40-49, 50-59, 60-69, and 70+.

- BMI Category: Classified according to WHO standards (Underweight, Normal, Overweight, Obese).


# Clinical Data Processing (ICD)
The ICD dataset was transformed from a long-format longitudinal record into a wide-format summary of baseline comorbidities.

Disease Categorization: Utilized case-insensitive string detection to identify four key health outcomes: Asthma, Diabetes, Hypertension, and COPD.

Temporal Collapsing: For each participant and disease, only the min(icd_date) (first occurrence) was retained to define the onset of the condition.

Binary encoding: Created indicator variables (1/0) for each disease category. A value of 1 indicates the presence of that condition in the participant's history.


# Residential Exposure Modeling
This step processes residential history to prepare for air quality exposure calculations. The study requires a 10-year lookback window from the date of study entry.

Window Definition: A rolling 10-year window was established for every participant (entry_date minus 10 years).

Cut-off window per individual: Residential periods were "clipped" to fit strictly within this window using pmax and pmin.

If a person lived in a house for 20 years, only the 10 years relevant to the study window were counted.

Weighted Exposure Calculation: * Calculated days_in_window using difftime.

Calculated exposure_weight by dividing the days spent in a specific county by 3,650 (the approximate number of days in 10 years).

Interpretation: A weighted_exp of ~1.000 indicates a participant has a complete 10-year residential history documented in the dataset.


# Final Dataset Integration
The final master dataset was constructed using a series of Left Joins, with main file as the clean_cohort data.

Main file: clean_cohort (Ensures all recruited participants are present).

Merge 1: Joined clean_icd to add baseline health status.

Merge 2: Joined clean_res to add the 10-year cumulative exposure weights.