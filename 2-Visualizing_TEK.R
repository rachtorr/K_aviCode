# Creating TEK values and visualizing with water temp data
# 21 January 2022
# code by Helena S Kleiner for Georgia Smies
## Modified by Cazimir Kowalski
## 27 July 2022
# edited by Rachel Torres
# 24 Jan 2024 

# in this part, we are loading in a new dataset with the TEK site rankings, and summarizing it to combine with our water quality data
# the end result is a plot that includes both the water quality metrics and ranking of TEK site

# we will use more tidyverse functions and ggplot for plotting 
# new functions include: pivot_longer, inner_join 
# if you are starting from the beginning and have not recently done part 1: Kavi_Tribe_Water_Quality.R, you may want to load your packages and set your working directory
library(tidyverse)
setwd("~/Documents/GitHub/K_aviCode/")


#### set up data from tek survey ####

#import survey data file
tek_values <- read.csv("TEKresponses.csv")

####################################
#### Prep TEK data frame ##########
###################################

#delete unnecessary timestamp column
# in this example we are selecting every column except the one listed, we use a negative sign to say "Don't Select"
tek_values <- tek_values %>%
  select(-"Timestamp")

#convert the data from a wide format to a long format
?pivot_longer

tek_values <- pivot_longer(data = tek_values, cols = everything(), names_to = "site",
                           values_to = "tek_value")
# more info for pivot longer - we are reshaping data frame so that rather than several columns, we have only 2 columns to summarize by site  - 
# as good practice in general - we want each column to be a variable and each row to be an observation - in this case it is two variables: site and rank 
# link to visualize pivot_longer: https://epirhandbook.com/en/images/pivoting/pivot_longer_new.png


# we can visualize the data as-is before summarizing 
# because we pivoted longer, we can make the 'site' variable a color in our plots 
ggplot(tek_values, aes(y=tek_value, x=site, col=site)) + geom_boxplot()


# based on photo, each monitoring site is located relatively close to one of the cultural sites, we will pair each one below 
tek_values$sample_location = NA # create a new column 
# next assign values to sample_location based on site rows 


# the following formatting is assigning a value to the rows wherever the statement inside the bracket is true
# for example: 
# dataframe$new_column[dataframe$existing_column=="existing label"] <- "new label"

# monitoring site 1 pairs with ceremony site
tek_values$sample_location[tek_values$site=="Ceremony.Site"] <- "Monitoring Site 1"
# monitoring site 2 pairs with medicinal foods site
tek_values$sample_location[tek_values$site=="Medicinal.Food.Site"] <- "Monitoring Site 2"
# monitoring site 3 pairs with hunting grounds
tek_values$sample_location[tek_values$site=="Hunting.Grounds"] <- "Monitoring Site 3"
# monitoring site 4 pairs with fishing site
tek_values$sample_location[tek_values$site=="Fishing.Site"] <- "Monitoring Site 4"
# monitoring site 5 pairs with language camp
tek_values$sample_location[tek_values$site=="Language.Camp"] <- "Monitoring Site 5"

# see we have added a third column that labels the closest monitor site 
str(tek_values) 


######################################
#### summarize and visualize data ####
######################################

# gather summary statistics on the TEK value dataset by site
# in this use of summary, we only have one variable, so we are running the functions directly 
tek_summary <- tek_values %>%
  group_by(site, sample_location) %>%
  summarize(mean_tek = mean(tek_value),
            sd = sd(tek_value),
            n = length(tek_value),
            se_tek = sd / sqrt(n))

str(tek_summary)


# write summary table as a csv
write.csv(tek_summary, "tek_summary.csv")

###############################################
#### visualize tek data with water temperature 
###############################################

# if you need to reload water data, do that here
water_num <- readr::read_csv("K'avi Tribe Water Quality Dataset_clean.csv")

# summarize the water temperature data by sampling location
temp_summary <- water_num %>%
  group_by(sample_location) %>%
  summarise(mean_temp = mean(water_temp_C),
            # calculate the standard deviation
            sd_temp = sd(water_temp_C),
            # calculate the number of observations
            n_temp = length(water_temp_C),
            # calculate the standard error
            se_temp = sd_temp / sqrt(n_temp))


# next we combine our two summary datasets: temp and tek 
# we use inner_join, which looks for the column that is the same in each dataset and matches them together 
?inner_join

tek_water_temp_data <- inner_join(temp_summary, tek_summary)


# plot mean temp v mean tek by paired site with standard error for each
tek_water_temp_data %>%
  ggplot(aes(x = mean_temp, y = mean_tek,
             xmin = mean_temp - se_temp, xmax = mean_temp + se_temp,
             ymin = mean_tek - se_tek, ymax = mean_tek + se_tek)) +
  geom_point(aes(color = sample_location)) +
  geom_errorbar(aes(color = sample_location)) +
  geom_errorbarh(aes(color = sample_location)) +
  xlab("Mean Water Temperature (°C)") +
  ylab("Mean K'vai TEK Ranking") +
  theme_classic()



#######################################
# We can repeat this plot with DO data 
#######################################

# summarise DO by location only 
do_summary <- water_num %>%
  group_by(sample_location) %>%
  summarise(mean_DO = mean(DO),
            # calculate the standard deviation
            sd_DO = sd(DO),
            # calculate the number of observations
            n_DO = length(DO),
            # calculate the standard error
            se_DO = sd_DO / sqrt(n_DO))

# join 
tek_water_data <- inner_join(do_summary, tek_summary)

# plot 
tek_water_data %>%
  ggplot(aes(x = mean_DO, y = mean_tek,
             xmin = mean_DO - se_DO, xmax = mean_DO + se_DO,
             ymin = mean_tek - se_tek, ymax = mean_tek + se_tek)) +
  geom_point(aes(color = sample_location)) +
  geom_errorbar(aes(color = sample_location)) +
  geom_errorbarh(aes(color = sample_location)) +
  xlab("Mean Dissolved Oxygen (mg/L)") +
  ylab("Mean K'vai TEK Ranking") +
  theme_classic()


## topics covered: 
# summarized TEK location rankings and plotted with water sample 
# more ggplot and tidyverse 
# new functions introduced: pivot_longer and inner_join

