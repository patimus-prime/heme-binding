library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
source("~/heme-binding/scripts/r/addpdbcol.R")


volumeFn <- function(activeLigand, activeResultPath)
{

  #activeLigand = "VEA"
  
  #activeResultPath = "~/heme-binding/results/volume/VEA"
  #for filtering: https://www.youtube.com/watch?v=PsSqn0pxouM
  #paste(activeLigand,"Volume data processing...")
  
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
  #activeResultPath
  # may need to add path = whatever from wd into the parentheses
  # result_files_ls is now a list of all the fuckin txt files
  #result_files_ls
  # now read them from the list into a dataframe 
  result_files_df <- lapply(result_files_ls, function(x) {read.delim(file = x, header = FALSE,encoding="UTF-8")})
  #rrrrr <- lapply(result_files_ls, function(y) {data.table::fread(file = y)})
  # add source pdb column
  result_files_df <- addpdbcol(result_files_df)
  
  #i think each file now has its own dataframe. now we combine them
  combined_results_df <- do.call("rbind", lapply(result_files_df, as.data.frame))
  #@ line 981 (w/ orig PDBs, get an enormous volume. can either throw out this header, or filter as below)
  
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
   #volume_data_df <- volume_data_df[volume_data_df$volume_data <= 1000, ] 
   #volume_data_df <- as.data.frame(volume_data_df)
   
   
   # selecting only the max for each row
   volume_data_df %>%
     group_by(PDB_ID) %>% slice(which.max(volume_data)) -> max_volume_df
   
   ##group %>% group_by(sub) %>% slice(which.max(marks))
   # from: https://www.geeksforgeeks.org/how-to-select-row-with-maximum-value-in-each-group-in-r-language/
   
  # 4. VOLUME DATA PLOT! -----------------
  # moved to main!
   
  # hist(volume_data_df$volume_data,
  #      main = "Distribution of Volume of Pockets",
  #      xlab = "Volume, A3",
  #      col = "darkmagenta",
  #      xlim = c(50,600), #force start at 50 then go to 1000
  #      #breaks = c(0,100,150,200,250,300,350,400,450,1000)
  #      )
  # 
  #  
   
  # 99. Cleanup! ----------
   # rm(result_files_df, 
   #    combined_results_df,
   #    temp_df, 
   #    volume_data_clean, 
   #    no_quest, 
   #    line_w_code
   #    
   # )
   
   # return data ----------
   #return stuff ----------
   
   volumeDataframes <- list(
     "allVolDf" = volume_data_df,
     "maxVolDf" = max_volume_df 
   )
  return(volumeDataframes)
   #return(max_volume_df)
}