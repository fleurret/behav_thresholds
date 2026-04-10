library(ggplot2)
library(dplyr)
library(tidyr)
library(lsmeans)
library(glmmTMB)
library(DHARMa)
library(car)
library(stats)
library(plotly)
library(rcompanion)
library(simr)


#### BEHAVIOR ####
# load your csv file
df = read.csv('D:/Caras/Analysis/Caspase/Acquisition/Asbah cohort/stats_output.csv')

# define your variables
# group_by is for any fixed and random effects
# summarise is for the response variable
# make sure they match the column headers in your dataframe
df_grouped = df %>% group_by(Subject, Day, Condition) %>%
  summarise(
    threshold = Threshold,
  )

# change day to log scale
df_grouped$Day = log(df_grouped$Day)
glm_data = df_grouped

##### L5 ET ablations #####
# define data for GLM
categories <- c("drGFP-Cre (IC) + Casp3 (ACx)","drGFP-Cre (IC) + Saline (ACx)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# this model asks if training day/group affects thresholds
glm_model <- glmmTMB(threshold ~ Day*Condition + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)



##### DCIC ablations #####
categories <- c("Ibotenic Acid (IC)","Saline (IC)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# this model asks if training day/group affects thresholds
glm_model <- glmmTMB(threshold ~ Day*Condition + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass
summary(glm_model)

# run ANOVA
Anova(glm_model)



#### HISTOLOGY ####
# load your csv file
df = read.csv('D:/Caras/Analysis/Caspase/Acquisition/Asbah cohort/ihc quantification.csv')

# define your variables
# group_by is for any fixed and random effects
# summarise is for the response variable
# make sure they match the column headers in your dataframe
df_grouped = df %>% group_by(Subject, Condition, Side) %>%
  summarise(
    hist = Ablation,
  )

##### L5 ET ablations #####
# define data for GLM
categories <- c("drGFP-Cre (IC) + Casp3 (ACx)","drGFP-Cre (IC) + Saline (ACx)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# this model asks if group and side (L or R) affects histology quantification
glm_model <- glmmTMB(hist ~ Side*Condition + (1|Subject),
                     data=glm_data, 
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# post-hoc tests
# let's look at difference between groups
pairs(regrid(emmeans(glm_model,  ~ Side*Condition)),  simple = 'Condition', adjust='Bonferroni')

# now difference between sides
pairs(regrid(emmeans(glm_model,  ~ Side*Condition)),  simple = 'Side', adjust='Bonferroni')



##### DCIC ablations #####
categories <- c("Ibotenic Acid (IC)","Saline (IC)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# this model asks if group and side (L or R) affects histology quantification
glm_model <- glmmTMB(hist ~ Side*Condition + (1|Subject),
                     data=glm_data, 
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# post-hoc tests
# let's look at difference between groups
pairs(regrid(emmeans(glm_model,  ~ Side*Condition)),  simple = 'Condition', adjust='Bonferroni')

# now difference between sides
pairs(regrid(emmeans(glm_model,  ~ Side*Condition)),  simple = 'Side', adjust='Bonferroni')






#### HISTOLOGY/BEHAVIOR CORRELATION ####

# load your csv file
df = read.csv('D:/Caras/Analysis/Caspase/Acquisition/Asbah cohort/learning_rates and ihc.csv')


##### Starting threshold #####
# define your variables
df_grouped = df %>% group_by(Subject, Condition, L_ablation, R_ablation) %>%
  summarise(
    R = Starting_threshold,
  )

###### L5 ET ablations ######
categories <- c("drGFP-Cre (IC) + Casp3 (ACx)","drGFP-Cre (IC) + Saline (ACx)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(R^2 ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R^2 ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)



###### DCIC ablations ######
categories <- c("Ibotenic Acid (IC)","Saline (IC)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(R^3 ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R^3 ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)



##### Best threshold #####
# define your variables
df_grouped = df %>% group_by(Subject, Condition, L_ablation, R_ablation) %>%
  summarise(
    R = Best_threshold,
  )

###### L5 ET ablations ######
categories <- c("drGFP-Cre (IC) + Casp3 (ACx)","drGFP-Cre (IC) + Saline (ACx)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(R ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)



###### DCIC ablations ######
categories <- c("Ibotenic Acid (IC)","Saline (IC)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(R^2 ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R^2 ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)



##### Learning rate #####
# define your variables
df_grouped = df %>% group_by(Subject, Condition, L_ablation, R_ablation) %>%
  summarise(
    R = Learning_rate,
  )

###### L5 ET ablations ######
categories <- c("drGFP-Cre (IC) + Casp3 (ACx)","drGFP-Cre (IC) + Saline (ACx)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(R*2 ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R*2 ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)



###### DCIC ablations ######
categories <- c("Ibotenic Acid (IC)","Saline (IC)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(R ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)



##### FA rate #####
# define your variables
df_grouped = df %>% group_by(Subject, Condition, L_ablation, R_ablation) %>%
  summarise(
    R = FA_rate,
  )

###### L5 ET ablations ######
categories <- c("drGFP-Cre (IC) + Casp3 (ACx)","drGFP-Cre (IC) + Saline (ACx)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(R*10 ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R*10 ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)



###### DCIC ablations ######
categories <- c("Ibotenic Acid (IC)","Saline (IC)")
glm_data = df_grouped[df_grouped$Condition %in% categories,] 

# does L ablation affect behavior?
glm_model <- glmmTMB(log(R) ~ L_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# does R ablation affect behavior?
glm_model <- glmmTMB(R ~ R_ablation + (1|Subject),
                     data=glm_data,
                     family=gaussian)

# check residual normality - should pass without errors
# if there are QQ plot errors, you may need to simplify model or transform variables
simulationOutput <- simulateResiduals(fittedModel = glm_model, plot = T, re.form=NULL)  # pass

# run ANOVA
summary(glm_model)
Anova(glm_model)

# correlation between starting threshold and L ablation
cor.test(glm_data$R, glm_data$L_ablation,
         method = c("pearson"),
         exact = FALSE)

# correlation between starting threshold and R ablation
cor.test(glm_data$R, glm_data$R_ablation,
         method = c("pearson"),
         exact = FALSE)
