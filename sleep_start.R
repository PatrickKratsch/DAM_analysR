# sleep_start calculates when a fly started sleeping (i.e. not moving for at least five min).
# In analysR, this function is called on each column of five_min_bouts. In other words,
# sleep_start takes one column at a time of five_min_bouts as an input argument. It first
# defines the adjusted length, which needs to be done because sleep_start slides a window
# of length 2 down the input vector (i.e. one column of five_min_bouts), and it will hence reach the 
# end of this vector once the first element of this window is at position (`n - 1``). Next, this
# function initialises an empty vector sleep_start_vec, which will store all the times on minutes
# when a particular fly (i.e. the one that was present in the channel that is the input to this function)
# started to sleep. Finally, sleep_start slides a window of length 2 down the input vector (the channel, i.e.
# column in five_min_bouts): when the window is positioned over a `0` followed by a `1`, the index of the `1` minus `1`
# is stored in sleep_start_vec. Note that subtracting `1` from the index of the `1` is necessary because 
# five_minute_bouts starts with a row that is equivalent to `0` minutes; this is due to the fact that
# we added a ghost row to DAM_raw_clean2. The ghost row is required to identify whether a fly was sleeping
# at the very beginning of the experiment (i.e. already sleeping at time = `1` min). The result of this
# ghost row is that any index we identify as the beginning of sleep will be shifted forward in time by `1` min.
# Hence, we need to subtract `1` from any index we find. This leads to the fase impression that we are
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