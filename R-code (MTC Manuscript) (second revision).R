
library(haven)
library(dplyr)
library(gtsummary)
library(car)

file_path <- "C:/Desktop/Research/Social Netwrok and T2D/MTC_Analysis/MTC_Completed Data_AcceptedOnly_JHP_0106 (1).sav"

my_data <- read_sav(file_path)

my_data <- my_data %>%
  mutate(
    total_actual_programs = rowSums(select(., DCP_mbumps_3_1, DCP_mbumps_3_2, 
                                           DCP_mbumps_3_3, DCP_mbumps_3_4, 
                                           DCP_mbumps_3_5, DCP_mbumps_3_6), na.rm = TRUE)
  )

my_data_clean <- as_factor(my_data)

analysis_data <- my_data_clean %>%
  mutate(
    # Program Category
    program_category = case_when(
      total_actual_programs == 0 ~ "None (0)",
      total_actual_programs == 1 ~ "Single Program (1)",
      total_actual_programs >= 2 ~ "Multiple Programs (2+)"
    ),
    program_category = factor(program_category, levels = c("None (0)", "Single Program (1)", "Multiple Programs (2+)")),
    
    # Diagnosis Years
    t2d_date_clean = as.Date(T2Ddiagnosis, format = "%m/%d/%Y"),
    T2Ddiagnosis_years = as.numeric(difftime(as.Date("2024-06-01"), t2d_date_clean, units = "days")) / 365.25,
    
    # UPDATED: Relationship Status (Separated moved to Divorced/Widowed)
    relstatus_clean = case_when(
      is.na(relstatus) ~ NA_character_,
      grepl("Separated|Divorced|Widowed", relstatus, ignore.case = TRUE) ~ "Divorced/Widowed/Separated",
      grepl("Married", relstatus, ignore.case = TRUE) ~ "Married",
      grepl("Dating one person|Engaged", relstatus, ignore.case = TRUE) ~ "Committed Relationship",
      TRUE ~ "Single/Dating Several"
    ),
    relstatus_clean = factor(relstatus_clean, levels = c("Married", "Committed Relationship", "Divorced/Widowed/Separated", "Single/Dating Several")),
    
    # Education
    educ_clean = case_when(
      grepl("Bachelor|Master|Doctoral", educ, ignore.case = TRUE) ~ "Bachelor's or Higher",
      grepl("Some college|Associates|Technical", educ, ignore.case = TRUE) ~ "Some College/Associates/Trade",
      TRUE ~ "High School or Less"
    ),
    educ_clean = factor(educ_clean, levels = c("High School or Less", "Some College/Associates/Trade", "Bachelor's or Higher")),
    
    # UPDATED: Income (Consolidated into 3 tiers)
    income_clean = case_when(
      is.na(income) ~ NA_character_,
      grepl("100,000|125,000|150,000", income, ignore.case = TRUE) ~ "$100,000 or more",
      grepl("50,000|75,000", income, ignore.case = TRUE) ~ "$50,000 to $99,999",
      TRUE ~ "Less than $50,000" 
    ),
    income_clean = factor(income_clean, levels = c("Less than $50,000", "$50,000 to $99,999", "$100,000 or more")),
    
    # Employment
    employ_clean = case_when(
      grepl("Employed for wages|Self-employed", employ, ignore.case = TRUE) ~ "Employed",
      grepl("Unemployed|Unable to work", employ, ignore.case = TRUE) ~ "Unemployed/Unable to work",
      grepl("Retired", employ, ignore.case = TRUE) ~ "Retired",
      grepl("student", employ, ignore.case = TRUE) ~ "Student",
      TRUE ~ "Other"
    ),
    employ_clean = factor(employ_clean, levels = c("Employed", "Retired", "Unemployed/Unable to work", "Student", "Other"))
  ) %>%
  
  select(
    program_category, age, relstatus_clean, educ_clean, income_clean, employ_clean, 
    T2Ddiagnosis_years, chronictot, 
    dcp2_t2doutcome_sum, DCP_spfc_2_tot, DCP_ltcbs_1_tot, DCP_mbumps_2_tot, 
    DCP_mbumps_4_tot, sdsca1_average_days, dses_tot, eHls_3_10_tot
  ) %>%
  
  na.omit() %>%
  droplevels()

table_1_revised <- analysis_data %>%
  select(age, relstatus_clean, educ_clean, income_clean, employ_clean, T2Ddiagnosis_years, chronictot, program_category) %>%
  tbl_summary(
    by = program_category, 
    statistic = list(all_continuous() ~ "{mean} ({sd})", 
                     all_categorical() ~ "{n} ({p}%)"),
    missing = "no" 
  ) %>%
  add_p(test = list(all_categorical() ~ "chisq.test")) %>% 
  add_overall() %>%
  modify_header(label = "**Demographics & Health Status**") %>%
  bold_labels()

print(table_1_revised)


outcomes_matrix <- cbind(
  analysis_data$dcp2_t2doutcome_sum, 
  analysis_data$DCP_spfc_2_tot, 
  analysis_data$DCP_ltcbs_1_tot, 
  analysis_data$DCP_mbumps_2_tot, 
  analysis_data$DCP_mbumps_4_tot, 
  analysis_data$sdsca1_average_days, 
  analysis_data$dses_tot, 
  analysis_data$eHls_3_10_tot
)

