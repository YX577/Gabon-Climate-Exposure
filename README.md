# Measuring Climate Change Exposure for Gabon


## Overview
This repo provides scripts for extracting, analyzing, and visualizing temperature and precipitation data for the African country of Gabon.

## Workflow
1. 01-Pre-processing - read data in from PostGIS and join it with other relational tables in the dataset. This was also a first step to look at the data.
2. 02-create-features - write functions to calculate each vegetation index based on spectral bands. For each veg index calculate the mean and standard deviation across time and save as a multiband raster. I used 6 different vegetation inices. 
3. 03-modeling-binary - model and hyperparameter selection using grid search and cross validation using 4 different kinds of models: logistic regression, random forests, support vector classification, and k-nearest neighbors.
4. I included a multi-class notebook to show that I tried!
5. Visualization is not included because it was done in a variety of programs, mainly QGIS and Tableau.

## Metrics used for Measuring Change in Climate
#### Mann-Kendall
The Mann-kendall statistic was used to measure trends for temperature and precipitation for the recent time-series (1979-2013). It is a non-parametric regression commonly used for time-series data to assess monotonic trend (linear or non-linear) significance. It is much less sensitive to outliers and skewed distributions. If the distribution of the deviations from the trend line is approximatly normally distributed, the M-K will return essentially the same result as simple linear regression.
#### Z-scores
Z-scores were used to measure significant  change between the future climatology (2061-2080) and the recent time period (1979-2013). This metric measures magnitude of change by representing how unusual the recent timeslice is relative to baseline variability. For each pixel, for each climate variable, a zscore is calculated by dividing the recent delta by the standard deviation of the baseline. The result (for a given pixel) is the number of standard deviations the recent mean is from the baseline. Assuming the variables are normally distributed (which, *in time*, they mostly are), each of these z-scores is a measure of how statistically significant the climate change was for that variable in that location. This metric shows direction of change in addition to magnitude of change – for example a value of 1 for average temperature means it’s getting warmer by 1 sd, and value of -1 means it’s getting cooler by 1 sd. This metric serves important purposes for climate change analysis: a) it standardizes all variables into one metric so that they can be compared with one another, and b) its more ecologically relevant because life strategies of organisms will generally be adapted to the historical variability of a given climate variable.


## Results
![significance](mann-kendall.png)



