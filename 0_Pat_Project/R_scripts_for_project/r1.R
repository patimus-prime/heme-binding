library(dplyr) 
library(data.table)
library(tidyr)

#may need to specify this option every run/change for running ALL PROCESSED FILES
#options(max.print = 999999999999999999999) #or whatever number


#set working directory to the folder w files!
test_path = "~/0_Pat_Project/test_folder/results" 
setwd(test_path)

# import all the shit that's been processed
# currently using results specific file, all of type .txt; therefore:
volume_results_ls <- list.files(pattern = "*.txt")
#may need to add path = whatever from wd into the paranthases
# volume_results_ls is now a list of all the fuckin txt files

#now read them from the list into a dataframe
# requires uniform text file 
volume_results_df <- lapply(volume_results_ls, function(x) {read.delim(file = x, header = FALSE)})

#i think each file now has its own dataframe. now we combine them
combined_volume_results_df <- do.call("rbind", lapply(volume_results_df, as.data.frame))

combined_volume_results_df %>%
  separate(V1, c(NA ,"volume_data"), "volume = ") -> final_volume_data_df

final_volume_data_df$volume_data <- as.numeric(as.character(final_volume_data_df$volume_data))
hist(final_volume_data_df$volume_data,
     main = "Distribution of Volume of Pockets",
     xlab = "Volume, A3",
     col="darkmagenta",
     xlim=c(0,5000),
     breaks = c(0,100,150,200,250,300,350,400,450,500,5000))
