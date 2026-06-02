# MTC Diabetes Analysis: Social Networks and Type 2 Diabetes (T2D)

This repository contains R scripts for cleaning survey data and performing advanced statistical analyses. The project investigates the relationship between social network support programs and clinical/behavioral health outcomes for individuals living with Type 2 Diabetes (T2D).

---

## Project Overview

The core objective of this research is to evaluate how participation in various support programs impacts health-related outcomes, self-efficacy, and self-care behaviors. The pipeline processes raw SPSS data, restructures demographic and clinical covariates, and executes a multi-stage statistical workflow:

1. **Descriptive Statistics:** Generates a baseline demographic characteristics table (`Table 1`) stratified by support program intensity using `gtsummary`.
2. **MANCOVA Omnibus Test:** Evaluates global statistical differences across 8 health and behavioral outcome metrics simultaneously using a Type-III Multivariate ANOVA.
3. **Hierarchical Linear Modeling:** Fits sequential linear regressions (Unadjusted $\rightarrow$ Demographic Adjusted $\rightarrow$ Fully Adjusted for Clinical Factors) across all 8 distinct clinical and psychological outcomes.
4. **Causal Mediation Analysis:** Tests whether Diabetes Knowledge acts as a significant mediator between support program categories and final Self-Care Days.

---

## Variables & Measures

### Independent Variable
* `program_category`: Level of support program participation, derived from cumulative tracking items (`None (0)`, `Single Program (1)`, `Multiple Programs (2+)`).

### Covariates & Controls
* **Demographics:** Age, Relationship Status (`relstatus_clean`), Education (`educ_clean`), Income Tier (`income_clean`), and Employment Status (`employ_clean`).
* **Clinical Status:** Total years living with a T2D diagnosis (`T2Ddiagnosis_years`) and Total Chronic Comorbidities (`chronictot`).

### Outcome Metrics
The analysis evaluates 8 distinct primary and secondary endpoints:
* `dcp2_t2doutcome_sum` (Diabetes Complications)
* `DCP_spfc_2_tot` (Diabetes Impact)
* `DCP_ltcbs_1_tot` (Health Beliefs)
* `DCP_mbumps_2_tot` (Barriers to Care)
* `DCP_mbumps_4_tot` (Diabetes Knowledge)
* `sdsca1_average_days` (Self-Care Days)
* `dses_tot` (Self-Efficacy)
* `eHls_3_10_tot` (E-Health Literacy)

---

## Setup and Installation

### Dependencies
To run this analysis, you must have **R (version 4.0 or higher)** installed. You can install all required packages directly from your CRAN console using the following command:

```R
install.packages(c("haven", "dplyr", "gtsummary", "car", "mediation"))
