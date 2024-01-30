## Examining 10 Years of K'avi Tribe Water Quality Dataset
## Written by HSK on 8 December 2021
## Modified by Cazimir Kowalski
## 27 July 2022

## edited by Rachel Torres  
## 24 January 2024 

# clearly state problem and context at the beginning 
# in this file, we are comparing annual water quality metrics (dissolved oxygen, water temp.) at different sites over time 
# in order to do this, we first need to clean the dataset and summarize by year 


##
#### SET UP R Studio ####
##

# clear global environment- the global environment is your workspace
rm(list = ls())

#install necessary packages- packages increase the functionality of R/RStudio
install.packages('tidyverse', 'lubridate', 'gganimate', 'janitor')
# load necessary libraries- libraries are the installed packages
library(tidyverse) # used for 'tidying' data: wrangling, analysis, visualizing 
library(lubridate) # used to handle data as dates 
library(janitor)   # used to explore and clean data 
library(gganimate) # what is gganimate used for? 

# set working directory- the wd is the folder that your related files will be contained in
  # it's important that each class / project has a specific
  # folder on your computer to maintain organization
setwd("~/Documents/GitHub/K_aviCode/")
# if using github project or working from posit cloud, don't need to run setwd()


# read in CSV file that we want to work with - should be located in your working directory
water <- read.csv("K_avi Tribe Water Quality Dataset.csv")

##
#### Examine Dataset ####
##

# str() and glimpse() are functions. we input our data set and they return an output to examine the structure of the dataset
str(water)
glimpse(water)

# would also encourage them to use View(water) so that they can see it's like excel data 
# or also head(water)

# how many rows and how many columns are there?
# what type of data are in each column? is that what you'd expect?
  # despite most of the columns containing what should just be numeric data
  # all of the columns are filled with data that's a character. this suggests
  # we should take a closer look at what is in each of these columns
# what are other problems that you're seeing with this dataset?



#######################
#### Clean Up Data ####
#######################

## rename column names
# see what names of columns are
names(water)
# there are 20 columns, but only 9 of them contain data (NA means Not Available)

# the output of names(water) is a list 
# we can make our own lists using c(); 
# for example here is list, na_names, of the names of columns we don't want 
na_names <- c("X", "X.1", "X.2", "X.3", "X.4", "X.5", "X.6", "X.7",
  "X.8", "X.9", "X.10")
na_names

# remove the 11 unnecessary columns 2 ways

# 1) you can use Tidyverse and the column names specifically to remove the columns

### select() is a tidyverse function, the minus sign means we are NOT selecting 
water_clean <- water %>% 
  select(-all_of(na_names))

# for tidyverse functions, we can use a pipe (%>%) which is an operator that takes the dataframe and performs a function on it 

# we can also do this with the janitor package, remove_empty() which identifies NAs and removes
water_clean <- water %>% 
  remove_empty("cols")

# now look at your data water_clean using one of the previous functions 

# why change names? 
### - it's easier to not have uppercase letters 
### - we want it to be all one word with no spaces or periods 
### - standard practice is _ and not . between words 

# here we can use clean_names() from janitor library
water_clean <- clean_names(water_clean)


# we can also do this manually by using select() from tidyverse, and rename the columns selected
### - some words we might want to shorten i.e. temperature = 'temp'
water_tidy <- water %>%
  select(sample_location = "Sample.Location",
         longitude = "Longitude",
         latitude = "Latitude",
         date = "Date",
         DO = "Dissolved.Oxygen.mg.L",
         water_temp_C = "Water.Temperature.0C",
         water_temp_F = "Water.Temperature.0.F",
         specific_conductivity = "Specific.Conductance.umhos",
         discharge = "Discharge.ft3.sec")

# we will work with tidy going forward, can delete water_clean example - they are the same just different column names 
rm(water_clean)


# let's look at the summarized dataset  
summary(water_tidy) # when we run summary, all columns that we want to be numeric are listed as characters - why? 

# here we could manually look for the repeated column headers that are throughout
# the dataset OR we could use text recognition to find these rows
# rows we're concerned about: 133, 266, 399, 532. <-- how did we know this? 

# identify duplicates 
get_dupes(water_tidy) # this is a function from janitor to identify any duplicated rows 
# in the output we see that despite having mostly numeric values, the lines that are duplicated have the col names listed again - we want to remove these 


# 1) you can use Tidyverse to remove all the rows that have specific text in a specific column
## introduce filter() here 
water_filt <- water_tidy %>%
  filter(sample_location != "Sample Location") # filter function takes a criteria for a column and checks whether it is true or not, here "!=" means it is not equal to 

# run summary again
summary(water_filt)

# dates in R are a separate data category 
## fix dates that are incorrect
water_filt$date <- mdy(water_filt$date) # mdy() is a function from lubridate package
# now run summary again and look at 'date' column
summary(water_filt)


## fix structure of each column as we'll need it for analysis
#  even though we removed the col names with characters, DO, water_temp_C, water_temp_F, specific_conductivity, discharge are all columns that need to be numeric values ]
# we can do this using tidyverse function mutate 
water_filt <- water_filt %>% mutate(
  DO = as.numeric(DO),
  water_temp_C = as.numeric(water_temp_C),
  water_temp_F = as.numeric(water_temp_F),
  specific_conductivity = as.numeric(specific_conductivity),
  discharge = as.numeric(discharge)
)


# confirm structure of all columns in dataframe
str(water_filt) # note the type of data we now have - character, date, numeric - does it make sense which is which ? 
summary(water_filt)

## create a column just including the year
# for analysis we'll need to group data by year, so let's make one more column
# that is the year the sample was collected
# because our date column is the type 'Date', we can use the 'year' function from lubridate to extract the year and make it another column 
water_filt$year <- year(water_filt$date) 
# this is another case where mutate can be used 
water_filt <- water_filt %>% mutate(year = year(date))

