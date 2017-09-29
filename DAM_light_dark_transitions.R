DAM_light_dark_transitions <- function(light_regime, days_in_minutes){
    
    dl_transitions <- vector()
    ld_transitions <- vector()
    
    adjusted_days_in_minutes <- days_in_minutes - 1
    
    for(i in 1:adjusted_days_in_minutes){
        
        if(light_regime[i] == 0 && light_regime[i + 1] == 1){
            
            dl_transitions <- c(dl_transitions, (i + 1))
        }
        else if(light_regime[i] == 1 && light_regime[i + 1] == 0){
            
            ld_transitions <- c(ld_transitions, i)
        }
    }
    
    list(dl_transitions = dl_transitions, ld_transitions = ld_transitions)
}