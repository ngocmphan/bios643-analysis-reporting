# data imports
pacman::p_load(rio, here, tidyverse, janitor)

cohort_data <- import(here("data", "cohort-data.csv"))
icd <- import(here("data", "icd-data.csv"))
residential <- import(here("data", "residential-data.csv"))


# data view

## Review data for cohort_data
summary(cohort_data)
str(cohort_data)
skimr::skim(cohort_data)

## Review data for icd
summary(icd)
str(icd)
skimr::skim(icd)

## Review data for residential
summary(residential)
str(residential)
skimr::skim(residential)


# Data cleaning

## cohort data cleaning
clean_cohort <- cohort_data %>%
  # Standardize column names to lower cases, rename sex variable
  rename(sex = `SEX (1=MALE)`, 
         entry_date = entrydate, 
         smoking_status = SMOKE, 
         loss_to_followup_date = DATE_losstofollowup) %>%
  clean_names() %>%

  
  # Remove duplicated records (ID variable)
  distinct() %>%
  
  # Standardize the values of categorical variables: smoke (ex: Former or former), socioeconomic_status
  mutate(
    smoking_status = str_to_lower(smoking_status), 
    socioeconomic_status = str_to_lower(socioeconomic_status)
  ) %>%
  
  # Standardize the dates for entry_date and loss_to_followup_date to format (MM/DD/YYYY)
  mutate(across(c(entry_date, loss_to_followup_date), ~ {
    case_when(
      str_detect(., "/") ~ mdy(.), # Parse standard strings
      TRUE ~ as.Date(as.numeric(.), origin = "1959-05-17") # Parse Excel serials
    )
  })) %>%
  
  # outlier data: Age value of 345 as NA
  mutate(age = if_else(age > 110, NA_real_, as.numeric(age))) %>%
  
  # recode and categorical variables
  ## Sex: 1 - male, 0 - Female
  ## Age_category: under 40, 40-49, 50-59, 60-69, 70+
  ## BMI_category: < 18.5 - Underweight, 18.5 - 24 - Normal weight, 25 -29 - Overweight, 30+ - Obese
  mutate(sex = case_when(
    sex == 1 ~ "Male",
    sex == 0 ~ "Female"
  )) %>%
  
  mutate(age_category = case_when(
    age < 40 ~ "Under 40",
    age >= 40 & age <= 49 ~ "40-49",
    age >= 50 & age <= 59 ~ "50-59",
    age >= 60 & age <= 69 ~ "60-69",
    age >= 70 ~ "70+"
  )) %>%
  
  
  mutate(bmi_category = case_when(
    bmi < 18.5 ~ "Underweight",
    bmi >= 18.5 & bmi < 25.0 ~ "Normal",
    bmi >= 25.0 & bmi < 30.0 ~ "Overweight",
    bmi >= 30.0 ~ "Obese"
  ))

## icd data cleaning
clean_icd <- icd %>%

  # For the variables of interest that are considered in the study: Diabetes, hypertension, and Asthma
  mutate(disease_category = case_when(
    str_detect(description, "(?i)asthma") ~ "asthma",
    str_detect(description, "(?i)diabetes") ~ "diabetes",
    str_detect(description, "(?i)hypertension") ~ "hypertension",
    str_detect(description, "(?i)COPD") ~ "copd",
    TRUE ~ "other"
  )) %>%
  
  # Change from long format to wide format, and include the date of first diagnosis in the wide format
  group_by(id, disease_category) %>%
  summarize(first_diag_date = min(as.Date(icd_date)), .groups = "drop") %>%
  pivot_wider(
    names_from = disease_category, 
    values_from = first_diag_date
  ) %>%
  
  # Include binary columns of the relevant diagnosis: Asthma, diabetes, hypertension, copd
  mutate(
    has_asthma = if_else(!is.na(asthma), 1, 0),
    has_diabetes = if_else(!is.na(diabetes), 1, 0),
    has_hypertension = if_else(!is.na(hypertension), 1, 0),
    has_copd = if_else(!is.na(copd), 1, 0)
  ) %>%
  
  # Standardized the column names
  clean_names()


## residential data cleaning

date_residential <- residential %>%
  left_join(clean_cohort, by = "id") %>%
  
  # Define the 10-year lookback window based on the entry date in the cohort of patient
  mutate(
    window_end = entry_date.x,
    window_start = entry_date.x - years(10)
  ) %>%
  
  # Cut-off the residential periods to fit within the 10-year window based on the entry cohort date
  mutate(
    actual_start = pmax(address_start_date, window_start),
    actual_end = pmin(address_end_date, window_end)
  ) %>%
  
  # Calculate days spent in that location within the window defined above
  mutate(days_in_window = as.numeric(difftime(actual_end, actual_start, units = "days"))) %>%
  
  # Remove periods that fall entirely outside the 10-year window
  filter(days_in_window > 0)


  # Weighted number of years per county per patient
  res_summary <- date_residential %>%
    group_by(id, state, county) %>%
    summarize(total_days = sum(days_in_window), .groups = "drop") %>%
  
    # Calculate the weight (total days / ~3650 days in 10 years)
    # This weight will be multiplied by AQI values in the next step
    mutate(exposure_weight = total_days / 3650)

  # Weighted number of years per patient. Noted that 1.000 weighted means 100% at one location
  clean_res <- res_summary %>%
    group_by(id) %>%
    summarise(weighted_exp = sum(exposure_weight))
  
  
# Merge dataset
cohort_data_final <- clean_cohort %>%
    # Joining clean_icd, and clean_res dataset
    left_join(clean_icd, by = "id") %>%
    left_join(clean_res, by = "id") 
  
export(cohort_data_final, here("data", "cohort_data_final.csv"))
  

  