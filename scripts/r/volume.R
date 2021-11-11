library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
source("~/heme-binding/scripts/r/addpdbcol.R")


volumeFn <- function(activeLigand, activeResultPath)
{

  # 0. Notes on global variables...---------------------------
  
  #may need to specify this option every run/change for running ALL PROCESSED FILES
  #options(max.print = 999999999999999999999) #or whatever number
  
  
  # 1. Assembling all results into one dataframe -----------------------------
  
  #set working directory to the folder w files!
  #setwd("~/heme-binding/results/volume") 
  setwd(activeResultPath)
  
  # import all the shit that's been processed
  # currently using results specific file, all of type .txt; therefore:
  result_files_ls <- list.files(pattern = "*.txt")
  
  # now read them from the list into a dataframe 
  result_files_df <- lapply(result_files_ls, function(x) {read.delim(file = x, header = FALSE,encoding="UTF-8")})
  
  # add source pdb column
  result_files_df <- addpdbcol(result_files_df)
  
  #i think each file now has its own dataframe. now we combine them
  combined_results_df <- do.call("rbind", lapply(result_files_df, as.data.frame))
  
  # combined_results_df is now the final output of this section and the primary df
  
  
  # 2. Volume Data ------------------------------------------
  
  # get only the REAL, INDIV VOLUMES ACQUIRED!!!
  # remove the sum volume
  combined_results_df %>%
    filter(grepl('[?]', V1)) -> combined_results_df
  
  # acquire only the numeric data
  combined_results_df %>%
    separate(V1, c(NA ,"volume_data"), "volume = ") -> volume_data_df
  
  
  # 3. Filter ------------
  
  # remove the NA values from the dataframe (this is a result of rows that did not contain volume data)
  volume_data_clean <- na.omit(volume_data_df)
  volume_data_df <- volume_data_clean
  
  # shit was imported from the text file as strings, convert to numbers
  volume_data_df$volume_data <- as.numeric(as.character(volume_data_df$volume_data))
  
  # remove outliers ----------
  # outlier operation however FUCKS IT UP so... need to convert back to df in between ops
  # therefore, below code filters >50, conv back to df, filter <= 1000, conv back to df
   volume_data_df <- volume_data_df[volume_data_df$volume_data >= 50, ]
   volume_data_df <- as.data.frame(volume_data_df)
  
   # LIKELY DESIRABLE TO REMOVE BIG ASS VOLUMES 
    #volume_data_df <- volume_data_df[volume_data_df$volume_data <= 1000, ] 
   #volume_data_df <- as.data.frame(volume_data_df)
   
   
   # selecting only the max for each row
   volume_data_df %>%
     group_by(PDB_ID) %>% slice(which.max(volume_data)) -> max_volume_df
   
   ##group %>% group_by(sub) %>% slice(which.max(marks))
   # from: https://www.geeksforgeeks.org/how-to-select-row-with-maximum-value-in-each-group-in-r-language/
   
   # multiple dataframes must be returned as a list - use this to your advantage 
   volumeDataframes <- list(
     "allVolDf" = volume_data_df,
     "maxVolDf" = max_volume_df 
   )
  return(volumeDataframes)
   #return(max_volume_df)
}