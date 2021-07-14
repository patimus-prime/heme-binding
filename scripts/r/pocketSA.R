library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
source("~/heme-binding/scripts/r/addpdbcol.R")
#for filtering: https://www.youtube.com/watch?v=PsSqn0pxouM


# 0. Notes on global variables...---------------------------

#may need to specify this option every run/change for running ALL PROCESSED FILES
#options(max.print = 999999999999999999999) #or whatever number


# 1. Assembling all results into one dataframe -----------------------------

#set working directory to the folder w files!
setwd("~/heme-binding/results/pocketSA")

# import all the shit that's been processed
# currently using results specific file, all of type .txt; therefore:
result_files_ls <- list.files(pattern = "*.pocketSA.txt") #double check what's up

# may need to add path = whatever from wd into the parentheses
# result_files_ls is now a list of all the fuckin txt files

# now read them from the list into a dataframe 
result_files_df <- lapply(result_files_ls, function(x) {read.delim(file = x, header = FALSE)})

# add source pdb column
result_files_df <- addpdbcol(result_files_df)

#i think each file now has its own dataframe. now we combine them
combined_results_df <- do.call("rbind", lapply(result_files_df, as.data.frame))
#@ line 981 (w/ orig PDBs, get an enormous volume. can either throw out this header, or filter as below)

# combined_results_df is now the final output of this section and the primary df


# 2. Acquire data from noise --------------------------------------

# only lines with 'surface area'
combined_results_df %>%
  filter(grepl('surface area = ', V1)) -> combined_results_df

# we must divide this into two separate data frames, excluded and accessible.
# they can be merged later into two columns in the same dataframe.
# FIXME: Perhaps rewrite this later when you feel more confident in R skills

combined_results_df %>%
  filter(grepl('excluded', V1)) -> excluded_df
combined_results_df %>%
  filter(grepl('accessible', V1)) -> accessible_df
#these two df would change into two columns of the same in the case of rewrite

# 3 acquire only the numeric data ----------------------

excluded_df %>%
  separate(V1, c(NA ,"Pocket_Excluded_SA"), "= ") -> excluded_df

accessible_df %>%
  separate(V1, c(NA, "Pocket_Accessible_SA"),"= ") -> accessible_df#[['perf']]

# select only the max rows. There's lots of duplicates. The surf() algorithm in Chimera seems to be a troublemaker

excluded_df %>%
  group_by(PDB_ID) %>% slice(which.max(Pocket_Excluded_SA)) -> max_excluded_df


accessible_df %>%
  group_by(PDB_ID) %>% slice(which.max(Pocket_Accessible_SA)) -> max_accessible_df


# 4 into one dataframe --------------------

pocketSA_df <- max_excluded_df
pocketSA_df['Pocket_Accessible_SA'] <- max_accessible_df$Pocket_Accessible_SA

