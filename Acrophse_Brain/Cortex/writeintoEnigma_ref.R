library(dplyr)
library(readr)
library(stringr)
library(tibble)

# 读取enigmaLists
enigmaLists <- read_csv("F:/ukb_light_dementia/20240515/cortex/data_cortex/enigmaLists.csv", show_col_types = FALSE)

reference_map <- tibble::tibble(
  reference = c(1, 1, 2),
  comparison = c("1vs2", "1vs3", "2vs3"),
  ref_group  = c("Acrophase_cos.3gp1", "Acrophase_cos.3gp1", "Acrophase_cos.3gp2"),
  cmp_group  = c("Acrophase_cos.3gp2", "Acrophase_cos.3gp3", "Acrophase_cos.3gp3")
)

process_files <- function(factor_file, cor_files_named) {
  
  factor_data <- read_csv(factor_file, show_col_types = FALSE) %>%
    mutate(
      neg_log_p_value = -log10(p.value),
      
      Compared_Group = case_when(
        str_detect(term, "3gp1$") ~ "Acrophase_cos.3gp1",
        str_detect(term, "3gp2$") ~ "Acrophase_cos.3gp2",
        str_detect(term, "3gp3$") ~ "Acrophase_cos.3gp3"
      )
    ) %>%
    left_join(reference_map, by = "reference", relationship = "many-to-many") %>%
    filter(
      Compared_Group == cmp_group,
      p.value < 0.05
    )
  
  
  for (cmp in unique(factor_data$comparison)) {
    
    message("Processing ", cmp)
    
    factor_sub <- factor_data %>% filter(comparison == cmp)
    
    cor_data <- read_csv(cor_files_named[[cmp]], show_col_types = FALSE)
    
    significant_info <- list()
    
    for (i in seq_len(nrow(factor_sub))) {
      
      result <- factor_sub[i, ]
      
      id <- as.numeric(gsub("residual_X|\\.2\\.0", "", result$dependent_var))
      
      dkt_row <- enigmaLists %>%
        filter(ID_Volume == id | ID_Areas == id | ID_Thickness == id)
      
      if (nrow(dkt_row) == 0) next
      
      dkt <- dkt_row$DKT
      row_index <- which(cor_data$DKT == dkt)
      if (length(row_index) == 0) next
      
      if (result$type == "Volume") {
        cor_data[row_index, c("beta_vol", "p_log_vol")] <-
          list(result$estimate, result$neg_log_p_value)
      } else if (result$type == "Area") {
        cor_data[row_index, c("beta_area", "p_log_area")] <-
          list(result$estimate, result$neg_log_p_value)
      } else if (result$type == "Thickness") {
        cor_data[row_index, c("beta_thickness", "p_log_thickness")] <-
          list(result$estimate, result$neg_log_p_value)
      }
      
      brain_area <- if (result$type == "Volume") {
        dkt_row$Volumes
      } else if (result$type == "Area") {
        dkt_row$Areas
      } else {
        dkt_row$Thickness
      }
      
      significant_info[[length(significant_info) + 1]] <- tibble(
        Term = result$term,
        Comparison = cmp,
        Reference_Group = result$Reference_Group,
        Compared_Group  = result$Compared_Group,
        ID = id,
        Brain_Area = brain_area,
        Estimate = result$estimate,
        Neg_Log_P_Value = result$neg_log_p_value,
        Type = result$type
      )
    }
    
    write_csv(cor_data, cor_files_named[[cmp]])
    
    sig_df <- bind_rows(significant_info)
    write_csv(
      sig_df,
      paste0("significant_results_", cmp, "_", basename(factor_file))
    )
  }
}


cor_files_named <- c(
  "1vs2" = "F:/PAtimingBrain/Acrophase_BMI/cortex/reference_1vs2.csv",
  "1vs3" = "F:/PAtimingBrain/Acrophase_BMI/cortex/reference_1vs3.csv",
  "2vs3" = "F:/PAtimingBrain/Acrophase_BMI/cortex/reference_2vs3.csv"
)

process_files(
  factor_file = "F:/PAtimingBrain/Acrophase_BMI/lm_PABrain_lm_byReference.csv",
  cor_files_named = cor_files_named
)
