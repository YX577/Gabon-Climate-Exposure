## create tables for vizualization
library(tidyr)
library(dplyr)
library(ecoclim)
library(ggplot2)
library(tibble)

# Create tables for monthly radar charts ----------------------------------
df <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/delta_df.csv", stringsAsFactors = FALSE)

# reshape table to create average over GCMS for variables
df <- df[c("model","variable", "layer", "zscore")]
df$layer <- as.character(df$layer)

# average over models
df <- df %>%
  group_by(layer, variable) %>%
  summarise(zscore=mean(zscore))

df <- df %>%
  spread(layer, zscore)

names(df)[2:13] <- c("Jan", "Oct", "Nov", "Dec", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept")

df <- df[c("variable", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec", "Jan", "Feb", "March", "April")]

write.csv(df, "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/Visualization/model_ensemble_zscores.csv", row.names = FALSE)

# Create GCM chart precip on x-axis and temp on y-axis ------------------------------------------------------------------

df <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/delta_df.csv")
df <- df[c("model", "layer","variable", "future_avg", "baseline_avg")]
df$layer <- as.character(df$layer)

temp <- df[df$variable=="temp",]
precip <- df[df$variable=="prec",]

temp <- temp %>%
  group_by(model, variable) %>%
  summarise(baseline_avg=mean(baseline_avg), future_avg=mean(future_avg))
temp$delta_avg <- temp$future_avg - temp$baseline_avg
  
precip <- precip %>%
  group_by(model, variable) %>%
  summarise(baseline_avg=sum(baseline_avg), future_avg=sum(future_avg))
precip$delta_avg <- precip$future_avg - precip$baseline_avg

df <- rbind(temp, precip)
df <- df[c("model", "variable", "delta_avg")]

df <- df %>%
  spread(variable, delta_avg)

df <- remove_rownames(df)
df <- column_to_rownames(df, var = "model")

# Plot
p <- ggplot(df, aes(x=temp, y=prec, label = rownames(df))) +
  geom_point() +
  geom_text(hjust = 0, nudge_x = 0.1) + 
  xlim(-5, 5) +
  labs(title= "Average Model Projections for Gabon",x="\nChange in Annual Temperature (C)", y="Change in Total Precipitation (mm)\n")+
  annotate("text", x = .7, y = -5, label = "warmer/\ndrier", size=4, color="brown") +
  annotate("text", x = .7, y = 5, label = "warmer/\nwetter", size=4, color="magenta") +
  annotate("text", x = -.7, y = -5, label = "cooler/\ndrier", size=4,color="darkblue") +
  annotate("text", x = -.7, y = 5, label = "cooler/\nwetter", size=4, color="purple")
ggsave("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/Visualization/charts/model_projections.png", p, width=6, height=5, units="in", dpi = 300)
  


