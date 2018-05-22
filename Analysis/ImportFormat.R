################################################################################
# Import and format mark/resight data for moose calf survival estimation at 
# Alaska Peninsula Becharof using known fate models
#
# Author: McCrea Cobb <<mccrea_cobb@fws.gov>>
# Last edited: 5/22/2018
################################################################################


##---- ImportFormat.R

library(RMark)

dat <- import.chdata("./InputData/MooseCalfData.txt", header = TRUE,
                     field.types = c("f", "f", "n"))

dat.p <- process.data(dat, model = "Known", 
                      groups = c("Twin", "Year"))  # Process data

dat.ddl <- make.design.data(dat.p)  # Create default design data
