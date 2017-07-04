# sleep_start calculates when a fly started a period of 5 min of inactivity
# sleep_start slides a window of length 2 down the input vector: when the window 
# is positioned over a `0` followed by a `1`, the index of the `1` minus 1
# is stored in sleep_start_vec. Note that subtracting 1 from the index of the `1` is necessary because 
# five_minute_bouts starts with a row that is equivalent to 0 minutes; this is due to the fact that
# we added a ghost of 1's row to DAM_raw_clean2. The ghost row is required to identify whether a fly was sleeping
# at the very beginning of the experiment (i.e. already sleeping at time = `1` min). The result of this
# ghost row is that any index we identify as the beginning of sleep will be shifted forward in time by 1 min.
# Hence, we need to subtract 1 from any index we find. This leads to the fase impression that we are
# storing the index of the `0` in sleep_start_vec (i.e. `i`); when in fact we are storing the index of
# `1`, which is (`i + 1 - 1`), which is `i`, and hence identical to the index of `0`. It must be clear though
# that the physiological entity we are storing in sleep_start_vec is the `1`, i.e. the minute during which the
# fly started to sleep.
sleep_start <- function(vec){
    
    adjusted_length <- length(vec) - 1
    
    sleep_start_vec <- vector(mode = "numeric")
    
    for(i in 1:adjusted_length){
        
        if(vec[i] == 0 && vec[i + 1] == 1){
            sleep_start_vec <- c(sleep_start_vec, i)
        }
    }
        
    sleep_start_vec
}
