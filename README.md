# DAM analysR
*Author: Patrick Kratschmer*
## Introduction  

This repository contains work in progress on an R-based analysis package for the Drosophila Activity Monitor (DAM) system.

In order to run it, R needs to be installed on the local computer, and preferably RStudio as an IDE. This is a quick guide to do so:

1. Download R
  * R can be downloaded from CRAN: https://cran.r-project.org/ Simply follow the instructions (and note that XQuartz is needed for Mac users).

2. Download RStudio
  * RStudio can be downloaded from: https://www.rstudio.com/

Once R and RStudio are installed on the local computer, there are two (so far) extra packages that need to be installed before using DAM_analysR. These are:

* xlsx
* plyr

To install these packages, and any other, type ````install.packages("<packagename>")```` into the console in RStudio. Once this is done, start a new R project in RStudio, which sets the working directory to be the new RProject directory. Now the DAM_analysR GitHub repository can be downloaded and all its contents be copied into that RProject directory on the local computer; otherwise, for those using git and GitHub, the remote repo (DAM_analysR) can be forked and set as the working directory in RStudio.

Once the working directory in RStudio contains the contents of DAM_analysR, the analysis of DAM raw output data can begin. First, run the raw data from the DAM through DAM FileScan; the output files from this need to be copied into the RStudio working directory. Second, source analysR.R by ````source("analysR.R")````. Third, run analysR with the name of the raw DAM output file as the first argument, and the length of the experiment in minutes as the second argument (the default experiment duration is 1440 min, i.e. one day). Store the output of analysR in a variable. Below, I go into detail of what the analysR output contains, and how the respective elements are calculated.

## analysR.R

