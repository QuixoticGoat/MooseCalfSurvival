
################################################################################
# Bayesian known-fate analysis of moose calf survival, APB Refuges             #
#                                                                              #
# Author: McCrea Cobb <mccrea_cobb@fws.gov>                                    #
# Created: 5/22/2018                                                           #
# Last edited: 6/17/2019                                                       #
################################################################################


### Simulated data

# Function arguments:
# R - Number of individuals radio-marked per year
# J - Number of months per year
# K - Number of winters of the study
R <- 25
J <- 6
K <- 10

ind <- 1:R                    
month<-1:J
year <- 1:K                     
z <- array(dim = c(R,J, K))    # Known-Fate CH

#Set Detection and Survival Parameters
p <- 1
phi <- rnorm(1, 0.96, .0025)

# We assume monitoring of individuals was perfect, therefore the latent state is observable. 
# All individuals enter the first month
z[,1,] <- 1
# Individuals then must survive to later months
for(i in 1:R){                  # Loop over sites
  for(j in 2:J){                # Loop over months
    for(k in 1:K){      # Loop over years
      z[i,j,k] <- rbinom(1,z[i,j-1,k],phi)
    }
  }
}
# Encounter history is renamed w, and is ready to be estimated
w<-z


#-------------------------------------------------------------------------------
## Jags file
sink("./output/raw_analysis/jags_model.txt")
cat("
    model {
    
    # Survival Model
    for(j in 1:(n.month-1)){                                         
      for(t in 1:nyear){
        mean.phi.w[j,t] ~ dunif(-5,5)
      } #t
    } #j

    for(i in 1:n.ind){                  # Loop individuals (25)
      for(t in 1:nyear){                # Loop years (10) 
        # mu(i,1,t) <- 1
        # w[i,1,t] ~ dbern(mu[i,1,t])
        for (j in 2:n.month){           # Loop occasions (6 months)
          logit(phi.w[i,j-1,t])<-mean.phi.w[j-1,t]
          mu[i,j,t]<-phi.w[i,j-1,t]*w[i,j-1,t] 
          w[i,j,t] ~ dbern(mu[i,j,t])
        } #j
      } #t
    } #i

    # Derived parameters
    for(t in 1:nyear){ 
      for(j in 1:(n.month-1)){    
        logit(monthly.winter.phi[j,t])<-mean.phi.w[j,t]
      }    
      over.winter.phi[t]<-prod(monthly.winter.phi[,t])
    } #t
    }

    ",fill = TRUE)
sink()


#-------------------------------------------------------------------------------
## Model specs

# Data
data.ws <- list(w=w, n.ind=dim(w)[1], n.month=dim(w) [2], nyear=dim(w)[3])

# Saved parameters
p <- c( "monthly.winter.phi", "over.winter.phi")

# Model specs:
nc=1; na=5000; ni=5000; nb=1000; nt=3 

# Model
mod <- jagsUI::jags(data.ws, inits=NULL, parameters.to.save = p, n.chains = nc,
                    n.adapt = na, n.iter = ni, n.burnin = nb, n.thin = nt,
                    model.file="./output/raw_analysis/jags_model.txt")
mod