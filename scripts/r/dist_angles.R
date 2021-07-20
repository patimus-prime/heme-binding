# This script is to import all distance/angle data into R. 
# slightly dependent uponn Python script details as to what 
# additional... helper information is printed out into the replylog.
# here we go:

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
#hemeSA_path = "~/heme-binding/results/hemeSA" 
#setwd(hemeSA_path)
setwd("~/heme-binding/results/distances_and_angles")

# import all the shit that's been processed
# currently using results specific file, all of type .txt; therefore:
result_files_ls <- list.files(pattern = "*.dist.angle.txt") #double check what's up

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

# 2. Acquire data from noise ---------------------------------------

# aight, this reply log kinda sucks so we're gonna need multiple data frames to cope
# kinda gonna reference *SA.R to deal with multiple outputs in one file
# forgive me for the extra dataframes! Will try to sweep up at the end.

# this grabs only the lines containing the grepl. We'll grab
# specific results first into respective dataframes, then join at the end.
# so, e.g. Distance df. AA# and residue code df. Angle df. Join by AA or whatever later.

# distance_raw_df contains all lines with 'Distance'
combined_results_df %>%
  filter(grepl('Distance', V1)) -> distance_raw_df
# 'to a' can be used to get residue number

# aa_num_raw_df contains all lines with the residues and residue number.
combined_results_df %>%
  filter(grepl('currently processing residue...', V1)) -> aa_num_raw_df

# angle_raw_df contains all lines listing residue num and angle
combined_results_df %>%
  filter(grepl('Angle', V1)) -> angle_raw_df
# 'and a" can be used to get the residue number.

# PDB ID will be needed to correctly link results/avoid doubling up on the residue #s
# if necessary, add a separate column for 'unique ID' like 1-90 for ea. pdb I guess
# hopefully unnecessary!

# So, distance first:

# angle row # == dist row #, so we're doing great so far. GJ me.

