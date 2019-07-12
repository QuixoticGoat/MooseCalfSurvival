################################################################################
# Estimate survival rates of moose calves at Alaska Peninsula Becharof Refuge  #
# using known fate analysis                                                    #
#                                                                              #
# Author: McCrea Cobb <mccrea_cobb@fws.gov>                                    #
# Created: 5/22/2018                                                           #
# Last edited: 6/17/2019                                                       #
################################################################################

# Required packages:
library(RMark)

# Source code:
source(file = "./code/01_import_format.R")


## Function to run known-fate model set:
run.moose <- function() {
  
  ## List of models:
  
  # Null model
  S.dot = list(formula = ~1)
  # Vary by year
  S.year = list(formula = ~Year)
  # Vary by Twin
  S.twin = list(formula = ~Twin)
  # Vary by day born
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
  moose_mark = mark.wrapper(model.list, 
                            data = dat.p, 
                            ddl = dat.ddl,
                            output = TRUE,
                            invisible = FALSE,
                            use.initial = FALSE,
                            filename = "./output/raw_analysis/model_set")
  
  # Return the model table and list of models:
  return(moose_mark)
}

# Run the candidate model set:
model_set <- run.moose()

# Look at the model selection table
model_set

# Output from the top model:
top_model <- mark(data = dat.p, 
                 ddl = dat.ddl, 
                 model.parameters = list(S = list(formula = ~Year)), 
                 filename = "./output/raw_analysis/top_model")

# Look at the results:
top_model
top_model$results$beta  # Estimates (beta-hats)

# Model average estimate of survival:
mavg <- model.average(model_set)


# Compute the real estimates (daily survival) from the top model:
top_model_real <- compute.real(model = top_model, design = top_model$design.matrix, data = dat)
top_model_real$fixed <- NULL  # remove "fixed" column; dunno what that is?
top_model_real$Year <- as.factor(c(2011:2016))  # Add column for years
top_model_real <- top_model.real[, c(5, 1, 2, 3, 4)]  # reorder the columns
top_model_real  # Take a look

top_model_derived <- data.frame(top_model$results$derived)  # Save derived values to a df
top_model_derived <- top_model_derived[c(1, 3, 5, 7, 9, 11),]  # remove duplicate columns
top_model_derived$Year <- factor(2011:2016)  # Add year column
top_model_derived <- top_model_derived[, c(5, 1, 2, 3, 4)]  # reorder the columns
names(top_model_derived) <- c("Year", "Estimate", "SE", "LCL", "UCL")  #rename columns
row.names(top_model_derived) <- NULL  # Remove row numbers
top_model_derived

# Save it:
results <- list(model_set, 
                top_model,
                top_model_real,
                top_model_derived)

save(results, file="output/raw_analysis/known_fate_results.Rdata")