mancova_model <- lm(outcomes_matrix ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)

cat("\n======================================================\n")
cat("               MANCOVA OMNIBUS TEST RESULTS             \n")
cat("======================================================\n")
mancova_results <- Manova(mancova_model, type = "III")
print(mancova_results)

cat("\n======================================================\n")
cat("          OUTCOME 1: Diabetes Impact (DCP_spfc_2_tot)   \n")
cat("======================================================\n")
impact_m1 <- lm(DCP_spfc_2_tot ~ program_category, data = analysis_data)
impact_m2 <- lm(DCP_spfc_2_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
impact_m3 <- lm(DCP_spfc_2_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(impact_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(impact_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(impact_m3))

cat("\n======================================================\n")
cat("          OUTCOME 2: Self-Efficacy (dses_tot)           \n")
cat("======================================================\n")
dses_m1 <- lm(dses_tot ~ program_category, data = analysis_data)
dses_m2 <- lm(dses_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
dses_m3 <- lm(dses_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(dses_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(dses_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(dses_m3))

cat("\n======================================================\n")
cat("          OUTCOME 3: E-Health Literacy (eHls_3_10_tot)  \n")
cat("======================================================\n")
ehls_m1 <- lm(eHls_3_10_tot ~ program_category, data = analysis_data)
ehls_m2 <- lm(eHls_3_10_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
ehls_m3 <- lm(eHls_3_10_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(ehls_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(ehls_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(ehls_m3))

cat("\n======================================================\n")
cat("          OUTCOME 4: Barriers to Care (DCP_mbumps_2_tot)\n")
cat("======================================================\n")
barriers_m1 <- lm(DCP_mbumps_2_tot ~ program_category, data = analysis_data)
barriers_m2 <- lm(DCP_mbumps_2_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
barriers_m3 <- lm(DCP_mbumps_2_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(barriers_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(barriers_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(barriers_m3))

cat("\n======================================================\n")
cat("          OUTCOME 5: Health Beliefs (DCP_ltcbs_1_tot)   \n")
cat("======================================================\n")
beliefs_m1 <- lm(DCP_ltcbs_1_tot ~ program_category, data = analysis_data)
beliefs_m2 <- lm(DCP_ltcbs_1_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
beliefs_m3 <- lm(DCP_ltcbs_1_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(beliefs_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(beliefs_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(beliefs_m3))

cat("\n======================================================\n")
cat("          OUTCOME 6: Complications (dcp2_t2doutcome_sum)\n")
cat("======================================================\n")
comp_m1 <- lm(dcp2_t2doutcome_sum ~ program_category, data = analysis_data)
comp_m2 <- lm(dcp2_t2doutcome_sum ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
comp_m3 <- lm(dcp2_t2doutcome_sum ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(comp_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(comp_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(comp_m3))

cat("\n======================================================\n")
cat("          OUTCOME 7: Knowledge (DCP_mbumps_4_tot)       \n")
cat("======================================================\n")
know_m1 <- lm(DCP_mbumps_4_tot ~ program_category, data = analysis_data)
know_m2 <- lm(DCP_mbumps_4_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
know_m3 <- lm(DCP_mbumps_4_tot ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(know_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(know_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(know_m3))

cat("\n======================================================\n")
cat("          OUTCOME 8: Self-Care Days (sdsca1_average_days)\n")
cat("======================================================\n")
sdsca_m1 <- lm(sdsca1_average_days ~ program_category, data = analysis_data)
sdsca_m2 <- lm(sdsca1_average_days ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean, data = analysis_data)
sdsca_m3 <- lm(sdsca1_average_days ~ program_category + age + relstatus_clean + educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + chronictot, data = analysis_data)
cat("\n--- MODEL 1 (Unadjusted) ---\n"); print(summary(sdsca_m1))
cat("\n--- MODEL 2 (+ Demographics) ---\n"); print(summary(sdsca_m2))
cat("\n--- MODEL 3 (+ Health Factors) ---\n"); print(summary(sdsca_m3))

install.packages("mediation")
library(mediation)

cat("\n======================================================\n")
cat("          MEDIATION: Multiple Programs vs. None         \n")
cat("======================================================\n")

med_model <- lm(DCP_mbumps_4_tot ~ program_category + age + relstatus_clean + 
                  educ_clean + income_clean + employ_clean + T2Ddiagnosis_years + 
                  chronictot, data = analysis_data)

out_model <- lm(sdsca1_average_days ~ program_category + DCP_mbumps_4_tot + age + 
                  relstatus_clean + educ_clean + income_clean + employ_clean + 
                  T2Ddiagnosis_years + chronictot, data = analysis_data)

set.seed(1234) 
med_results <- mediate(med_model, out_model, 
                       treat = "program_category", 
                       mediator = "DCP_mbumps_4_tot",
                       control.value = "None (0)",             
                       treat.value = "Multiple Programs (2+)",
                       boot = FALSE, sims = 1000)              

print(summary(med_results))

cat("\n======================================================\n")
cat("          MEDIATION: Single Program vs. None            \n")
cat("======================================================\n")

set.seed(1234) 
med_results_single <- mediate(med_model, out_model, 
                              treat = "program_category", 
                              mediator = "DCP_mbumps_4_tot",
                              control.value = "None (0)",             
                              treat.value = "Single Program (1)", 
                              boot = FALSE, sims = 1000)

print(summary(med_results_single))