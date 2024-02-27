## Examining 10 Years of K'avi Tribe Water Quality Dataset
## Written by HSK on 8 December 2021
## Modified by Cazimir Kowalski
## 27 July 2022
## edited by Rachel Torres  
## 24 January 2024 


## in this file, we are comparing annual water quality metrics (dissolved oxygen, water temp.) at different sites over time 
# in order to do this, we are going to clean a dataset and summarize by year, then plot it to visualize  
# we are primarily using these key packages through out workshop 
## tidyverse, lubridate, janitor 

# There are two main variables we work with in this section: stream temperature and dissolved oxygen
# water temperature can be meaningful for protecting aquatic communities while maintaining socio-economic benefits (Ouellet-Proulx et al. 2017). Common water temperatures in lakes and streams range between 4 and 35 °C.
# Dissolved oxygen (DO) is the concentration of oxygen dissolved in water. Common DO concentrations range between 0 and 12 mg L-1 and DO concentrations less than 2 mg L-1 are considered hypoxic



####---SET UP R Studio---####


# clear global environment- the global environment is your workspace
rm(list = ls())

#install necessary packages- packages increase the functionality of R/RStudio 
# if you already installed packages, do not need to do this again! 
install.packages('tidyverse', 'lubridate', 'janitor')

# load necessary libraries- libraries are the installed packages
library(tidyverse) # used for 'tidying' data: wrangling, analysis, visualizing 
library(lubridate) # used to handle data as dates 
library(janitor)   # used to clean data sets

# functions we are learning: 
# tidyverse: select, filter, mutate, ggplot, summarize 
# janitor: get_dupes
# lubridate: mdy, year


# ----------------------------------------------------------------------------
#### start here  ####
# ----------------------------------------------------------------------------
 

# before we dive into the data cleaning part, load this data and let's see a plot 
water_example <- readr::read_csv("tidy_water_quality_dataset.csv")

# run this line for plot
# we will use the ggplot format, which follows:
## ggplot(dataset) + geom_plottype(aes(x, y))
water_example %>%
  ggplot(aes(x = date, y = water_temp_C, color = sample_location)) +
  geom_line() + geom_point() +
  theme_minimal()

# in order to get to this point where we can explore visually, we first have to clean our original data set 

# ----------------------------------------------------------------------------
#### cleaning and organizing our data ####
# ----------------------------------------------------------------------------

# starting at the very beginning! 
# read in CSV file that we want to work with - should be located in your working director
water <- read.csv("K_avi_Tribe_Water_Quality_Dataset.csv")
# to see what the dataset looks like, use View()
View(water)


####---Examine Dataset---####

# str() is a function that gives us the structure of an object in R, here we use it to examine the structure of our dataset 
str(water)

# note that it is displaying the type of data in each column:
## chr stands for character vector, or string - when printed, this type of data will have quotation marks
## logi is short for 'logical' which can contain True or False, but in our case NA 

# how many rows and how many columns are there?
# what type of data are in each column? is that what you'd expect?
    # despite most of the columns containing what should just be numeric data all of the columns are filled with data that's a character. this suggests we should take a closer look at what is in each of these columns
# what are other problems that you're seeing with this dataset?

# we can also preview the first 6 lines of the dataset by using head()
head(water)


####---Clean Up Data---####
# In this section, we are cleaning up the data and making it easier to work with 

# we are working to make our dataset 'tidy' in that it follows:
## each variable is a column
## each observation is a row 
## each value is a single cell 

# first we are going to select the columns we want (not including the empty NA columns) and rename the columns to easier names 
# why change names? 
### - it's easier to not have uppercase letters (R is case sensitive)
### - we want it to be all one word with no spaces or periods 
### - some words we might want to shorten i.e. temperature = 'temp'

# here we are using select() from tidyverse package 
?select
# this allows us to select the columns we want and rename them in the process 
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

#! Your Turn: check how this has changed using either head() or str() from above 



# let's look at the summarized dataset  
summary(water_tidy) 
# when we run summary, variables we expect to be numeric are listed as characters - why? 
# sometimes this happens if there is a row that contains character data mixed in with the numeric data 

# we need our columns to be numeric so we can run analysis and make plots - you get an error if they are characters
plot(water_tidy$date, water_tidy$DO)

# we will check for and identify any duplicates here using the function get_dupes from janitor
?get_dupes 

get_dupes(water_tidy)
# in the output we see that despite having mostly numeric values, the lines that are duplicated have the col names listed again - we want to remove these 

# to remove these rows, we use filter() from tidyverse  
# filter function takes a criteria for a column and checks whether it is true or not, here "!=" means it is not equal to 
water_filt <- water_tidy %>%
  filter(sample_location != "Sample Location") 
# now check if duplicates were removed 
get_dupes(water_filt)

