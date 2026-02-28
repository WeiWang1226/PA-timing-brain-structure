# Physical Activity Acrophase and Brain Structure (UK Biobank)

## Overview
This repository contains analysis scripts for examining the associations between physical activity acrophase (timing of peak activity) and brain structural measures using UK Biobank imaging data.

## Study Aim
To investigate whether physical activity timing (early / intermediate / late acrophase patterns) is associated with:

- Cortical thickness
- Cortical surface area
- Cortical volume
- Subcortical volume and intensity

## Data Source
UK Biobank:
- Accelerometer data (physical activity timing)
- Brain MRI imaging data (IDPs)
- Demographic and clinical covariates

Note: Raw UK Biobank data are not included in this repository.

## Repository Structure

## Statistical Analysis

- Linear regression models
- Covariate adjustment (age, sex, BMI, etc.)
- FDR correction
- Pairwise comparisons
- Neuroimaging visualization (ggseg / surface mapping)

## Software

- R (version ≥ 4.2)
- Required packages:
  - tidyverse
  - survival
  - broom
  - ggseg
  - emmeans
  - car

## Reproducibility

This repository contains analysis scripts only.  
Researchers with approved UK Biobank access can reproduce results using the same pipeline.

## Author
Wei Wang
