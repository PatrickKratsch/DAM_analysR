sleep_define <- function(vec){
    
    len <- length(vec)
    adjusted_len <- len - 4
    
    for(i in 2:adjusted_len){
        
        window_sum <- sum(vec[i:(i + 4)])
        
        if(window_sum == 5){
            
            vec[i] <- 1
        }
        else{
            
            vec[i] <- 0
        }
    }
    
    # Add an extra condition for the last 4
    # bouts in vec (analogue_to_binary). These
    # cannot be one, and so must all be set to zero.
    
    vec[(len - 3):len] <- 0
    
    vec
}
