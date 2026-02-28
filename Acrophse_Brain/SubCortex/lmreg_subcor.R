library(broom)
library(dplyr)
library(readr)

# 读取数据
subcorLists <- read_csv("F:/PAtimingBrain/subcortex/subcorList.csv")
#PAtimingBrain.PABrain <- read_csv("D:/PAtimingBrain/PABrain_with_residuals.csv", show_col_types = FALSE)
PAtimingBrain.PABrain <- read_csv("F:/PAtimingBrain/Acrophase_BMI/PABrianResidual_Luo.csv", show_col_types = FALSE)

# 获取 ID 列表
ids <- unlist(subcorLists[, "ID"])

# 找到匹配的列
matching_columns <- grep(paste0("residual_(", paste(ids, collapse="|"), ")"), names(PAtimingBrain.PABrain), value = TRUE)

covariates <- c("days_int","age.acti","sex31","start.time.of.wear90010.season","townsend.deprivation.index189","assessment.centre54",
                "Final_Education_FULL", "Final_Healthy_diet_score_FULL","Final_Smoking_status_FULL",
                "Final_Alcohol_frequency_categories_FULL","acc_sleep_dur_AD_mn","acc_sleep_midp_AD_mn",  "MVPA1005M400.Weekly.5.23")


PAtimingBrain.PABrain$Acrophase_cos.3gp <-
  relevel(PAtimingBrain.PABrain$Acrophase_cos.3gp, ref = "2")

# 进行多变量回归分析并保存结果
for (iv_index in 643) {  # 
  iv_name <- names(PAtimingBrain.PABrain)[iv_index]
  results <- data.frame()  # 初始化结果数据框
  
  for (dv in matching_columns) {  # 遍历匹配的列名
    formula_string <- paste("scale(", dv, ") ~ ", iv_name, " + ", paste(covariates, collapse = " + "))
    # 构建线性模型
    model <- lm(as.formula(formula_string), data = PAtimingBrain.PABrain)
    tidy_model <- broom::tidy(model)
    
    # 筛选出与当前自变量相关的系数，并添加到结果数据框
    relevant_result <- tidy_model %>% 
      filter(grepl(iv_name, term))%>% 
      mutate(dependent_var = dv)
    
    measure_type <- subcorLists$measure[which(subcorLists$ID == gsub("^residual_", "", dv))]
    relevant_result <- relevant_result %>% mutate(measure_type = measure_type)
    
    results <- rbind(results, relevant_result)
  }
  
  # 保存未矫正的结果
  write.csv(results, paste0("F:/PAtimingBrain/Acrophase_BMI/subcortex/uncorrP_sub_for_", iv_name, ".csv"), row.names = FALSE)
  
  # 分别计算 Intensity 和 Volume 的 FDR 调整后的 p 值
  intensity_results <- results %>% filter(measure_type == "Intensity")
  volume_results <- results %>% filter(measure_type == "Volume")
  
  if (nrow(intensity_results) > 0) {
    adjusted_p_values_intensity <- p.adjust(intensity_results$p.value, method = "BH")
    intensity_results <- intensity_results %>% 
      mutate(FDR_p_value = adjusted_p_values_intensity,
             p_log = -log10(FDR_p_value))
  }
  
  if (nrow(volume_results) > 0) {
    adjusted_p_values_volume <- p.adjust(volume_results$p.value, method = "BH")
    volume_results <- volume_results %>% 
      mutate(FDR_p_value = adjusted_p_values_volume,
             p_log = -log10(FDR_p_value))
  }
  
  # 合并 Intensity 和 Volume 的结果
  final_results <- bind_rows(intensity_results, volume_results) %>%
    # select(dependent_var, estimate, p_log, measure_type) %>%
    mutate(dependent_var = gsub("^residual_", "", dependent_var))
  
  # 合并结果数据框和 subcorLists
  final_results <- subcorLists %>%
    left_join(final_results, by = c("ID" = "dependent_var"))
  
  # 保存结果到 CSV 文件
  write.csv(final_results, paste0("F:/PAtimingBrain/Acrophase_BMI/subcortex/CorrP_sub_for_", iv_name, ".csv"), row.names = FALSE)
}

PAtimingBrain.PABrain$Early <- as.numeric(PAtimingBrain.PABrain$Acrophase_cos.3gp == 3)
PAtimingBrain.PABrain$Intermediate <- as.numeric(PAtimingBrain.PABrain$Acrophase_cos.3gp == 2)
PAtimingBrain.PABrain$Late <- as.numeric(PAtimingBrain.PABrain$Acrophase_cos.3gp == 1)

table(PAtimingBrain.PABrain$Early)
table(PAtimingBrain.PABrain$Intermediate)
table(PAtimingBrain.PABrain$Late)

volume_columns_sub <- matching_columns[
  gsub("^residual_", "", matching_columns) %in%
    subcorLists$ID[subcorLists$measure == "Volume"]
]

intensity_columns_sub <- matching_columns[
  gsub("^residual_", "", matching_columns) %in%
    subcorLists$ID[subcorLists$measure == "Intensity"]
]

perform_regression_binary_sub <- function(dv_columns, iv_binary, iv_name, type) {
  
  all_results <- list()
  
  for (dv in dv_columns) {
    
    tmp <- PAtimingBrain.PABrain[, c(dv, iv_binary, covariates)]
    
    if (length(unique(na.omit(tmp[[iv_binary]]))) < 2) next
    
    model <- lm(
      as.formula(
        paste("scale(", dv, ") ~ ", iv_binary, " + ",
              paste(covariates, collapse = " + "))
      ),
      data = tmp
    )
    
    res <- broom::tidy(model) %>%
      filter(term == iv_binary) %>%
      mutate(
        dependent_var = dv,
        iv = iv_name,
        measure_type = type
      )
    
    all_results[[dv]] <- res
  }
  
  results <- dplyr::bind_rows(all_results)
  
  if (nrow(results) == 0) return(results)
  
  # FDR within each measure type
  results <- results %>%
    group_by(measure_type) %>%
    mutate(
      FDR_p_value = p.adjust(p.value, method = "BH"),
      p_log = -log10(FDR_p_value)
    ) %>%
    ungroup()
  
  results$dependent_var <- gsub("^residual_", "", results$dependent_var)
  
  return(results)
}

early_volume_sub <- perform_regression_binary_sub(
  volume_columns_sub, "Early", "Early", "Volume"
)

early_intensity_sub <- perform_regression_binary_sub(
  intensity_columns_sub, "Early", "Early", "Intensity"
)

inter_volume_sub <- perform_regression_binary_sub(
  volume_columns_sub, "Intermediate", "Intermediate", "Volume"
)

inter_intensity_sub <- perform_regression_binary_sub(
  intensity_columns_sub, "Intermediate", "Intermediate", "Intensity"
)

late_volume_sub <- perform_regression_binary_sub(
  volume_columns_sub, "Late", "Late", "Volume"
)

late_intensity_sub <- perform_regression_binary_sub(
  intensity_columns_sub, "Late", "Late", "Intensity"
)
all_results_sub_binary <- dplyr::bind_rows(
  early_volume_sub, early_intensity_sub,
  inter_volume_sub, inter_intensity_sub,
  late_volume_sub, late_intensity_sub
)
final_results_sub_binary <- subcorLists %>%
  left_join(all_results_sub_binary,
            by = c("ID" = "dependent_var"))
write.csv(
  final_results_sub_binary,
  "F:/PAtimingBrain/Acrophase_BMI/subcortex/lm_sub_binaryChronotype.csv",
  row.names = FALSE
)




