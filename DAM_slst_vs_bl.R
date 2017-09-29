DAM_slst_vs_bl <- function(analysR_output, xlsx_file_name, channels = 1:32){
    
    # NB: the xlsx package is built in JAVA, 
    # so you need JAVA installed to run this script.
    library("xlsx")
    library("plyr")
    
    # Create data frames for each fly 
    # of sleep start times vs bout lengths.
    # Store these data frames in a list.
    sleepstart_vs_boutlength_dfs <- list()
    i <- 1
    for(channel in channels){
        
        channel_length <- length(analysR_output$sleep_start_list[[channel]])
        
        sleepstart_vs_boutlength_dfs[[i]] <- data.frame(analysR_output$sleep_start_list[[channel]],
                                                        analysR_output$sleep_bout_length[[channel]],
                                                        rep(channel, channel_length))
        names(sleepstart_vs_boutlength_dfs[[i]]) <- c("sleep_start", "bout_length", "channel")
        
        i <- i + 1
    }
    
    # Add 1's or 0's as a third column to each 
    # dataframe in sleepstart_vs_boutlength_dfs.
    # This way, you know which sleep episode 
    # (and corresponding length) happened during
    # the night and which ones during the day.
    light_regime <- analysR_output$light_regime
    i <- 1
    for(df in sleepstart_vs_boutlength_dfs){
        
        light_regime_current <- vector(mode = "numeric")
        
        j <- 1
        for(bout in df$sleep_start){
            
            light_regime_current[j] <- light_regime[bout]
            j <- j + 1
        }
        
        sleepstart_vs_boutlength_dfs[[i]] <- cbind(sleepstart_vs_boutlength_dfs[[i]], 
                                                   light_regime = light_regime_current)
        i <- i + 1
    }
    
    # Bind all data frames into one big data frame
    single_df <- ldply(sleepstart_vs_boutlength_dfs, data.frame)
    
    # Write that data frame into xlsx file
    write.xlsx(single_df, xlsx_file_name)
}
