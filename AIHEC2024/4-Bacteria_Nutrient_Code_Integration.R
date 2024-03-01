#### Bacteria and Nutrient Data Code Integration
## Written by Helena Kleiner
## 9 February 2022
## Modified by Cazimir Kowalski
## 27 July 2022
## edited by Rachel Torres Feb 22 2024 

#### set up work space ####

# load necessary libraries
library(tidyverse)
library(lubridate)
library(janitor)

# This activity repeats the previous water quality activity with a new dataset on bacteria and nutrients 
# the same steps are taken:
# loading data, cleaning, summarising, joining, and plotting

# new functions include: clean_names(), full_join() 
# functions we've already used include: mdy(), year(), select(), group_by() and summarize_at(), mutate(), filter(), ggplot(), ifelse()  

#### Part 1: Summarize nutrient and bacteria data ####

## read in data and check for missing data
bact <- read.csv("K_avi Bacteria and Nutrient Data.csv")

# look at the structure of the file, see what might need to be changed
str(bact)
# most data were formatted correctly, we just have to fix problems with the date
bact$date <- mdy(bact$date)
# rerun the structure function, to know that it worked
str(bact)
# create a column that's specific to the year
bact$year <- year(bact$date)

# if you want, you can also remove the first column using select and a minus (-)
bact <- bact %>% select(-X)

# as an option, you can also change the column names to be all lower case 
# we previously did this using select, but let's use a new function from janitor package 
?clean_names

bact_clean <- clean_names(bact)
head(bact_clean)

## now we can start summarizing the data, we'll look at it on an annual level
bact_sum <- bact_clean %>% 
  group_by(sample_location, year) %>%  # we want one data point per year and sample location, so we are using group() 
  summarize_at(vars(e_coli_col_100_m_l, total_coliform_col_100_m_l, mg_l, turbidity_ntu),
               list(mean=mean, median=median, min=min, max=max), na.rm=TRUE)

head(bact_sum)

#########################################################
#### Part 2: bind to existing water quality dataset ####
#######################################################

# read in cleaned water quality dataset
water <- read.csv("K'avi Tribe Water Quality Dataset_clean.csv")

# remove the line number (X), column
water <- water %>% select(-X)

# we're going to bind the two datasets together using a function in tidyverse
# full_join() is much more reliable & versitle function than merge(),
# which is a base R function
water_bact <- full_join(water, bact_clean)
# but we're seeing an error, so we need to fix the date in the water df into a date, and make it not a character
water$date <- ymd(water$date)
# now we can try again to join them
water_bact <- full_join(water, bact_clean) # success
# this function is great, because it is telling us all the information it is joining by!

##############################################
#### Part 3: bind to TEK summary dataset ####
############################################

# read in the TEK summary dataset so we know what we're working with
tek_sum <- read.csv("tek_summary.csv")

# it can be helpful to know what our column names are when we're summarizing
# data, so try this to have a list
names(water_bact)

# now we need to summarize the water quality dataset so that we can have them
# in the same format to merge them together
water_bact_mean <- water_bact %>%
  group_by(sample_location) %>%
  # find the mean for all of the different water quality metrics
  summarise(mean_DO = mean(DO),
            mean_temp = mean(water_temp_C),
            mean_sc = mean(specific_conductivity),
            mean_ecoli = mean(e_coli_col_100_m_l, na.rm = T),
            mean_tot_col = mean(total_coliform_col_100_m_l, na.rm = T),
            mean_nit = mean(nitrates_mg_l, na.rm = T),
            mean_phos = mean(mg_l, na.rm = T),
            mean_turb = mean(turbidity_ntu, na.rm = T))


tek_water_bact_mean <- inner_join(water_bact_mean, tek_sum)

# how might we want to visualize this combined dataframe?
# make a plot here with ggplot that includes: the tek rank, the monitoring site, and the mean nitrates (or pick another variable from the bacteria and nutrients data)


  
###############################################
#### Part 4: Nutrient data failure calculations
###############################################

# here we can review the ifelse() function 
# the format is ifelse(condition, value if true, value if false) 

# pipe the water quality data - you can either use the bact dataframe or join
# I am just going to work with bact to make sure sure we're working with less data
bact_check <- bact_clean %>%
  # use the mutate function to create new columns (one for each water quality metric),
  # that checks if the metric for each measurement date pases or fails based on the
  # K'avi water quality standards, where 1 = pass, 0 = fail
  mutate(ecoli_check = if_else(e_coli_col_100_m_l >= 126, 1, 0),
         tot_col_check = if_else(total_coliform_col_100_m_l >= 250, 1, 0),
         nit_check = if_else(nitrates_mg_l >= 10, 1, 0),
         phos_check = if_else(mg_l >= 0.07, 1, 0))

# Now that we know when each standard passes / fails, we can count them to
# figure out how often each sampling location fails based on each measurement
# so, pipe our water quality data
rank_sum <- bact_check %>%
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

# the above plot shows us the average failure across all water standards by site, but doesn't show us which water standards are the highest percents or which monitoring sites have higher tek ranking
## what if we want to visualize multiple variables at once? we can do this by assigning variables to shape and color 
rank_sum %>% 
  inner_join(tek_sum) %>% 
  select(mean_tek, site, ecoli_percent, tot_col_percent, nit_percent, phos_percent, site) %>% 
  pivot_longer(c(ecoli_percent, tot_col_percent, nit_percent, phos_percent)) %>% 
  ggplot(aes(x=name, y=site, size=value, col=mean_tek)) +
  geom_count()



##############################################
# topics covered in part 4 include:
## dataframe manipulation: mutate, select, inner_join, pivot_longer 
## group_by and summarize
## another application of ifelse function 
## joining data frames with the same columns 
## more visualization with ggplot 
  

