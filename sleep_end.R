# sleep_end calculates the end of each sleep episode of a fly. In analysR, this function
# is called on each column of five_min_bouts, which by itself represents each individual
# channel used in the experiment. It first defines adjusted_length, which is the length of
# the input vector minus `1`. This is necessary because sleep_end uses a sliding window
# of length `2` to slide down the input vector, and it will hence reach its end at position
# `(n - 1)`. Next, sleep_end_vec is defined as an empty numeric vector, which will be filled
# with all the minutes during which a fly stopped sleeping. To find these time points,
# a sliding window of length two slides down the input vector until it encounters
# a transition from `1` to `0`. It will then store the index of the `0` in sleep_end_vec.
# Note that because we added a ghost_row (consisting of `1`'s) to DAM_raw_clean2 in
# analysR, the row index of each element in five_min_bouts is shifted downwards by `1`.
# Hence, to store the time point of the second element of the sliding window, i.e. the `0`,
# we actually have to store the index of the `1`, which is synonymous with the index
# of the `0` minus `1`.
sleep_end <- function(vec){
    
    adjusted_length <- length(vec) - 1
    
    sleep_end_vec <- vector(mode = "numeric")
    
    for(i in 1:adjusted_length){
       
        if(vec[i] == 1 && vec[i + 1] == 0){
            
            sleep_end_vec <- c(sleep_end_vec, (i + 3))
        }
    }
    
    sleep_end_vec
}