library(car)
library(dplyr)
library(readr)
library(sjmisc)
# start here
#______________________________________

PAtimingBrain.PABrain <- read_csv("F:/PAtimingBrain/Acrophase_BMI/PABrianResidual_Luo.csv", show_col_types = FALSE)
enigmaLists <- read_csv("XXXX/enigmaLists.csv")

# 获取 ID 列表
volume_ids <- enigmaLists$ID_Volume
area_ids <- enigmaLists$ID_Areas
thickness_ids <- enigmaLists$ID_Thickness

# 找到匹配的列
volume_columns <- grep(paste0("residual_X(", paste(volume_ids, collapse="|"), ")\\.2\\.0$"), names(PAtimingBrain.PABrain), value = TRUE)
area_columns <- grep(paste0("residual_X(", paste(area_ids, collapse="|"), ")\\.2\\.0$"), names(PAtimingBrain.PABrain), value = TRUE)
thickness_columns <- grep(paste0("residual_X(", paste(thickness_ids, collapse="|"), ")\\.2\\.0$"), names(PAtimingBrain.PABrain), value = TRUE)

# 定义协变量
PAtimingBrain.PABrain$assessment.centre54 <- factor(PAtimingBrain.PABrain$assessment.centre54)
PAtimingBrain.PABrain$start.time.of.wear90010.season <- factor(PAtimingBrain.PABrain$start.time.of.wear90010.season)
PAtimingBrain.PABrain$Final_Education_FULL <- as.numeric(PAtimingBrain.PABrain$Final_Education_FULL)
PAtimingBrain.PABrain$Final_Healthy_diet_score_FULL <- as.numeric(PAtimingBrain.PABrain$Final_Healthy_diet_score_FULL)
PAtimingBrain.PABrain$Final_Smoking_status_FULL <- as.numeric(PAtimingBrain.PABrain$Final_Smoking_status_FULL)
PAtimingBrain.PABrain$Final_Alcohol_frequency_categories_FULL <- as.numeric(PAtimingBrain.PABrain$Final_Alcohol_frequency_categories_FULL)
summary(PAtimingBrain.PABrain$Acrophase_cos)
#hist(PAtimingBrain.PABrain$Acrophase_cos)

PAtimingBrain.PABrain$Acrophase_cos <- as.numeric(PAtimingBrain.PABrain$Acrophase_cos)

PAtimingBrain.PABrain$Acrophase_cos.3gp[PAtimingBrain.PABrain$Acrophase_cos<=11] <- 3
PAtimingBrain.PABrain$Acrophase_cos.3gp[PAtimingBrain.PABrain$Acrophase_cos>11 & PAtimingBrain.PABrain$Acrophase_cos<=17] <- 2
PAtimingBrain.PABrain$Acrophase_cos.3gp[PAtimingBrain.PABrain$Acrophase_cos>17] <- 1
PAtimingBrain.PABrain$Acrophase_cos.3gp <- factor(
  PAtimingBrain.PABrain$Acrophase_cos.3gp)

table(PAtimingBrain.PABrain$Acrophase_cos.3gp)

covariates <- c("days_int","age.acti","sex31","start.time.of.wear90010.season","townsend.deprivation.index189","assessment.centre54",
                "Final_Education_FULL",  "Final_Healthy_diet_score_FULL","Final_Smoking_status_FULL",
                "Final_Alcohol_frequency_categories_FULL","acc_sleep_dur_AD_mn","acc_sleep_midp_AD_mn",  "MVPA1005M400.Weekly.5.23")

PAtimingBrain.PABrain$Early <- as.numeric(PAtimingBrain.PABrain$Acrophase_cos.3gp == 3)
PAtimingBrain.PABrain$Intermediate <- as.numeric(PAtimingBrain.PABrain$Acrophase_cos.3gp == 2)
PAtimingBrain.PABrain$Late <- as.numeric(PAtimingBrain.PABrain$Acrophase_cos.3gp == 1)

table(PAtimingBrain.PABrain$Early)
table(PAtimingBrain.PABrain$Intermediate)
table(PAtimingBrain.PABrain$Late)
perform_regression_binary <- function(dv_columns, iv_binary, iv_name, type) {
  
  all_results <- list()
  
  for (dv in dv_columns) {
    
    tmp <- PAtimingBrain.PABrain[, c(dv, iv_binary, covariates)]
    
    # 至少要有 1 / 0 两类
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
        type = type
      )
    
    all_results[[dv]] <- res
  }
  
  results <- dplyr::bind_rows(all_results)
  
  if (nrow(results) == 0) return(results)
  
  # FDR：每个时型 × 全脑 ROI
  results <- results %>%
    group_by(type) %>%
    mutate(
      FDR = p.adjust(p.value, method = "BH")
    ) %>%
    ungroup()
  
  return(results)
}
early_volume <- perform_regression_binary(
  volume_columns, "Early", "Early", "Volume"
)

early_area <- perform_regression_binary(
  area_columns, "Early", "Early", "Area"
)

early_thickness <- perform_regression_binary(
  thickness_columns, "Early", "Early", "Thickness"
)
inter_volume <- perform_regression_binary(
  volume_columns, "Intermediate", "Intermediate", "Volume"
)

inter_area <- perform_regression_binary(
  area_columns, "Intermediate", "Intermediate", "Area"
)

inter_thickness <- perform_regression_binary(
  thickness_columns, "Intermediate", "Intermediate", "Thickness"
)
late_volume <- perform_regression_binary(
  volume_columns, "Late", "Late", "Volume"
)

late_area <- perform_regression_binary(
  area_columns, "Late", "Late", "Area"
)

late_thickness <- perform_regression_binary(
  thickness_columns, "Late", "Late", "Thickness"
)
all_results_binary <- dplyr::bind_rows(
  early_volume, early_area, early_thickness,
  inter_volume, inter_area, inter_thickness,
  late_volume, late_area, late_thickness
)

write.csv(
  all_results_binary,
  "F:/PAtimingBrain/Acrophase_BMI/lm_PABrain_binaryChronotype.csv",
  row.names = FALSE
)
