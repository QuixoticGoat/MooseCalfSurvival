################################################################################
# Plot the real (daily survival) and derived (annual survival) estimates from 
# the top known fate model generated from KnownFateModels.R
#
# Author: McCrea Cobb <<mccrea_cobb@fws.gov>>
# Last edited: 5/22/2018
################################################################################


##---- PlotTopModel

# Required packages:
library(ggplot2)
library(RMark)

# Source code:
source("./code/01_import_format.R")
source("./code/02a_known_fate_model.R")


# ------------------------------------------------------------------------------
##----01_real_estimates:

# Create a plot called p:
(p <- ggplot(top_model_real, aes(x = Year, y = estimate)) +
   geom_pointrange(data = top_model.real,
                   aes(x = Year, y = estimate, ymin = lcl, ymax = ucl),
                   size = 1, fill = "white", shape = 22) +
   xlab("Year") + 
   ylab("Daily survival rate"))

# Save the plot:
ggsave("./output/figures/daily_survival_estimates.pdf",
       width = 6, height = 4, units = "in")



#-------------------------------------------------------------------------------
##----derived_estimates:

(p <- ggplot(top_model_derived, aes(x = Year, y = Estimate)) +
  geom_pointrange(data = top_model_derived,
                  aes(x = Year, y = Estimate, ymin = LCL, ymax = UCL),
                  size = 1, fill = "white", shape = 22) +
  xlab("Year") + 
  ylab("Annual survival rate"))

# Save the plot:
ggsave("./output/figures/annual_survival_estimates.pdf",
       width = 6, height = 4, units = "in")
