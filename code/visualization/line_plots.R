## line Charts
library(ggplot2)
#devtools::install_github("ricardo-bion/ggradar", dependencies = TRUE)
library(ggradar)
suppressPackageStartupMessages(library(dplyr))
library(scales)
library(fmsb)

df <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/Visualization/model_ensemble_zscores.csv")

df <- remove_rownames(df)
df <- column_to_rownames(df, var = "variable")

# Temp and precip plot averaged over models
df <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/delta_df.csv")
df <- df %>%
  gather(month, delta, 2:13)

p <- ggplot(df, aes(month, delta, colour = variable, group = variable)) +  
  geom_point() +
  geom_line() +
  scale_colour_brewer(palette="Set2", "") +
  labs(title= "Monthly Change Relative to Historical Variability,\nGabon",
       x="Month", 
       y="Z-score")
ggsave("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/Visualization/charts/monthly_zscores.png", p, width=6, height=5, units="in", dpi = 300)


df <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/delta_df.csv", stringsAsFactors = FALSE)

# reshape table to create average over GCMS for variables
df <- df[c("model","variable", "layer", "zscore")]
df$layer <- as.character(df$layer)

# Temperature plot
df_temp <- df[df$variable=="temp",]
df_temp$month <- month.abb[as.numeric(df_temp$layer)]
df_temp$month <- factor(df_temp$month, levels = c("May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr"))

p <- ggplot(df_temp, aes(month, zscore, colour = model, group=model)) +  
  geom_point() +
  geom_line() +
  scale_colour_brewer(palette="Paired", "") +
  labs(title= "Monthly Temperature Change Relative\n to Historical Variability, Gabon",
       x="Month", 
       y="Z-score")
ggsave("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/Visualization/charts/monthly_temp_zscores.png", p, width=6, height=5, units="in", dpi = 300)

# precipitation plot
df_precip <- df[df$variable=="prec",]
df_precip$month <- month.abb[as.numeric(df_precip$layer)]
df_precip$month <- factor(df_precip$month, levels = c("May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr"))

p <- ggplot(df_precip, aes(month, zscore, colour = model, group=model)) +  
  geom_point() +
  geom_line() +
  scale_colour_brewer(palette="Paired", "") +
  labs(title= "Monthly Precipitation Change Relative\n to Historical Variability, Gabon",
       x="Month", 
       y="Z-score")
ggsave("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/Visualization/charts/monthly_prec_zscores.png", p, width=6, height=5, units="in", dpi = 300)

