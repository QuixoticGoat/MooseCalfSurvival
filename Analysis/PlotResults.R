################################################################################
# Plot the real (daily survival) and derived (annual survival) estimates from 
# the top known fate model generated from KnownFateModels.R
#
# Author: McCrea Cobb <<mccrea_cobb@fws.gov>>
# Last edited: 5/22/2018
################################################################################


##---- PlotTopModel

library(ggplot2)
library(RMark)
source("./Analysis/ImportFormat.R"); source("./Analysis/KnownFateModels.R")

# ------------------------------------------------------------------------------
# 1. Real estimates:

# Create a plot called p:
p <- ggplot(TopModel.real, aes(x = Year, y = estimate))
p <- p + geom_pointrange(data = TopModel.real,
                         aes(x = Year, y = estimate, ymin = lcl, ymax = ucl),
                         size = 1, fill = "white", shape = 22) +
  xlab("Year") + 
  ylab("Daily Survival Rate")

# Look at the plot:
p

# Save the plot:
ggsave("./Figures/DailySurvivalEstimates.pdf",
       width = 6, height = 4, units = "in")



#-------------------------------------------------------------------------------
# Derived estimates:
library(ggplot2)
p <- ggplot(TopModel.derived, aes(x = Year, y = Estimate))
p <- p + geom_pointrange(data = TopModel.derived,
                         aes(x = Year, y = Estimate, ymin = LCL, ymax = UCL),
                         size = 1, fill = "white", shape = 22) +
  xlab("Year") + 
  ylab("Annual Survival Rate")

# Look at the plot:
p

# Save the plot:
ggsave("./Figures/AnnualSurvivalEstimates.pdf",
       width = 6, height = 4, units = "in")
