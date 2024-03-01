#### K'avi Tribe Water Quality Rating + Visualizing
## Written by Helena S Kleiner
## 2 February 2022
## Modified by Cazimir Kowalski
## 27 July 2022
## Modified by Rachel Torres 22 Feb 2024 

#### set up work space ####
# clear global environment
rm(list=ls())

# this activity builds on the previous ones by loading in the same data set and creating a check for water quality standards
# familiar functions used include: mutate(), ggplot(), group_by() and summarise(), inner_join() 
# new functions learned include: ifelse(), 

# load necessary libraries
library(tidyverse)
# important cleaned water quality dataset
water <- read.csv("K'avi Tribe Water Quality Dataset_clean.csv")
tek_sum <- read.csv("tek_summary.csv")

#### Rate the water quality data ####

# the next part uses the function if_else, which follows this pattern: 
# if_else(Conditional, if True then return this value, if false then return this value)
?if_else

# pipe the water quality data
water_check <- water %>%
  # use the mutate function to create new columns (one for each water quality metric),
  # that checks if the metric for each measurement date pases or fails based on the
  # K'avi water quality standards, where 1 = pass, 0 = fail
  mutate(temp_check = if_else(water_temp_C <= 15, 1, 0), 
         DO_check = if_else(DO >= 12, 1, 0),
         SC_check = if_else(specific_conductivity <= 400, 1, 0))

# the following plot helps to visualize what is happening with ifelse, using water temperature as an example
# the dashed horizontal line is out conditional, at water temp = 15 
# above that line, water is warmer, and fails our check. the new variable "temp_check" is equal to 0
# below the dashed line, water is normal temperatures and passes, so temp_check = 1 
ggplot(water_check) + geom_hline(aes(yintercept=15), linetype="dashed", size=2) + 
  geom_point(aes(x=as.Date(date), y=water_temp_C, col=as.factor(temp_check))) +
  labs(color="temp_check", x="Date", y="Water Temp. (C)") + 
  geom_text(aes(x=as.Date("1990-1-1"), y=22, label="Fail=0"), col="red", size=6, nudge_x = 100) +
  geom_text(aes(x=as.Date("1990-1-1"), y=12, label="Pass=1"), col="darkgreen", size=6, nudge_x=150)

# you can also use head() or summary() to see the new columns we added with mutate 



# Now that we know when each standard passes / fails, we can count them to
# figure out how often each sampling location fails based on each measurement
# so, pipe our water quality data
rank_sum <- water_check %>%
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
w_check_tek <- inner_join(rank_sum, tek_sum)

## visualize the data
w_check_tek %>%
  # plot the average failure rate for each monitoring site on x-axis against
  # average TEK ranking based on site pairings
  ggplot(aes(x = average_fail, y = mean_tek)) +
  # plot these data as points, make the point size larger so it's more visible,
  # and color by monitoring site
  geom_point(aes(color = sample_location), size = 10) +
  # add x-axis label
  xlab("Average Failure for K'avi Water Quality Standards (%)") +
  # add y-axis label
  ylab("Average TEK Ranking by K'avi") +
  # remove the legend for the point size
  guides(size = FALSE) +
  # clean up plot by changing the theme
  theme_classic()

# what other plots could be made? 

# can create other plots that visualize the different variable percent fails 


### --- finished this activity! ---###

# topics covered in this section:
# introduced ifelse() to create new columns that show whether a variable passed a water quality standard 
# summarised by percent of samples that failed test
# more plotting with ggplot() 

