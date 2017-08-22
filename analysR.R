# analysR is a function to analyse data from the DAM system
analysR <- function(DAM_raw, days_in_minutes = 1440){
    
    library(dplyr)
      
    # Source auxilliary functions (need to be in working directory)
    source("sleep_define.R")
    source("sleep_start.R")
    source("sleep_end.R")
    source("light_dark_transitions.R")
    
    # Read in raw data input
    DAM_raw <- read.table(DAM_raw)
    
    # Extract columns 12:44 or 10:42 (based on date parsing)
    if(dim(DAM_raw)[2] == 44){
      
        DAM_raw_clean <- DAM_raw[1:days_in_minutes, 12:44]
    }
    else if(dim(DAM_raw)[2] == 42){
      
        DAM_raw_clean <- DAM_raw[1:days_in_minutes, 10:42]
    }
    
    # Bind an extra row of 1's to first position of DAM_raw_clean; 
    # This extra row is important for downstream analysis, but 
    # does not represent anything physiological.
    DAM_raw_clean2 <- rep.int(1, 33) %>% rbind(DAM_raw_clean)
    
    # Extract first column from DAM_raw_clean2, 
    # which indicates light on/off into a 
    # separate vector (may be needed for reference later on). 
    # Then remove that column from DAM_raw_clean2.
    light_regime <- DAM_raw_clean2[2:dim(DAM_raw_clean2)[1], 1]
    DAM_raw_clean2 <- DAM_raw_clean2[, 2:33]
    
    # Bind an extra column to the left of 
    # DAM_raw_clean2 to indicate the time.
    DAM_raw_clean3 <- 0:days_in_minutes %>% cbind(DAM_raw_clean2)
 
    # Initialise a new data frame with dimensions 
    # of DAM_raw_clean3[, 2:33]. This 
    # object is an analogue-to-binary transformation, 
    # with 1 indicating no movement and 0 indicating movement.
    # NB: loop starts at i == 2 because the first column, 
    # the time indicator, must be kept constant.
    analogue_to_binary <- DAM_raw_clean3
    cols <- ncol(analogue_to_binary)
    for(i in 2:cols){
      
        analogue_to_binary[, i] <- sapply(analogue_to_binary[, i], function(foo){if(foo == 0){foo <- 1} else{foo <- 0}})
    }
    
    # Create new dataframe five_min_bouts, which has 1's 
    # at 'sleep onset' times, i.e. at the beginning
    # of time bouts of 5 min of inactivity, based on analogue_to_binary.
    five_min_bouts <- analogue_to_binary
    for(i in 2:cols){
      
        five_min_bouts[, i] <- sleep_define(five_min_bouts[, i])
    }
    
    # Now slide down every column of five_min_bouts to 
    # find sleep onset and sleep offset.
    # The latter are stored in two separate lists.
    sleep_start_list <- list()
    sleep_end_list <- list()
    for(i in 2:cols){
      
        start_index <- length(sleep_start_list) + 1
        sleep_start_list[[start_index]] <- sleep_start(five_min_bouts[, i])
        
        end_index <- length(sleep_end_list) + 1
        sleep_end_list[[end_index]] <- sleep_end(five_min_bouts[, i])
    }
    
    # Subtract corresponding columns of sleep_end_list 
    # from sleep_start_list, in oder to generate
    # a new list of vectors representing sleep lengths 
    # for each sleep bout for each fly.
    sleep_bout_length <- list()
    for(i in 2:cols){
        
        bout_index <- length(sleep_bout_length) + 1
        sleep_bout_length[[bout_index]] <- sleep_end_list[[bout_index]] - 
          sleep_start_list[[bout_index]] + 1
    }
    
    # Calculate all transitions from light to dark and dark to light
    transitions <- light_dark_transitions(light_regime, days_in_minutes)
    
    output <- list(light_regime = light_regime, transitions = transitions, 
                   DAM_raw = DAM_raw, DAM_raw_clean = DAM_raw_clean, 
                   DAM_raw_clean2 = DAM_raw_clean2, DAM_raw_clean3 = DAM_raw_clean3, 
                   analogue_to_binary = analogue_to_binary, five_min_bouts = five_min_bouts, 
                   sleep_start_list = sleep_start_list, sleep_end_list = sleep_end_list, 
                   sleep_bout_length = sleep_bout_length)
    
    # Return list output
    output
}
