# K_aviCode

This repository contains R files for the AIHEC 2024 data science workshop, adopted from the Geoscience Alliance 2022 data science workshop.. 

## Background Info 

The EPA is the single biggest funder of tribal water quality programs and that tribes often hire consultants because they do not have staff trained in data analysis.  As a result, funds that should stay on the Reservation often flow outward and at greatly inflated costs. This workshop us based on a course at Salish-Kootenai College (SKC), developed by Georgia Smies, and aims to bridge the gap to train students in data analysis. Georgia wrote the background included below. 

**EPA Reporting Requirements**

The EPA has been coordinating with tribal programs since 1973 to strengthen environmental protection of tribal water, air, and land.  Most tribes developed their natural resource programs by focusing upon water quality programs first.  As a result, many tribes that I[Georgia] work with have at least 30 years of long-term monitoring data of tribal surface waters.  Datasets include chemical, physical, and biological parameters of water quality.

The EPA has strict protocols that dictate how samples are collected, analyzed, and assessed.  These protocols are summarized in a Quality Assurance Action Plan or QAPP that must be approved before funding is provided for annual monitoring efforts.  The QAPP also specifies how data is to be stored, validated, and provides a reporting schedule that Tribes must follow. At a minimum, Tribes must submit annual assessment reports that describe the statistical trends of all monitored parameters.  For instance, for each long-term monitoring location, the discharge, water temperature, dissolved oxygen, pH, specific conductance, turbidity, total suspended solids etc. must be analyzed to determine the minimum, mean (or median), and maximum values throughout the annual monitoring period.  Chemical and biological data are similarly described.  Typically, programs have small annual sample sizes (n<9) so more complex analysis is not possible.  The EPA reviews the annual report as part of the funding criteria and makes suggestions to the Tribe as needed.

**Current problems with data analysis and reporting**

Today, most of the Tribes I[Georgia] work with have not analyzed their long-term datasets for trends because they lack the analysis capacity.  This is a serious limitation.  The Tribes that have hired me to look at their data as a consultant are often not aware of the environmental changes occurring within their streams.  Often, water quality program employees have frequent staff turnovers and long-term familiarity with streams and rivers is not “baked” into the program.  Additionally, even the programs like the Northern Cheyenne, who do have staff who have been in the same position for greater 20 years lack the ability to communicate what they intrinsically understand because they lack the data analysis training.  For instance, I did work for the CSKT and evaluated 20 years of water quality data on valley bottom streams.  I found that water temperature had increased by an average 6 degrees Fahrenheit since 2000.  I then coupled my finding with tribal fisheries data that indicated changes in the local fishery.  This provided powerful information for the tribes to use for management decisions.

Further, tribes do not have a tool(s) that allows them to evaluate their surface waters based upon what is important to them culturally and spiritually.  *The EPA asks only for quantitative analysis of measured parameters. Sites that have “good” water quality based upon these parameters are given priority from a management perspective.*  This analysis does not address what many consider to be the 5 pillars of TEK (native language preservation, traditional food gathering, traditional medicine, cultural practices, spiritual practices, and some would add food sovereignty).  As a result, Tribes do not have a means to communicate to the EPA what is important to them and sites that are important culturally may not be given the same protection as those that are assessed using only quantitative assessment of physical variables.  In short, western scientific approaches fail to embrace the native world view.

## About the data 

This activity is based on a fictional tribe called the K'avi (derived from a powerful medicinal source that gave them energy and cleared their thinking….what you and I call coffee), in order to not single out any indigenous groups. The location is also fictional, but representative of a place with ample surface water, a high elevation stream network fed by glaciers with wetlands and a lake. The photo of the 'reservation' is included below, and is in a remote portion of Banff National Park. The 10 year database is similar to data collected from tribes in Wester Montana. To incorporate the TEK element, a layer of sites adjacent to or near the long-term water quality monitoring sites that were important to the K’avi were added.  Specifically, there is a language camp, lake and river fishing sites, spiritual ceremony site, hunting area, and a site for gathering medicinal foods. 

