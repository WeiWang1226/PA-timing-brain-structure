library(ggseg)
library(ggplot2)
library(dplyr)
plot(dk)
plot(aseg)

labels_dk<- brain_labels(dk)
#write.csv(labels_dk, "D:/PAtimingBrain/subcortex/labels_dk_ggseg.csv")
labels_aseg<- brain_labels(aseg)
#write.csv(labels_aseg,"D:/PAtimingBrain/subcortex/labels_aseg_ggseg.csv")


###############Subcortical morphology
setwd("F:/PAtimingBrain/Acrophase_BMI/subcortex")
RA_subcor<-read.csv("subcortex_3earlyVS2Inter.csv")


#subcortical beta
plot3<-RA_subcor %>%
  group_by(measure) %>%
  ggplot() +
  geom_brain(atlas = aseg,aes(fill = estimate)) +
  scale_fill_gradient2(low = "royalblue",
                       mid = "white",
                       high = "red3",
                       midpoint = 0)+
  theme_void()+
  facet_wrap(~measure,nrow=2)+
  theme(text = element_text(size =30)) +
  theme(plot.title=element_text(size=18,vjust = 2.5))

plot3
ggsave("subcortex_3earlyVS2Inter_beta.pdf",plot3, width=6,height=6,dpi=300)

##subcortical p

plot4<- RA_subcor %>%
  group_by(measure) %>%
  ggplot() +
  geom_brain(atlas = aseg, aes(fill = p_log)) +
  scale_fill_gradient(low = "white",
                      high = "red3")+
  theme_void()+
  facet_wrap(~measure,nrow=2)+
  theme(text = element_text(size = 30)) +
  theme(plot.title=element_text(size=18,vjust = 2.5))
plot4
ggsave("subcortex_3earlyVS2Inter_uncorP.pdf",plot4, width=6,height=6,dpi=300)

