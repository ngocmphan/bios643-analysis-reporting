This document outlines the systematic cleaning and processing of the longitudinal health study datasets, including cohort demographics, clinical outcomes (ICD codes), and residential history.

# Environment and Data Initialization
The analysis utilizes the tidyverse ecosystem for data manipulation, rio for versatile file importing, and janitor for automated column name standardization.

Software Dependencies: rio, here, tidyverse, janitor. 

Source Files:

cohort-data.csv: Primary participant demographics and study entry dates.

icd-data.csv: Longitudinal Electronic Health Records (EHR) containing diagnosis codes.

residential-data.csv: Historical residential periods for exposure assessment.

# Cohort Data Cleaning
The cohort data underwent significant transformation to ensure categorical consistency and date format inconsistencies. 

Columns renamed: Variables were renamed for clarity (e.g., SEX (1=MALE) to sex) and converted to lower case for consistency.

Deduplication: Applied a strict distinct() filter to remove any identical record repeats across the ID variable.

Date Normalization: Handled inconsistent date formatting for both Entry_date and date_loss_to_followup

- Parsing standard MM/DD/YYYY strings.

- Converting numeric Excel serial dates using the established study origin (1959-05-17).

Outlier Management: An "Age" value of 345 was identified as a data entry error and recoded to NA to prevent skewing statistical models.

Smoking variable inconsistent values between "Former" or "former". Values of the variable are transformed to all lower cases. 
Feature Engineering:

- Sex: Recoded from 1/0 to "Male"/"Female".

- Age Category: Grouped into bins: Under 40, 40-49, 50-59, 60-69, and 70+.

- BMI Category: Classified according to WHO standards (Underweight, Normal, Overweight, Obese).


# Clinical Data Processing (ICD)
The ICD dataset was transformed from a long-format longitudinal record into a wide-format summary of the relevant health issues in the study. 

Disease Categorization: Utilized case-insensitive string detection to identify four key health outcomes: Asthma, Diabetes, Hypertension, and COPD.

Date relevant to the study: For each participant and disease, only the min(icd_date) (first occurrence) was retained to define the onset of the condition.

Binary encoding: Created indicator variables (1/0) for each disease category. A value of 1 indicates the presence of that condition in the participant's history.

All the column names were standardized to lower cases. 

# Residential Exposure Modeling
This step processes residential history to prepare for air quality exposure calculations. The study requires a 10-year lookback window from the date of study entry.

Window Definition: A rolling 10-year window was established for every participant by the entry cohort date, and entry_date - 10 years.

Cut-off window per individual: Residential periods were "clipped" to fit strictly within this window using pmax and pmin.

For example, if a person lived in a house for 20 years, only the 10 years relevant to the study window were counted.

Weighted Exposure Calculation: * Calculated days_in_window using difftime.

Calculated exposure_weight by dividing the days spent in a specific county by 3,650 (the approximate number of days in 10 years).

Interpretation: A weighted_exp of ~1.000 indicates a participant has a complete 10-year residential history documented in the dataset.

All the column names were standardized to lower cases. 


# Final Dataset Integration
The final master dataset was constructed using a series of Left Joins, with main file as the clean_cohort data.

Main file: clean_cohort (Ensures all recruited participants are present).

Merge 1: Joined clean_icd to add baseline health status.

Merge 2: Joined clean_res to add the 10-year cumulative exposure weights.