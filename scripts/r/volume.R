library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021


library(tidyverse)
library(datasets)
#for filtering: https://www.youtube.com/watch?v=PsSqn0pxouM

#############################
# It is now uh, appropriate-seeming to add in a table of contents.
# So, by header in this code we have:
# 0. Notes on global variables that must be altered for this code to run properly
# 1. Assemble all lines/results from the result log from Chimera into one data_frame
# 2. Volume results and cleaning code
# 3. Residue results and cleaning
# 4. Plotting
############################

# 0. Notes on global variables...---------------------------

#may need to specify this option every run/change for running ALL PROCESSED FILES
#options(max.print = 999999999999999999999) #or whatever number

# 1. Assembling all results into one dataframe -----------------------------

#set working directory to the folder w files!
volume_path = "~/heme-binding/results/volume" 
setwd(volume_path)

# import all the shit that's been processed
# currently using results specific file, all of type .txt; therefore:
result_files_ls <- list.files(pattern = "*.txt")

# may need to add path = whatever from wd into the parentheses
# result_files_ls is now a list of all the fuckin txt files

# now read them from the list into a dataframe 
result_files_df <- lapply(result_files_ls, function(x) {read.delim(file = x, header = FALSE)})

#i think each file now has its own dataframe. now we combine them
combined_results_df <- do.call("rbind", lapply(result_files_df, as.data.frame))
#@ line 981 (w/ orig PDBs, get an enormous volume. can either throw out this header, or filter as below)

# combined_results_df is now the final output of this section and the primary df

# 2. Volume Data ------------------------------------------

# NOTE: this gets kind of complicated and we go back and forth with operations
# and then converting back to dataframe

# this line splits the lines by delimiter "volume =" to create the volume_data_df
# NOTE!!! This removes some data for tracability if we want to look back at specific pockets. But this seems highly improbably desirable
# WE'LL HAVE ABSOLUTELY NO IDEA WHOSE VOLUME IS WHOSE. THIS APPLIES ALSO TO OTHER DATA ACHIEVED WITH THIS SAME METHOD


# FIXME!! Still need to add first column of where this data FUCKING COMES FROM




# THIS FILTERS ONLY FOR REAL, INDIV VOLUMES ACQUIRED!!!
combined_results_df %>%
  filter(grepl('[?]', V1)) -> no_quest

combined_results_df %>%
  separate(V1, c(NA ,"volume_data"), "volume = ") -> volume_data_df

# remove the NA values from the dataframe (this is a result of rows that did not contain volume data)
volume_data_clean <- na.omit(volume_data_df)
volume_data_df <- volume_data_clean

# shit was imported from the text file as strings, convert to numbers
volume_data_df$volume_data <- as.numeric(as.character(volume_data_df$volume_data))






# remove outliers, as we got some w/ 40k A3
# outlier operation however FUCKS IT UP so... need to convert back to df in between ops
# therefore, below code filters >50, conv back to df, filter <= 1000, conv back to df
 volume_data_df <- volume_data_df[volume_data_df$volume_data >= 50, ]
 volume_data_df <- as.data.frame(volume_data_df)
 #volume_data_df <- volume_data_df[volume_data_df$volume_data <= 1000, ] 
 #volume_data_df <- as.data.frame(volume_data_df)
 
# achieved volume dataframe with just volume data limited to 0-1000 A^3; difficult lol



# 4. Plotting -------------------------

# VOLUME DATA PLOT! -----------------vvv
hist(volume_data_df$volume_data,
     main = "Distribution of Volume of Pockets",
     xlab = "Volume, A3",
     col = "darkmagenta",
     xlim = c(50,600), #force start at 50 then go to 1000
     #breaks = c(0,100,150,200,250,300,350,400,450,1000)
     )

 