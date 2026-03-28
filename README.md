# Project Overview
This repository contains the complete research pipeline for evaluating the longitudinal association between 10-year cumulative air pollution exposure (AQI) and the risk of new-onset Chronic Obstructive Pulmonary Disease (COPD) in U.S. adults.

The study utilizes a multi-cohort approach, integrating Electronic Health Records (EHR) with residential history and EPA environmental data to move beyond acute observations toward conclusive evidence of long-term environmental impacts on respiratory health.

## Research Question
Is long-term exposure to combustion-related pollutants associated with a higher incidence of COPD, independent of tobacco use and chronological age?

# Repository Structure
This project is organized into modular directories to ensure technical autonomy and reproducible workflows.

/documentation: Contains the Statistical Analysis Plan (SAP), project protocols, and the master data dictionary.

/data: Storage for raw and intermediate datasets (Note: Raw EHR data is restricted and not tracked via version control).

/analysis: The core technical hub of the project.

/analysis/README.md: Refer to this file for specific instructions on data cleaning, merging logic, and script execution.

/analysis/scripts: Annotated R scripts for cleaning and statistical modeling.

/analysis/output: Generated tables, figures, and summary statistics.

# Getting Started & Reproducibility
1. Prerequisites
To execute the cleaning and analysis pipeline, you will require:

R (v4.5.2 or later)

RStudio

Required Packages: tidyverse, skimr, survival (for Cox models), and broom.

2. Data Preparation
Before running the analysis, ensure the raw CSV files (cohort-data.csv, icd-data.csv, residential-data.csv) are placed in the /data directory.

3. Execution Flow
Data Cleaning: Navigate to the /analysis directory and consult the Data Cleaning README. This document outlines the 7 data quality indicators and the specific filtering steps (inclusion/exclusion) required to generate the analysis-ready dataset.

Merging: Run the merging scripts to link clinical and residential data by Participant ID.

Analysis: Execute the modeling scripts once the exposure variables are derived.