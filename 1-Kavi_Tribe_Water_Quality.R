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

# there will be two main variables we work with in this section: stream temperature and dissolved oxygen
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

# set working directory- the wd is the folder that your related files will be contained in
  # it's important that each class / project has a specific
  # folder on your computer to maintain organization
setwd("~/Documents/GitHub/K_aviCode/")
# if using github project or working from posit cloud, don't need to run setwd()

########################################################################################
#### start here if you have no experience with any coding ####
# this section will review some R basics 

# what is coding? for starters, we can do basic math -  run these lines and see output in the console 
4*5
12/3+4*5/67+89*10
(2 + 3)/2

# we can save output by assigning it a name using "<-" to make it an object 
# the format for all R objects is: object_name <- value 

x <- 4*5 # notice how output does not show up in console, but now you have an object stored in your environment (top right panel)

# type 'x' into the console and hit enter 
#! Your Turn: add x to 100 and save as a new variable 'y' 


# Vectors, which are a list  
# we can combine multiple objects using c() 
my_vector <- c(x, 52, 54, 61, 63)
print(my_vector)

# we can use functions on vectors 
# the format for functions is: function(object, parameters) 
# the object is what the function is being done on, and parameters can be any extra information that R needs to run the function 
# for example: 
max(my_vector)

#! Your Turn: find the mean() of my_vector 


#! Your Turn: create a second vector called "v2" and include 5 values 



# vectors can also contain characters,  but if they do, the entire list is stored as character 
v3 <- c("January", "Feb", 3, 4, 5)
# we can't run math functions on this type of vector because of the characters


# when we have multiple vectors, each representing a different variable, they can combine to make a dataset. 
# here we are using tibble() to make our dataset. We want the following format: each column is a variable, each row is an observation, and each cell is a single value 
my_tib <- tibble(my_vector, v2)

# sometimes datasests are so large we do not want to print the entire thing in our console. Instead we can preview it with some examples here: 
str(my_tib)
head(my_tib)
summary(my_tib)

# vectors within datasets are referred to with a '$'
# for example, to get the mean of v2 
mean(my_tib$v2)

# if we know there are the same number of values, we can add a column this way
my_tib$v3 <- v3

# datasets can be organized and manipulated in different ways. with tidyverse, we can use a pipe (%>%) which is an operator that takes the dataframe and performs a function on it. Examples are shown below 

# select function: selects variables from dataset and optionally renames
my_tib_sel <- my_tib %>% select(v2, v3)
head(my_tib_sel)

# filter function: filters by row, based on criteria that can be equal to (==), not equal to (!=), greater than (>), greater than or equal to (>=), less than (<), or less than or equal to (<=)
my_tib_filt <- my_tib_sel %>% filter(v3=="January")
head(my_tib_filt)

# mutate function: mutate creates a new variable that can be based on an existing one 
my_tib_mut <- my_tib_filt %>% mutate(v4 = v2*2)
head(my_tib_mut)

# we can condense these lines using the pipe! 
# for example 
my_tib_all <- my_tib %>% 
  select(v2, v3) %>% 
  filter(v3=="January")  %>% 
  mutate(v4 = v2*2)
# compare my_tib_all with my_tib_mut - should be the same because we ran the same functions on them 

#! Your Turn: using select, filter, mutate, or all of the above, create a new dataset from the original my_tib 



# finally, with tidy datasets we can easily plot our data
# we will use the ggplot format, which follows:
## ggplot(dataset) + geom_plottype(aes(x, y))

# for example 
my_tib_all %>% ggplot() + geom_point(aes(x=v2, y=v4))

#! Yout Turn: try using ggplot for the dataset you created above



# next you'll put all this new knowledge to practice with a dataset of daily streamflow water quality for different monitoring sites - this has more points than our practice one, but all the functions are used in the same way! 


# ----------------------------------------------------------------------------------------
#### start here if you already have some experience with R or another programming language ####
# ----------------------------------------------------------------------------------------


# before we dive into the data cleaning part, load this data and let's see a plot 
water_filt <- readr::read_csv("K'avi Tribe Water Quality Dataset_clean.csv")

# run this line for plot
water_filt %>%
  ggplot(aes(x = date, y = water_temp_C, color = sample_location)) +
  geom_line() + geom_point() +
  theme_minimal()

# in order to get to this point where we can explore visually, we first have to clean our original data set 


# starting at the very beginning! 
# read in CSV file that we want to work with - should be located in your working director
water <- read.csv("K_avi Tribe Water Quality Dataset.csv")
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
write.csv(water_num, file = "K'avi Tribe Water Quality Dataset_clean.csv")


####---Analyze and visualize data---####

# if you need to re-load your clean dataset, do that here
water_num <- readr::read_csv("K'avi Tribe Water Quality Dataset_clean.csv")

# plot the data to look and see if we have any outliers or misentered data we might be concerned about
water_num %>%
  ggplot(aes(x = date, y = water_temp_C, color = sample_location)) +
  geom_line() 

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