`analysR.R` is the base function used to work through the DAM FileScan output. Its first input is the DAM FileScan output, which is a text file (don't forget parentheses and file extension). Optionally, if the experiment was run for a different duration than 1440 min, the length of the experiment in minutes can be passed into analysR as the second argument. analysR's output is a list of 11 elements. Each element can be accessed by the `$` operator:

   1. `light_regime` is a list of 1's and 0's, where 1 indicates light-on, and 0 light-off. Its length is specified by the `days_in_minutes` argument to `analysR`. Hence, each element of the `light_regime` vector indicates whether during a given minute of the experiment the light was switched on or off.

   2. `transitions` is calculated by `light_dark_transitions.R`, which is sourced from within analysR. This function takes two arguments, `light_regime` and `days_in_minutes`. It walks through light_regime until it encounters a transition from 0 to 1 or vice versa, and stores the index of that transition in two separate vectors, one for dark-light transitions, and one for light-dark transitions, respectively. Note that the minute of transition stored is always the 1, i.e. for light-dark transitions, the last minute in `light_regime` associated with a 1 is stored, while for dark-light transitions, the first minute associated with a 1 is stored. This is because even if the lights were on for just 1 s during a whole 1 min bin, in the DAM raw data, this minute will be associated with a 1. Hence, by storing the indices of the 1's, we know that for light-dark transitions, this was definitely the last minute during which the lights were on, while for dark-light transitions, this was definitely the first minute during which the lights were on.

   3. `DAM_raw` is the raw output from the DAM system, which is exactly the content of the text file you pass into `analysR` as the first argument.

   4. `DAM_raw_clean` extracts columns 12 to 44 from `DAM_raw`, which corresponds to the light regime (column 12 of `DAM_raw`), and the beam crosses per minute for each channel (32 channels in total, resulting in 33 columns). This is done because the first 11 columns are not used for downstream analyses.

   5. `DAM_raw_clean2` binds an extra row of 1's to the beginning of `DAM_raw_clean`, which is important for later calculations of sleep episodes: these are calculated in part by finding a transition from activity to inactivity; if a fly was inactive at the start of the experiment, this can only be interpreted as sleep (if this inactivity lasted for at least 5 min) if we add a row of pseudo-activity to the beginning of each channel. In addition, `DAM_raw_clean2` has the first column removed, which is stored in the vector `light_regime` as stated above, and not carried forward for downstream calculations.

   6. `DAM_raw_clean3` has an additional column added to the start of `DAM_raw_clean2`, which contains a sequence of numbers from 0 to `days_in_minutes`, the second input argument to `analysR`. This is done to "index" every row in `DAM_raw_clean3`.

   7. `analogue_to_binary` takes `DAM_raw_clean3[, 2:33]` (because the first column, the `days_in_minutes`, is not used for this calculation), and transforms any 0 in the data frame into a 1, and any non-0 into a 0. Hence, every minute of inactivity is now represented by a 1, while every minute during which the fly crossed the infrared beam at least once is represented by a 0. This makes `analogue_to_binary` an inactivity representation. Note that `days_in_minutes` is appended as the first column in `analogue_to_binary` after the above calculation is done, so `analogue_to_binary` has 33 columns.

   8. `five_min_bouts` is calculated via the function `sleep_define.R` (`sleep_define.R` must be in the working directory). This function is sourced from within `analysR`. `sleep_define` runs through every column of `analogue_to_binary` (again, except the first one, which is `days_in_minutes`), and looks for five consecutive 1's, i.e. periods of five minutes of inactivity. It does so via a sliding window of length 5, sliding down every column of `analogue_to_binary` from the first row to the fourth-last row (the window would otherwise exceed the length of the column). Whenever it finds a window of five consecutive 1's, it saves a 1 at position 1 of the sliding window in `five_min_bouts`. E.g., if a fly didn't cross the infrared beam between minutes 223 and 227, a 1 is put at position 223 in `five_min_bouts`. As a result, `five_min_bouts` will consist of 0's and 1's, with every 1 indicating that at this moment in time during the experiment (e.g. at minute 223), the fly didn't move for five consecutive minutes, i.e. it didn't move during this minute (e.g. minute 223), and neither during the next four, indicating a period of five minutes of inactivity. If this is interpreted as a single sleep bout, then `five_min_bouts` is a dataframe where every 1 indicates the beginning of a five minute sleep bout (which is how this dataframe got its name). A nine minute sleep bout in `five_min_bouts` would be represented by five 1's in a row, a 300 min sleep bout by 296 1's in a row, an n min sleep bout therefore by (n - 4) 1's in a row, where n >= 5.

   9. `sleep_start_list` is calculated by the function `sleep_start.R`, which is sourced from within `analysR`. `sleep_start` uses a sliding window of length 2 to slide down each column of `five_min_bouts`. Every time it encounters a transition from 0 to 1, it identifies this as the start of a sleep episode, and saves the index of the 1 in a vector. The result (i.e. `sleep_start_list`) is a list of vectors, where each vector contains the indices of sleep starts for one channel (i.e. one fly) for the course of the whole experiment (defined by `days_in_minutes` in `analysR`).

   10. `sleep_end_list` is calculated by the function `sleep_end.R`, which is also sourced from within `analysR`. Like `sleep_start`, `sleep_end` also uses a sliding window of length 2 to slide through each column of `five_min_bouts`. It is important to note how `sleep_end` calculates the index of sleep end. When the window encounters a transition from 1 to 0, it saves the index of the first 1 plus 4 (due to the nature of what a 1 in `five_min_bouts` represents). E.g., if a fly exhibits a sleep bout of 7 minutes at minute 726, `five_min_bouts` will have 1's at positions 726, 727, and 728. Hence, a transition from 1 to 0 will be noticed by `sleep_end` when the window is placed over positions 728 and 729. Because the 1 at position 728 in `five_min_bouts` indicates a sleep bout of 5 minutes, the index that is saved by `sleep_end` is 728 + 4 = 732.

   11. `sleep_bout_length` is calculated by subtracting every element in `sleep_start_list` from every corresponding element in `sleep_end_list`, plus 1. Hence, every list element in `sleep_bout_length` is a list itself and corresponds to one channel. This sub-list contains the length of every sleep bout exhibited by a specific fly throughout the course of the whole experiment. To get the corresponding start and end times of each sleep bout, `sleep_start_list` and `sleep_end_list` must be indexed by the same index as the bout is associated with in `sleep_bout_length`.

## sleepstart_vs_boutlength_txt.R
