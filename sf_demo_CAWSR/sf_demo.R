library(tidyverse)
library(sf)
library(mapview)
library(parzer)
library(lubridate)
library(terra)
# about parzer: https://semba-blog.netlify.app/02/25/2020/geographical-coordinates-conversion-made-easy-with-parzer-package-in-r/

# load data 
water_example <- readr::read_csv("../AIHEC2024/tidy_water_quality_dataset.csv") %>% 
  rename(latitude = longitude,
         longitude = latitude)

# plot lat long - is this a map?
ggplot(water_example, aes(x=longitude, y=latitude)) + 
  geom_point() +
  geom_text(aes(label=sample_location), nudge_y = 0.1)

# because lat / lon is stored as character, need to change to crs, and make the data a 'spatial feature' with the sf package 

# convert lon / lat DMS format to numeric 
water_example$latitude <- parse_lat(water_example$latitude)
water_example$longitude <- parse_lon(water_example$longitude)

water_filt <- water_example %>% filter(!is.na("latitude") & !is.na("longitude"))

# here we convert our data frame into a 'simple feature' which is the R package 'sf' way of handling spatial data that is a vector (points, lines, polygons)
water_sf <- st_as_sf(x=water_filt,
                     coords = c("longitude","latitude"),
                     crs = "+init=epsg:4326")
head(water_sf)

# plot 
ggplot(water_sf) + geom_sf()
# plot with map - something is off with CRS 
mapview(water_sf)
# plot with variables 
ggplot(water_sf) + geom_sf(aes(col=water_temp_C), size=5) + scale_color_gradient( low="blue", high="red")

# can also treat treat sf object as a regular data frame and aggregate - this example is filtering to summer months and taking the average temperature of each site 
summer_avg = water_sf %>% 
  mutate(month = month(date)) %>% 
  dplyr::filter(month>6 & month<10) %>% 
  group_by(sample_location) %>% 
  summarize(summer_temp_C = mean(water_temp_C)) 

ggplot(summer_avg) + geom_sf(aes(col=summer_temp_C), size=5) + scale_color_gradient( low="blue", high="red")


# the above example uses points 
# connected points create lines and polygons 
# the next example is from the California Wild, Scenic, and Recreational Rivers dataset (https://data.cnra.ca.gov/dataset/wild-and-scenic-rivers-california-state-designations-only-2020)
# most shapefiles include several different files, so loading them requires the folder where all the files are contained, and this folder should have the same name as the beginning of the file 


# the function st_read will read in the data as a 'simple feature' 
ca_lines <- st_read(paste("WildAndScenicRivers_CAStateDesignationsOnly_Lines/", sep=""))

ggplot(ca_lines) + geom_sf()

mapview(ca_lines)

# the other folder includes point features that identify the endpoints of designated WSR 

# another common format of spatial data is a raster, which shows data as an area 
# 
# library(rgdal) my computer is having issues but rgdal is the package for raster that can handle many different filetypes. terra is another good package 

# load in dem and look at properties (dem = digital elevation model)
dem <- terra::rast("n40_w125_1arc_v3.tif")
dem
# plot 
plot(dem)
hist(dem)
contour(dem)




