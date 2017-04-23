# analyseR.R is a function to analyse data from the DAM system for sleep in Drosophila.
analysR <- function(DAM_raw, days_in_minutes = 1440, textual_file_name = NULL){
    
    # Source auxilliary functions (need to be in working directory)
    source("sleep_define.R")
    source("sleep_start.R")
    source("sleep_end.R")
    source("light_dark_transitions.R")
    
    # Read in raw data input
    DAM_raw <- read.table(DAM_raw)
    
    # Extract columns 12:44 for downstream analysis
    DAM_raw_clean <- DAM_raw[1:days_in_minutes, 12:44]
    
    # Bind an extra row of 1's to first position of DAM_raw_clean. This extra row
    # is important for downstream analysis, but does not represent anything
    # physiological = ghost row. 
    ghost_row <- rep.int(1, 33)
    DAM_raw_clean2 <- rbind(ghost_row, DAM_raw_clean)
    
    # Extact first column from DAM_raw_clean2, which indicates light on/off into a 
    # separate vector (may be needed for reference later on). Then remove that column
    # from DAM_raw_clean2.
    light_regime <- DAM_raw_clean2[2:dim(DAM_raw_clean2)[1], 1]
    DAM_raw_clean2 <- DAM_raw_clean2[, 2:33]
    
    # Bind an extra column to the left of DAM_raw_clean2 to indicate the time.
    time_column <- 0:days_in_minutes
    DAM_raw_clean3 <- cbind(time_column, DAM_raw_clean2)
 
    # Initialise a new data frame with dimensions of DAM_raw_clean3[, 2:33]. This 
    # object is an analogue-to-binary transformation, with 1 indicating no movement and 0
    # indicating movement.
    # NB: loop starts at i == 2 because the first column, the time indicator, must be kept constant.
    # In analogue_to_binary, the 1's represent inactivity bouts, the 0's activity bouts
    analogue_to_binary <- DAM_raw_clean3
    cols <- ncol(analogue_to_binary)
    for(i in 2:cols){
        analogue_to_binary[, i] <- sapply(analogue_to_binary[, i], function(foo){if(foo == 0){foo <- 1} else{foo <- 0}})
    }
    
    # Create new dataframe five_min_bouts, which has 1's at 'sleep onset' times, i.e. at the beginning
    # of time bouts of 5 min of inactivity, based on analogue_to_binary.
    five_min_bouts <- analogue_to_binary
    for(i in 2:cols){
        five_min_bouts[, i] <- sleep_define(five_min_bouts[, i])
    }
    
    # Now we slide down every column of five_min_bouts to find sleep onset and sleep offset.
    # The latter are stored in two separate lists.
    sleep_start_list <- list()
    sleep_end_list <- list()
    for(i in 2:cols){
        sleep_start_column <- sleep_start(five_min_bouts[, i])
        start_index <- length(sleep_start_list) + 1
        sleep_start_list[[start_index]] <- sleep_start_column
        
        sleep_end_column <- sleep_end(five_min_bouts[, i])
        end_index <- length(sleep_end_list) + 1
        sleep_end_list[[end_index]] <- sleep_end_column
    }
    
    # Subtract corresponding columns from sleep_end_list from sleep_start_list, in oder to generate
    # a new list of vectors representing sleep lengths for each sleep bout for each fly.
    sleep_bout_length <- list()
    for(i in 2:cols){
        bout_index <- length(sleep_bout_length) + 1
        sleep_bout_length[[bout_index]] <- sleep_end_list[[bout_index]] - sleep_start_list[[bout_index]] + 1
    }
    
    # Calculate all transitions from light to dark and dark to light
    transitions <- light_dark_transitions(light_regime, days_in_minutes)
    
    output <- list(light_regime = light_regime, transitions = transitions, DAM_raw = DAM_raw, DAM_raw_clean = DAM_raw_clean, 
         DAM_raw_clean2 = DAM_raw_clean2, DAM_raw_clean3 = DAM_raw_clean3, 
         analogue_to_binary = analogue_to_binary, five_min_bouts = five_min_bouts, 
         sleep_start_list = sleep_start_list, sleep_end_list = sleep_end_list, 
         sleep_bout_length = sleep_bout_length)
    
    # If textual file name is specified, deparse output, so it will create a textual 
    # file in working directory that can later be sourced without loss of information. 
    if(!is.null(textual_file_name)){
        
        lr <- output$light_regime
        dr <- output$DAM_raw
        drc <- output$DAM_raw_clean
        drc2 <- output$DAM_raw_clean2
        drc3 <- output$DAM_raw_clean3
        a2b <- output$analogue_to_binary
        fmb <- output$five_min_bouts
        ssl <- output$sleep_start_list
        sel <- output$sleep_end_list
        sbl <- output$sleep_bout_length
        trsns <- output$transitions
        dump(c("lr", "trsns", "dr", "drc", "drc2", "drc3", "a2b", 
               "fmb", "ssl", "sel", "sbl" ), file = sprintf("%s.R", textual_file_name))
    }
    
    
    # Return list output
    output
    
}
