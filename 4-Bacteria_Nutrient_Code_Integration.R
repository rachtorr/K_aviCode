#### Bacteria and Nutrient Data Code Integration
## Written by Helena Kleiner
## 9 February 2022
## Modified by Cazimir Kowalski
## 27 July 2022

#### set up work space ####

# load necessary libraries
library(tidyverse)
library(lubridate)



#### Part 1: Summarize nutrient and bacteria data ####

## read in data and check for missing data
# the document needs to be a CSV, so change the file format in Excel
bact <- read.csv("K_avi Bacteria and Nutrient Data.csv")

# look at the structure of the file, see what might need to be changed
str(bact)
# most data were formatted correctly, we just have to fix problems with the date
bact$date <- mdy(bact$date)
# rerun the structure function, to know that it worked
str(bact)
# create a column that's specific to the year
bact$year <- year(bact$date)

# if you want, you can also remove the first column and change the column names,
# using colnames function, but neither of these steps are necessary
bact <- bact[,-1]
colnames(bact) <- c("sample_location", "longitude", "latitude", "date",
                     "e_coli", "tot_coliform", "nitrate", "phosphorus",
                     "turbidity", "year")


## now we can start summarizing the data, we'll look at it on an annual level
bact_sum <- bact %>%
  group_by(sample_location, year) %>% # you can group by multiple or a single group(s) to make this summary
  summarize(mean_ecoli = mean(e_coli, na.rm = T),
            median_ecoli = median(e_coli, na.rm = T),
            min_ecoli = min(e_coli, na.rm = T),
            max_ecoli = max(e_coli, na.rm = T),
            mean_tot_col = mean(tot_coliform, na.rm = T),
            median_tot_col = median(tot_coliform, na.rm = T),
            min_tot_col = min(tot_coliform, na.rm = T),
            max_tot_col = max(tot_coliform, na.rm = T),
            mean_phos = mean(phosphorus, na.rm = T),
            median_phos = median(phosphorus, na.rm = T),
            min_phos = min(phosphorus, na.rm = T),
            max_phos = max(phosphorus, na.rm = T),
            mean_turb = mean(turbidity, na.rm = T),
            median_turb = median(turbidity, na.rm = T),
            min_turb = min(turbidity, na.rm = T),
            max_turb = max(turbidity, na.rm = T))

#### Part 2: bind to existing water quality dataset ####

# read in cleaned water quality dataset
water <- read.csv("K'avi Tribe Water Quality Dataset_clean.csv")

# remove the line number (X), column
water <- water[,-1]

# we're going to bind the two datasets together using a function in tidyverse
# full_join() is much more reliable & versitle function than merge(),
# which is a base R function
join <- full_join(water, bact)
# but we're seeing an error, so we need to fix the date in the water df into a date, and make it not a character
water$date <- ymd(water$date)
# now we can try again to join them
join <- full_join(water, bact) # success
# this function is great, because it is telling us all the information it is joining by!


#### Part 3: bind to TEK summary dataset ####

# read in the TEK summary dataset so we know what we're working with
tek_sum <- read.csv("tek_summary.csv")

# it can be helpful to know what our column names are when we're summarizing
# data, so try this to have a list
names(join)

# now we need to summarize the water quality dataset so that we can have them
# in the same format to merge them together
join_sum <- join %>%
  group_by(sample_location) %>%
  # find the mean for all of the different water quality metrics
  summarise(mean_DO = mean(DO),
            mean_temp = mean(water_temp_C),
            mean_sc = mean(specific_conductivity),
            mean_ecoli = mean(e_coli, na.rm = T),
            mean_tot_col = mean(tot_coliform, na.rm = T),
            mean_nit = mean(nitrate, na.rm = T),
            mean_phos = mean(phosphorus, na.rm = T),
            mean_turb = mean(turbidity, na.rm = T))

# create a paired dataset of monitoring site and TEK site in a new data frame
# monitoring site 1 pairs with ceremony site
# monitoring site 2 pairs with medicinal foods site
# monitoring site 3 pairs with hunting grounds
# monitoring site 4 pairs with deep water fishing site
# monitoring site 5 pairs with language camp

dat <- cbind(join_sum[1,], tek_sum[1,])
dat[2,] <- cbind(join_sum[2,], tek_sum[5,])
dat[3,] <- cbind(join_sum[3,], tek_sum[3,])
dat[4,] <- cbind(join_sum[4,], tek_sum[2,])
dat[5,] <- cbind(join_sum[5,], tek_sum[4,])


#### Part 4: Nutrient data failure calculations

# pipe the water quality data - you can either use the bact dataframe or join
# I am just going to work with bact to make sure sure we're working with less data
bact <- bact %>%
  # use the mutate function to create new columns (one for each water quality metric),
  # that checks if the metric for each measurement date pases or fails based on the
  # K'avi water quality standards, where 1 = pass, 0 = fail
  mutate(ecoli_check = if_else(e_coli >= 126, 1, 0),
         tot_col_check = if_else(tot_coliform >= 250, 1, 0),
         nit_check = if_else(nitrate >= 10, 1, 0),
         phos_check = if_else(phosphorus >= 0.07, 1, 0))

# Now that we know when each standard passes / fails, we can count them to
# figure out how often each sampling location fails based on each measurement
# so, pipe our water quality data
rank_sum <- bact %>%
  # remove all the NA rows by filtering for only the rows that have a 1 or 0
  filter(ecoli_check == 1 | ecoli_check == 0) %>%
  # group the data by the sampling location
  group_by(sample_location) %>%
  # summarize the data
  # get the length (number of samples collected at each site)
  summarise(n_sample = length(ecoli_check),
            # find the number of times the ecoli measurement failed to meet the K'avi standards
            ecoli_fail = length(which(ecoli_check == 0)),
            # calculate the % failure rate for ecoli measurements / site
            ecoli_percent = ecoli_fail / n_sample * 100,
            # find the number of times the total coliform failed to meet the K'avi standards
            tot_col_fail = length(which(tot_col_check == 0)),
            # calculate the % failure rate for total coliform  measurements / site
            tot_col_percent = tot_col_fail / n_sample * 100,
            # find the number of times the nitrate measurement
            # failed to meet the K'avi standards
            nit_fail = length(which(nit_check == 0)),
            # calculate the % failure rate for nitrate measurements / site
            nit_percent = nit_fail / n_sample * 100,
            #find the number of times the phosphorous levels failed to meet the standards
            phos_fail = length(which(phos_check == 0)),
            # calculate the % failure rate for phosphorous measurements / site
            phos_percent = phos_fail / n_sample * 100,
            # calculate the average failure rate for each site across all water
            # quality measurements
            average_fail = mean(c(ecoli_percent, tot_col_percent, nit_percent, phos_percent))
  )


## visualize the data
rank_sum %>%
  ggplot(aes(x = sample_location, y = average_fail)) +
  geom_col() +
  xlab("Monitoring Site") +
  ylab("Average Failure for K'avi Water Quality Standards (%)") +
  # wrap the monitoring site names so that the text doesn't overlap
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  theme_classic()
