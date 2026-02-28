


# lm start ----------------------------------------------------------------
rm(list=ls())
# setwd('D:/00AA论文/pa timing and metabolism/data/')
# imputed.data <- readRDS("D:/00AA论文/pa timing and metabolism/data/imputated_combined0326.rds")

imputed.data <- readRDS("F:/PAtimingBrain/Acrophase_BMI/imputated_combined0326/imputated_combined0326.rds")


attach(imputed.data)
colnames(imputed.data)

imputed.data$Final_Education_FULL <- as.numeric(imputed.data$Final_Education_FULL)
imputed.data$Final_Healthy_diet_score_FULL <- as.numeric(imputed.data$Final_Healthy_diet_score_FULL)
imputed.data$Final_Smoking_status_FULL <- as.numeric(imputed.data$Final_Smoking_status_FULL)
imputed.data$Final_Alcohol_frequency_categories_FULL <- as.numeric(imputed.data$Final_Alcohol_frequency_categories_FULL)
str(imputed.data)

library(sjmisc)
library(tidyr)

# lm ----------------------------------------------------------------------
summary(imputed.data$Acrophase_cos)
hist(imputed.data$Acrophase_cos)

imputed.data$Acrophase_cos <- as.numeric(imputed.data$Acrophase_cos)

imputed.data$Acrophase_cos.3gp[imputed.data$Acrophase_cos<=11] <- 3
imputed.data$Acrophase_cos.3gp[imputed.data$Acrophase_cos>11 & imputed.data$Acrophase_cos<=17] <- 2
imputed.data$Acrophase_cos.3gp[imputed.data$Acrophase_cos>17] <- 1
imputed.data$Acrophase_cos.3gp <- factor(imputed.data$Acrophase_cos.3gp)
frq(imputed.data$Acrophase_cos.3gp)

imputed.data <- imputed.data[!is.na(imputed.data$Acrophase_cos.3gp),]

imputed.data <- complete(imputed.data)
#check the missing rate                  
colMeans(is.na(imputed.data)) * 100
mean(is.na(imputed.data)) * 100

summary(imputed.data)
# lm ----------------------------------------------------------------------

# 加载所需的包
library(emmeans)

# 定义需要分析的变量
response_vars <- c("BMI.acti")


model <- lm(formula(BMI.acti ~ Acrophase_cos.3gp + age.acti + sex31 + townsend.deprivation.index189 + assessment.centre54 + Final_Education_FULL + start.time.of.wear90010.season + Final_Healthy_diet_score_FULL + Final_Smoking_status_FULL + Final_Alcohol_frequency_categories_FULL + acc_sleep_dur_AD_mn + acc_sleep_midp_AD_mn + MVPA1005M400.Weekly.5.23), data = imputed.data)

# 进行方差分析
anova_result <- anova(model)
anova_result

# 进行事后两两比较
emmeans_result <- emmeans(model, pairwise ~ Acrophase_cos.3gp)
emmeans_result


