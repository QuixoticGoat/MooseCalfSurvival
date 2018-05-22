################################################################################
# Estimate survival rates of moose calves at Alaska Peninsula Becharof Refuge 
# using known fate analysis
#
# Author: McCrea Cobb <<mccrea_cobb@fws.gov>>
# Last edited: 5/22/2018
################################################################################

##---- RunModel

library(RMark)
source(file = "./Analysis/ImportFormat.R")

## Function to run known-fate model set:
run.moose = function() {
  
  # Process data:
  dat.p <- process.data(dat, model = "Known", 
                        groups = c("Twin", "Year"))  
  
  # Create default design data:
  dat.ddl <- make.design.data(dat.p)  
  
  # List of models:
  S.dot = list(formula = ~1)
  S.year = list(formula = ~Year)
  S.twin = list(formula = ~Twin)
  S.dayborn = list(formula = ~DayBorn)
  # year-specific intercepts, common slope
  S.year.dayborn = list(formula = ~Year + DayBorn)
  # One intercept, year-specific slopes
  S.dayborn.by.year = list(formula = ~Year:DayBorn)
  # Year-specific intercepts and slopes
  S.dayborn.x.year = list(formula = ~Year * DayBorn)
  # Twin-specific intercepts, common slope
  S.twin.dayborn = list(formula = ~Twin + DayBorn)
  # One intercept, Twin-specific slopes
  S.dayborn.by.twin = list(formula = ~Twin:DayBorn)
  # Twin-specific intercepts and slopes
  S.dayborn.x.twin = list(formula = ~Twin * DayBorn)
  # Year-specific intercepts, common slope
  S.year.twin = list(formula = ~Year + Twin)
  # One intercept, year-specific slopes
  S.twin.by.year = list(formula = ~Year:Twin)
  # Year-specific intercepts and slopes
  S.twin.x.year = list(formula = ~Year * Twin)
  
  # Run all models:
  model.list = create.model.list("Known")
  moose.results = mark.wrapper(model.list, 
                               data = dat.p, 
                               ddl = dat.ddl,
                               output = FALSE,
                               invisible = TRUE,
                               use.initial = TRUE,
                               filename = "./OutputData/ModelSet")
  
  # Return the model table and list of models:
  return(moose.results)
}

# Run the candidate model set:
ModelSet <- run.moose()

# Look at the model selection table
ModelSet

# Output from the top model:
TopModel <- mark(data = dat.p, 
                 ddl = dat.ddl, 
                 model.parameters = list(S = list(formula = ~Year)), 
                 filename = "./OutputData/TopModel")

# Look at the results:
TopModel
TopModel$results$beta  # Estimates (beta-hats)

# Model average estimate of survival:
mavg <- model.average(ModelSet)


# Compute the real estimates (daily survival) from the top model:
TopModel.real <- compute.real(model = TopModel, design = TopModel$design.matrix, data = dat)
TopModel.real$fixed <- NULL  # remove "fixed" column; dunno what that is?
TopModel.real$Year <- as.factor(c(2011:2016))  # Add column for years
TopModel.real <- TopModel.real[, c(5, 1, 2, 3, 4)]  # reorder the columns
TopModel.real  # Take a look

TopModel.derived <- data.frame(TopModel$results$derived)  # Save derived values to a df
TopModel.derived <- TopModel.derived[c(1, 3, 5, 7, 9, 11),]  # remove duplicate columns
TopModel.derived$Year <- factor(2011:2016)  # Add year column
TopModel.derived <- TopModel.derived[, c(5, 1, 2, 3, 4)]  # reorder the columns
names(TopModel.derived) <- c("Year", "Estimate", "SE", "LCL", "UCL")  #rename columns
row.names(TopModel.derived) <- NULL  # Remove row numbers