## again look at data to see how it has been changed 

# write the data frame as another CSV so this cleaned data set can be used
# for other analyses
write.csv(water_filt, file = "K'avi Tribe Water Quality Dataset_clean.csv")


### ---- Pause ---- ###

#####################################
#### Analyze and visualize data ####
###################################

# plot the data to look and see if we have any outliers or misentered data we
# might be concerned about
water_filt %>%
  ggplot(aes(x = date, y = water_temp_C, color = sample_location)) +
  geom_line() 

# here do another ggplot examples 


## here is a place to introduce ggplot cheatsheet: https://www.maths.usyd.edu.au/u/UG/SM/STAT3022/r/current/Misc/data-visualization-2.1.pdf

# we want to visualize annual values, to do this we need to summarize our data and save it as a new dataframe 

# create a dataframe of the summary statistics
water_summary <- water_filt %>%
  # group the data first by sampling location and then year
  group_by(sample_location, year) %>%
  # summarize the data
  # structure of summarize = (new_column_name = function(column from water df))
  summarize(# calculate the mean
            mean_temp = mean(water_temp_C),
            mean_DO = mean(DO),
            # calculate the median
            median_temp = median(water_temp_C),
            median_DO = median(DO),
            # calculate the minimum
            min_temp = min(water_temp_C),
            min_DO = min(DO),
            # calculate the maximum
            max_temp = max(water_temp_C),
            max_DO = max(DO),
            # calculate the standard deviation
            sd_temp = sd(water_temp_C),
            sd_DO = sd(DO),
            # calculate the number of observations
            n_temp = length(water_temp_C),
            n_DO = length(DO),
            # calculate the standard error
            se_temp = sd_temp / sqrt(n_temp),
            se_DO = sd_DO / sqrt(n_DO)
            )

# compared with previous data frame water_filt, what is different?
# we summarised the data, how many rows are there now, how many variables? 
str(water_summary)

# plot the water mean water temperature data
# call the dataframe you want to use
water_summary %>%
  # assign the x, y variables, and grouping to color the data
  ggplot(aes(x = year, y = mean_temp, color = sample_location)) +
  # use geom_point to plot a data point for each year
  geom_point() + geom_line() +

  #geom_errorbar(aes(ymin = mean_temp - se_temp, ymax = mean_temp + se_temp),
   #             width=.2,
    #            position=position_dodge(0.05))
  # Georgia: I tried adding SE bars to the plot and it ended up just becoming overwhelming,
  # so it's probably something we don't want to include

  # pick a theme to clean up plot
  theme_bw() +
  # add plot and axis titles
  ggtitle("K'avi Tribe Mean Annual Water Temperature") +
  xlab("Year") +
  ylab("Mean Water Temperature (°C)")

# could do a reasoning check - based on photo, why do you think monitoring sites 1 and 5 are colder? 
# could also say something about temp. axis. (5C ~ 41F; 10C ~ 50F)

# if we want to do error bars, separate by site and facet wrap
water_summary %>%
  # assign the x, y variables, and grouping to color the data
  ggplot(aes(x = year, y = mean_temp, color = sample_location)) +
  # use geom_point to plot a data point for each year
  geom_point() + 
  # visualizing uncertainty with se 
  geom_errorbar(aes(ymin = mean_temp - se_temp, ymax = mean_temp + se_temp, col=sample_location)) + 
  # pick a theme to clean up plot
  theme_bw() +
  # add plot and axis titles
  ggtitle("K'avi Tribe Mean Annual Water Temperature") +
  xlab("Year") +
  ylab("Mean Water Temperature (°C)") + facet_wrap('sample_location', nrow=1)


# plot the mean DO data - why do we care about DO? what is it? 
# important for water quality, aquatic life needs DO, but not too much or too little. levels below 5mg/L are low enough to stress out fish 
# Link to EPA description: https://www.epa.gov/national-aquatic-resource-surveys/indicators-dissolved-oxygen#:~:text=Dissolved%20oxygen%20(DO)%20is%20the,of%20a%20pond%20or%20lake.

# call the dataframe you want to use
water_summary %>%
  # assign the x, y variables, and grouping to color the data
  ggplot(aes(x = year, y = mean_DO, color = sample_location)) +
  # use geom_point to plot a data point for each year
  geom_point() + geom_line() + 
  # pick a theme to clean up plot
  theme_bw() +
  # add plot and axis titles
  ggtitle("K'avi Tribe Mean Annual Water Dissolved Oxygen") +
  xlab("Year") +
  ylab("Mean Dissolved Oxygen")

# can show the error bars for this as well 
water_summary %>%
  # assign the x, y variables, and grouping to color the data
  ggplot(aes(x = year, y = mean_DO, color = sample_location)) +
  # use geom_point to plot a data point for each year
  geom_point() + 
  # visualizing uncertainty with se 
  geom_errorbar(aes(ymin = mean_DO - se_DO, ymax = mean_DO + se_DO, col=sample_location)) + 
  # pick a theme to clean up plot
  theme_bw() +
  # add plot and axis titles
  ggtitle("K'avi Tribe Mean Annual Water Temperature") +
  xlab("Year") +
  ylab("Mean Water Temperature (°C)") + facet_wrap('sample_location', nrow=1)
# outlier at site 1 
# could ask questions: why are values dropping over time at monitoring site 2? 


# topics covered:
# cleaning data (removed unnecessary columns and rows with repeated header)
# summarizing 
# filtering (example used was to take out the rows with text of col headers in them, not to extract desired values)
# ggplot - annual time series (point and line)



