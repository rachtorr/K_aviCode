# Creating TEK values and visualizing with water temp data
# 21 January 2022
# code by Helena S Kleiner for Georgia Smies
## Modified by Cazimir Kowalski
## 27 July 2022

# edited by Rachel Torres
# 24 Jan 2024 

#### set up work space ####

#import survey data file
tek_values <- read.csv("TEKresponses.csv")
#delete unnecessary timestamp column
tek_values <- tek_values %>%
  select(-c("Timestamp",))
#convert the data from a wide format to a long format
tek_values <- pivot_longer(data = tek_values, cols = everything(), names_to = "site",
                           values_to = "tek_value")
# more info for pivot longer - we are reshaping data frame so that rather than several columns, we have only 2 columns to summarise by site  - 
# as good practice in general - we want each column to be a variable and each row to be an observation - in this case it is two variables: site and rank 
# link to visualizer: https://epirhandbook.com/en/images/pivoting/pivot_longer_new.png


##* can we match here and save the edited one 
# monitoring site 1 pairs with ceremony site
# monitoring site 2 pairs with medicinal foods site
# monitoring site 3 pairs with hunting grounds
# monitoring site 4 pairs with fishing site
# monitoring site 5 pairs with language camp
tek_values$sample_location = NA
tek_values$sample_location[tek_values$site=="Ceremony.Site"] <- "Monitoring Site 1"
tek_values$sample_location[tek_values$site=="Medicinal.Food.Site"] <- "Monitoring Site 2"
tek_values$sample_location[tek_values$site=="Hunting.Grounds"] <- "Monitoring Site 3"
tek_values$sample_location[tek_values$site=="Fishing.Site"] <- "Monitoring Site 4"
tek_values$sample_location[tek_values$site=="Language.Camp"] <- "Monitoring Site 5"

head(tek_values) # see we have added a third column that labels the closest monitor site 

#### summarize and visualize data ####

# gather summary statistics on the TEK value dataset by site
sum_draws <- tek_values %>%
  group_by(site, sample_location) %>%
  summarize(mean_tek = mean(tek_value),
            sd = sd(tek_value),
            n = length(tek_value),
            se_tek = sd / sqrt(n))

head(sum_draws)
# here is somewhere questions can be asked - maybe could rank them? use the order function 
sum_draws$site[order(sum_draws$mean_tek, decreasing = T)] # highest rank is most important 

# write summary table as a csv
write.csv(sum_draws, "tek_summary.csv")

# summarize the water quality data by sampling location
# in these locations, can we be more specific on the names of dataframe 
# here we could also read in the water csv that we saved in the previous R file 
sum_water <- water_filt %>%
  group_by(sample_location) %>%
  summarise(mean_temp = mean(water_temp_C),
            # calculate the standard deviation
            sd_temp = sd(water_temp_C),
            # calculate the number of observations
            n_temp = length(water_temp_C),
            # calculate the standard error
            se_temp = sd_temp / sqrt(n_temp))

# create a paired dataset of monitoring site and TEK site in a new data frame
# monitoring site 1 pairs with ceremony site
# monitoring site 2 pairs with medicinal foods site
# monitoring site 3 pairs with hunting grounds
# monitoring site 4 pairs with fishing site
# monitoring site 5 pairs with language camp

# dat <- cbind(sum[1,], sum_draws[1,])
# dat[2,] <- cbind(sum[2,], sum_draws[5,])
# dat[3,] <- cbind(sum[3,], sum_draws[3,])
# dat[4,] <- cbind(sum[4,], sum_draws[2,])
# dat[5,] <- cbind(sum[5,], sum_draws[4,])

# need to explain inner_join here 
# 
tek_water_data <- inner_join(water_summary, sum_draws)

# plot mean temp v mean tek by paired site with standard error for each
tek_water_data %>%
  ggplot(aes(x = mean_temp, y = mean_tek,
             xmin = mean_temp - se_temp, xmax = mean_temp + se_temp,
             ymin = mean_tek - se_tek, ymax = mean_tek + se_tek)) +
  geom_point(aes(color = sample_location)) +
  geom_errorbar(aes(color = sample_location)) +
  geom_errorbarh(aes(color = sample_location)) +
  xlab("Mean Water Temperature (°C)") +
  ylab("Mean K'vai TEK Ranking") +
  theme_classic()

# could repeat this entire thing with DO 

# summarise DO by location only 
sum_water <- water_filt %>%
  group_by(sample_location) %>%
  summarise(mean_DO = mean(DO),
            # calculate the standard deviation
            sd_DO = sd(DO),
            # calculate the number of observations
            n_DO = length(DO),
            # calculate the standard error
            se_DO = sd_DO / sqrt(n_DO))

# join 
tek_water_data <- inner_join(sum_water, sum_draws)

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


# summarised location rankings and plotted with water sample 
# more ggplot and tidyverse 
# pivot longer was introduced 

