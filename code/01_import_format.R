

################################################################################
# Import and format mark/resight data for moose calf survival estimation at    #
# Alaska Peninsula Becharof using known fate models                            #
#                                                                              #
# Author: McCrea Cobb <mccrea_cobb@fws.gov>                                    #
# Created: 5/22/2018                                                           #
# Last edited: 6/17/2019                                                       #
################################################################################
 
# Required packages:
library(RMark)
library(readxl)
library(tidyverse)

# Load the excel tab with the data:
dat <- read_excel("./data/raw_data/moose_calf_day_WATTS.xlsx", sheet="R")

# Rename BirthDateZScoree to DayBorn for MARK:
dat <- dat %>%
  rename(DayBorn = BirthDateZscore)

# Write the raw data to a tab delimited
write.table(dat, file="./data/derived_data/dat.txt", sep="\t", row.names = FALSE)

# Load known-fate data:
dat <- import.chdata("./data/derived_data/dat.txt", 
                     header = TRUE,
                     field.types = c("f", "f", "n", "s"))

# Process the dataset for MARK:
dat.p <- process.data(dat, 
                      model = "Known", 
                      groups = c("Twin", "Year"))  # Process data

# Make the design matrix for MARK:
dat.ddl <- make.design.data(dat.p)  # Create default design data
