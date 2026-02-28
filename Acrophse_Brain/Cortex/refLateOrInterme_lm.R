library(car)
library(dplyr)
library(readr)
library(sjmisc)
# start here
#______________________________________

PAtimingBrain.PABrain <- read_csv("F:/PAtimingBrain/Acrophase_BMI/PABrianResidual.csv", show_col_types = FALSE)
enigmaLists <- read_csv("XXX/enigmaLists.csv")

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
                "Final_Education_FULL", "Final_Healthy_diet_score_FULL","Final_Smoking_status_FULL",
                "Final_Alcohol_frequency_categories_FULL","acc_sleep_dur_AD_mn","acc_sleep_midp_AD_mn",  
                "MVPA1005M400.Weekly.5.23")
perform_lm_with_reference <- function(
    dv_columns,
    iv_name,
    ref_level,     # 1 或 2
    type
) {
  
  all_results <- list()
  
  # 临时拷贝，避免污染原数据
  df <- PAtimingBrain.PABrain
  
  # ① 设定 reference
  df[[iv_name]] <- relevel(
    factor(df[[iv_name]]),
    ref = as.character(ref_level)
  )
  
  for (dv in dv_columns) {
    
    tmp <- df[, c(dv, iv_name, covariates)]
    
    # 至少要有 2 组
    if (length(unique(na.omit(tmp[[iv_name]]))) < 2) next
    
    model <- lm(
      as.formula(
        paste("scale(", dv, ") ~ ", iv_name, " + ",
              paste(covariates, collapse = " + "))
      ),
      data = tmp
    )
    
    res <- broom::tidy(model) %>%
      filter(grepl(paste0("^", iv_name), term)) %>%
      mutate(
        dependent_var = dv,
        type = type,
        reference = ref_level
      )
    
    all_results[[dv]] <- res
  }
  
  dplyr::bind_rows(all_results)
}
iv_name <- "Acrophase_cos.3gp"

vol_ref1 <- perform_lm_with_reference(
  volume_columns, iv_name, ref_level = 1, type = "Volume"
)

area_ref1 <- perform_lm_with_reference(
  area_columns, iv_name, ref_level = 1, type = "Area"
)

thick_ref1 <- perform_lm_with_reference(
  thickness_columns, iv_name, ref_level = 1, type = "Thickness"
)   
vol_ref2 <- perform_lm_with_reference(
  volume_columns, iv_name, ref_level = 2, type = "Volume"
)

area_ref2 <- perform_lm_with_reference(
  area_columns, iv_name, ref_level = 2, type = "Area"
)

thick_ref2 <- perform_lm_with_reference(
  thickness_columns, iv_name, ref_level = 2, type = "Thickness"
)
lm_results_all <- dplyr::bind_rows(
  vol_ref1, area_ref1, thick_ref1,
  vol_ref2, area_ref2, thick_ref2
)
lm_results_all <- lm_results_all %>%
  group_by(dependent_var) %>%   # 同一对比 × 全脑 ROI
  mutate(FDR = p.adjust(p.value, method = "BH")) %>%
  ungroup()

write.csv(
  lm_results_all,
  "F:/PAtimingBrain/Acrophase_BMI/lm_PABrain_lm_byReference.csv",
  row.names = FALSE
)