# run summary again
summary(water_filt)
# our numeric variables are still stored as characters, we need to change this 

## fix structure of each column as we'll need it for analysis
#  even though we removed the col names with characters, DO, water_temp_C, water_temp_F, specific_conductivity, discharge are all columns that need to be numeric values 
# we can do this using tidyverse function mutate 
?mutate

water_num <- water_filt %>% mutate(
  DO = as.numeric(DO),
  water_temp_C = as.numeric(water_temp_C)
)

# see the difference
summary(water_num)

#! Your Turn: can you use mutate to change the other variables (water_temp_F, specific_conductivity, discharge) to numeric? Save it as the same dataframe, 'water_num'





# dates in R are a separate data category 
## fix dates that are incorrect with mdy() from lubridate package
?mdy
water_num$date <- mdy(water_num$date) 

#! Your Turn: run summary again and look at 'date' column, which was previously a character



# remember how we got an error when we tried to plot before? now that we have proper date and numeric columns, try again 
plot(water_num$date, water_num$DO)
# this is  the standard R version of plot, but we can make more exciting ones below 

# confirm structure of all columns in dataframe
str(water_num) # note the type of data we now have - character, date, numeric - does it make sense which is which ? 

## create a column just including the year
# for future analysis we'll need to group data by year, so let's make one more column
# that is the year the sample was collected
# because our date column is the type 'Date', we can use the 'year' function from lubridate to extract the year and make it another column 
water_num$year <- year(water_num$date) 

## again look at data to see how it has been changed 
str(water_num)

# write the data frame as another CSV so this cleaned data set can be used
# for other analyses
write.csv(water_num, file = "K_avi_Tribe_Water_Quality_Dataset_clean.csv")

# ----------------------------------------------------------------------------
#### Summarizing and visualizing data ####
# ----------------------------------------------------------------------------
# if you need to re-load your clean dataset, do that here
water_num <- readr::read_csv("K_avi_Tribe_Water_Quality_Dataset_clean.csv")


# plot the data to look and see if we have any outliers or misentered data we might be concerned about
water_num %>%
  ggplot(aes(x = date, y = water_temp_C, color = sample_location)) +
  geom_line() 


#######################################################################
#### Pause here? lunch break 
#######################################################################

# ggplot can be used to do many different types of plots 
# the general format is: 
# ggplot(data, aes(x, y)) + geom_plottype
# see options for plot types at the ggplot cheatsheet: https://www.maths.usyd.edu.au/u/UG/SM/STAT3022/r/current/Misc/data-visualization-2.1.pdf

# when exploring data, it's good to look at distribution of it 
# we can do this with boxplots, histograms, density plots - try those here
water_num %>% 
  ggplot(aes(x=sample_location, y=water_temp_C)) + geom_boxplot()

#! Your Turn: try different plot here using same formula 



# we want to visualize annual values, to do this we need to summarize our data and store it as a new dataset  

# create a dataframe of the summary statistics
water_ann_mean <- water_num %>%
  # group the data first by sampling location and then year
 group_by(sample_location, year) %>%
  # summarize the data
  # summarize() along with across() can be used to apply a function to multiple columns, in our case we use mean, but could change or add to this 
  summarize(across(c(DO, water_temp_C, specific_conductivity, discharge), list(mean=mean))) 

# we summarized the data by year, how has the structure changed? 
str(water_ann_mean)

# plot the water mean water temperature data
# call the dataframe you want to use
water_ann_mean %>%
  # assign the x, y variables, and grouping to color the data
  ggplot(aes(x = year, y = water_temp_C_mean, color = sample_location)) +
  # use geom_point to plot a data point for each year, connect with line
  geom_point() + geom_line() +
  # pick a theme to clean up plot
  theme_bw() +
  # add plot and axis titles
  ggtitle("K'avi Tribe Mean Annual Water Temperature") +
  xlab("Year") +
  ylab("Mean Water Temperature (°C)")

# Do a reasoning check - based on photo of the monitoring sites, why do you think monitoring sites 1 and 5 are colder? 
# temp conversion 5C ~ 41F; 10C ~ 50F



# plot the mean DO data - why do we care about DO? what is it? 
# important for water quality, aquatic life needs DO, but not too much or too little. levels below 5mg/L are low enough to stress out fish 
# Link to EPA description: https://www.epa.gov/national-aquatic-resource-surveys/indicators-dissolved-oxygen#:~:text=Dissolved%20oxygen%20(DO)%20is%20the,of%20a%20pond%20or%20lake.

#! Your Turn: plot the annual average DO here 




####---Finished with part 1---####
# topics covered:
# cleaning data (removed unnecessary columns and rows with repeated header)
# filtering (example used was to take out the rows with text of col headers in them, not to extract desired values)
# summarizing by year
# ggplot - time series and boxplot 



