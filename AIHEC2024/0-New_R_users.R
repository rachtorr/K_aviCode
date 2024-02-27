# load in package 
#may need to install first 
install.packages("tidyverse")
library(tidyverse)

# this section will review some R basics and syntax

# what is coding? for starters, we can do basic math -  run these lines and see output in the console (the panel in bottom left with '>' at each line)
4*5
12/3+4*5/67+89*10

# we can save output by assigning it a name using "<-" to make it an object 
# the format for all R objects is: object_name <- value 
x <- 4*5 # notice how output does not show up in console, but now you have an object stored in your environment (top right panel)

# type 'x' into the console and hit enter 

#! Your Turn: add x to 100 and save as a new variable 'y' 


# data types:
# x and y are saved as numeric, which means we can use them in equations and mathermatical functions
# other types of data include characters and logical, which we go through below

# Vectors are like a list with one type of data 
# we can combine multiple objects using c() 
my_vector <- c(x, 32, 47, 61, 63)
# see my_vector in the console 
print(my_vector)
# note the information in our Environment about my_vector: num means the data is numeric, [1:5] is because it is a list from 1 to 5. 
# we can extract single values from the vector using brackets and the order 
my_vector[1]

# we can use functions on vectors 
# the format for functions is: function(object, parameters) 
# the object is what the function is being done on, and parameters can be any extra information that R needs to run the function 
# for example: 
max(my_vector)

#! Your Turn: find the mean() of my_vector 


# now create a new vector 
#! Your Turn: create a second vector called "v2" and include 5 numeric values 



# vectors can also contain characters,  but if they do, the entire list is stored as character 
v3 <- c("January", "Feb", 3, 4, 5)
# we can't run math functions on this type of vector because of the characters


# when we have multiple vectors, each representing a different variable, they can combine to make a dataset. 
# here we are using tibble() to make our dataset. We want the following format: 
# each column is a variable, each row is an observation, and each cell is a single value 
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



# next you'll put all this new knowledge to practice with a dataset of daily stream water quality for different monitoring sites - this has more points than our practice one, but all the functions are used in the same way! We will learn more why the functions used here (select, filter, mutate) are useful 
