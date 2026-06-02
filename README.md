# MTC Diabetes Analysis: Social Networks and Type 2 Diabetes (T2D)

This repository contains the production-ready R analytics pipeline for processing raw clinical survey data, generating stratified baseline demographics, and executing advanced multivariate and causal inference modeling. 

The repository evaluates the impact of structured social support network programs on behavioral, psychological, and physiological endpoints for patients managing Type 2 Diabetes (T2D).

---

## Analytical Architecture

The workflow is engineered into four distinct sequential phases to ensure structural reproducibility and statistical rigor:

1. **Data Normalization & Cleaning:** Imports raw SPSS data arrays, harmonizes sparse or high-cardinality categorical strings (e.g., income, education, and relationship tiers), constructs cumulative indices, and applies listwise complete-case constraints (`na.omit()`).
2. **Stratified Descriptive Statistics:** Leverages `gtsummary` to build a publication-grade baseline characteristic matrix tracking demographic variance across program interaction levels.
3. **Multivariate Analysis (MANCOVA):** Implements an omnibus Type-III Multivariate Analysis of Covariance via the `car` framework to concurrently evaluate structural group variance across 8 independent health/behavioral outcome vectors while controlling for clinical and demographic drift.
4. **Hierarchical Regressions & Causal Mediation:** Executes sequential ordinary least squares (OLS) regressions (Unadjusted $\rightarrow$ Demographics $\rightarrow$ Fully Adjusted) across 8 distinct endpoints, paired with parametric causal mediation testing to determine the indirect effect of Diabetes Knowledge on downstream Self-Care Days.

---

## Feature & Variable Dictionary

### Exposure Measure
* `program_category`: An ordinal factor tracking active intervention engagement based on multi-item tracking arrays, categorized as: `None (0)`, `Single Program (1)`, or `Multiple Programs (2+)`.

### Confounding & Control Matrices
* **Socio-Demographic Core:** Age, Relationship Status (`relstatus_clean`), Educational Attainment (`educ_clean`), Standardized Income Tier (`income_clean`), and Employment Status (`employ_clean`).
* **Clinical Covariates:** Duration since initial diagnosis (`T2Ddiagnosis_years`) calculated relative to a standard baseline index, and a cumulative multi-morbidity burden index (`chronictot`).

### Target Outcome Endpoints
The pipeline evaluates 8 distinct primary and secondary clinical/behavioral endpoints:
* `dcp2_t2doutcome_sum` (Total Diabetes Complications)
* `DCP_spfc_2_tot` (Perceived Diabetes Impact)
* `DCP_ltcbs_1_tot` (Health Belief Scales)
* `DCP_mbumps_2_tot` (Structural Barriers to Care)
* `DCP_mbumps_4_tot` (Objective Diabetes Knowledge)
* `sdsca1_average_days` (Self-Care Behavior Days)
* `dses_tot` (Diabetes Self-Efficacy Scale)
* `eHls_3_10_tot` (Digital Health Literacy)

---

## Environment Requirements & Package Setup

This pipeline is optimized for **R version 4.0.0 or higher**. Dependencies must be loaded from CRAN prior to executing the core analytics script:

```R
install.packages(c("haven", "dplyr", "gtsummary", "car", "mediation"))
