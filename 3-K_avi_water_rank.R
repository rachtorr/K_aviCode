#### K'avi Tribe Water Quality Rating + Visualizing
## Written by Helena S Kleiner
## 2 February 2022
## Modified by Cazimir Kowalski
## 27 July 2022

#### set up work space ####
# clear global environment

# load necessary libraries
library(tidyverse)
# important cleaned water quality dataset
water <- read.csv("K'avi Tribe Water Quality Dataset_clean.csv")
tek_sum <- read.csv("tek_summary.csv")

#### Rate the water quality data ####

# pipe the water quality data
water <- water %>%
  # use the mutate function to create new columns (one for each water quality metric),
  # that checks if the metric for each measurement date pases or fails based on the
  # K'avi water quality standards, where 1 = pass, 0 = fail
  mutate(temp_check = if_else(water_temp_C <= 15, 1, 0), # should it be less than OR less than and equal to
         DO_check = if_else(DO >= 12, 1, 0),
         # pH_check = if_else(pH < 7.1, 1, 0)
         # there's no pH dataset in the data you gave me
         SC_check = if_else(specific_conductivity <= 400, 1, 0))

# Now that we know when each standard passes / fails, we can count them to
# figure out how often each sampling location fails based on each measurement
# so, pipe our water quality data
rank_sum <- water %>%
  # group the data by the sampling location
  group_by(sample_location) %>%
  # summarize the data
            # get the length (number of samples collected at each site)
  summarise(n_sample = length(temp_check),
            # find the number of times the temperature measurement failed to meet the K'avi standards
            temp_fail = length(which(temp_check == 0)),
            # calculate the % failure rate for temp measurements / site
            temp_percent = temp_fail / n_sample * 100,
            # find the number of times the DO measurement failed to meet the K'avi standards
            DO_fail = length(which(DO_check == 0)),
            # calculate the % failure rate for DO measurements / site
            DO_percent = DO_fail / n_sample * 100,
            # find the number of times the specific conductivity measurement
            # failed to meet the K'avi standards
            SC_fail = length(which(SC_check == 0)),
            # calculate the % failure rate for temp measurements / site
            SC_percent = SC_fail / n_sample * 100,
            # calculate the average failure rate for each site across all water
            # quality measurements
            average_fail = mean(c(temp_percent, DO_percent, SC_percent))
            )

## create a new data frame that merges water quality ranking data with TEK data

# monitoring site 1 pairs with ceremony site
# monitoring site 2 pairs with medicinal foods site
# monitoring site 3 pairs with hunting grounds
# monitoring site 4 pairs with fishing site
# monitoring site 5 pairs with language camp

dat <- cbind(rank_sum[1,],tek_sum[1,])
dat[2,] <- cbind(rank_sum[2,], tek_sum[5,])
dat[3,] <- cbind(rank_sum[3,], tek_sum[3,])
dat[4,] <- cbind(rank_sum[4,], tek_sum[2,])
dat[5,] <- cbind(rank_sum[5,], tek_sum[4,])


## visualize the data
dat %>%
  # plot the average failure rate for each monitoring site on x-axis against
  # average TEK ranking based on site pairings
  ggplot(aes(x = average_fail, y = mean_tek)) +
  # plot these data as points, make the point size larger so it's more visible,
  # and color by monitoring site
  geom_point(aes(color = sample_location, size = 2.5)) +
  # add x-axis label
  xlab("Average Failure for K'avi Water Quality Standards (%)") +
  # add y-axis label
  ylab("Average TEK Ranking by K'avi") +
  # remove the legend for the point size
  guides(size = FALSE) +
  # clean up plot by changing the theme
  theme_classic()

# used tidyverse filter to see how many were above thresholds 
# also introduced ifelse in this part 
# summarised by percent of samples that failed test and plotted 
# could ask to do different plots here 