![Photo of fictional K'avi reservation. Water Quality monitoring sites are marked in blue, and cultural sites are marked in green.](K_aviTribeMap.png)

The water quality variables include: water temperature, dissolved oxygen, specific conductance, and discharge, at a monthly timestep. Water temperature can be meaningful for protecting aquatic communities while maintaining socio-economic benefits ([Ouellet-Proulx et al. 2017](https://www.mdpi.com/2073-4441/9/7/457)). Common water temperatures in lakes and streams range between 4 and 35 °C. Dissolved oxygen (DO) is the concentration of oxygen dissolved in water. Common DO concentrations range between 0 and 12 mg L-1 and DO concentrations less than 2 mg L-1 are considered hypoxic, although levels below 5mg/L are low enough to stress out fish ([EPA](https://www.epa.gov/national-aquatic-resource-surveys/indicators-dissolved-oxygen#:~:text=Dissolved%20oxygen%20(DO)%20is%20the,of%20a%20pond%20or%20lake.)).

## About the code 

The goal for this workshop is to get hands-on experience with data management and visualization in R, and to explore the relationship between Western scientific priorities and Indigenous community values. 
The main focus is on learning [`tidyverse`]([url](https://www.tidyverse.org/)https://www.tidyverse.org/) and [`ggplot`]([url](https://ggplot2.tidyverse.org/)https://ggplot2.tidyverse.org/). It is organized into 5 parts, with each R file numbered in order. 

In the first file, we cover R basics, data types and type conversion, data cleaning with `dplyr` functions, and plotting with `ggplot`. 

## Getting started with R 

1. Download and install R and RStudio
   - Go to the [R website](https://www.r-project.org). Then, under the Getting Started section, click on the link that says download R.
   - R software is downloaded from a CRAN (Comprehensive R Archive Network) mirror. For the fastest download, scroll to your country, then select the CRAN link that is closest to you, geographically. For example, in Humboldt Co, California, USA the closest CRAN would be https://ftp.osuosl.org/pub/cran/, hosted by Oregon State University in Corvallis, Oregon, USA.
   - From your local CRAN, select the download link (“Download R for”) that matches your computer operating system (Windows, Mac).
      - Windows: Click the link that says install R for the first time. Then, within the gray box, click the link that says Download R x.y.z for Windows, where x, y, and z are different numbers that designate the current version of R. This should start the file download. Proceed normally as with any new PC program, following the automated download instructions.
      - Mac: Under the section labeled “Files”, click on the first blue link that ends in .pkg. This is the most recent R binary file. This should start the file download. Proceed normally as with any new Mac application, following the automated download instructions.

2. Go to the [RStudio website](https://www.rstudio.com/products/rstudio/download). Scroll to the bottom of the page.
   - Under Installers for Supported Platforms, select the link that matches your computer operating system (Windows, Mac) to download and install RStudio.
      - Windows: Double-click the .exe file and proceed normally as with any new PC program, following the automated install instructions.
      - Mac: Double-click the .dmg file; this will open a new window in your desktop. Drag the RStudio icon to the Applications folder to install it in your computer.
    
3. Install packages used in this workshop. Within R, researchers have developed “packages” that group together code and functions to allow you to easily perform different types of computing tasks. You’ll need to use multiple packages during the module activities, and it will be easiest to go ahead and install all of them ahead of time.
   - Now that R and RStudio are installed, open RStudio. The default window on the left of the screen is called the Console, and you can write commands in this window. The two windows on the right include tabs that you can view to see the history of code you’ve already run and your workspace, plots of figures you’ve made with your code, packages you’ve installed, and the files you have open in your working directory.
   - To install the packages, copy and paste the following lines of code to the right of the > in the Console, then press Enter. Note: You need to be connected to the internet to complete the package installation.
  
     ```
     install.packages("tidyverse")
     install.packages("janitor")
     install.packages("lubridate")
     ```
     As you’re installing the packages, you might see a lot of red output messages. However, you can check that they downloaded successfully by then running the following scripts to load the packages:
     ```
     library(tidyverse)
     library(janitor)
     library(lubridate)
     ```

     To check if the packages have installed correctly, navigate over to the “Packages” tab in the bottom right window of RStudio and see if there is a check box next to tidyverse, janitor, and lubridate. 

4. Download the files from this repo, make sure that you have the following:
   - K_avi Tribe Water Quality Dataset.csv
   - 1-Kavi_Tribe_Water_Qualiy.R
   - 2-Visualizing_TEK.R  

You are ready to get started with the first R activity: 1-Kavi_Tribe_Water_Quality.R 

## Acknowledgements 

This activity was first created by Georgia Smies at SKC, and developed by Helena S. Kleiner. It was later modified by Cazimir Kowalski. The text for setting up R studio was adopted from the [MacrosystemsEDDIE Teaching Materials](https://macrosystemseddie.github.io/module1) in 'R You Ready for EDDIE? Module 1'. This work is part of an ongoing project to develop Indigenous data science educational tools with the [Ecological Forecasting Initiative](https://ecoforecast.org/).

For presentation at the AIHEC/NFEWS 2024 meeting, this work is supported by funding from the following: the Computer Science Department, University of Minnesota (with support from NSF award 1901099),  the Native Food, Energy, and Water Security INCLUDES Alliance (NSF award 2120035); the Environmental Change Initiative, University of Notre Dame; the Alfred P. Sloan Foundation and the Geoscience Alliance (NSF award 2039341). 
     



