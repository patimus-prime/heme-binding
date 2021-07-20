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
#distance_raw_df %>%
#  separate(V1, c(NA,"Distance"),"is ") -> distance_num_df
distance_raw_df %>%
  separate(V1, c(NA,"Res_Num"), "to a") -> dist_aa_df
dist_aa_df %>%
  separate(Res_Num, c('ResNum', 'Dist'), "is ") -> dist_aa_df

#this separates 'em up by a delimiter, and surprisingly splits each line perfectly
#update it for less confusion. but change the name if you'd like to verify it worked

# YAAAAAAAASSSS THAT WORKED WTFFFFFFF AMAZING


#aa and num: same thing as above. use '...' to get the line. Then split by ' '
# NOTE: DO NOT SPLIT BY '...' ALONE. IT FUCKS EVERYTHING UP, likely due to regular expressions
aa_num_raw_df %>%
  separate(V1, c(NA,"another_step_req"), "processing residue...") -> aa_super_df
aa_super_df %>%
  separate(another_step_req, c('Res_code','Res_num'),' ') -> awesome_df
# next two lines to get JUST the number in the second column.
regexp <- "[[:digit:]]+"
str_extract(awesome_df$Res_num,regexp) -> awesome_df$Res_num
awesome_df -> ResCode_ResNum_df

# linking by PDB ID and residue NUM now possible! would give + Residue Code, in this case
# FINALLY! We get angle!
# delimiter ' and ' to get the: aNN and angle.
angle_raw_df %>%
  separate(V1, c(NA,'raw_angle_lines'), 'and ') -> ang1_df
#split by ' is '
ang1_df %>%
  separate(raw_angle_lines, c('Residue_number','Angle'),' is ') -> omega_df

str_extract(omega_df$Residue_number,regexp) -> omega_df$Residue_number

omega_df -> Angles_df

# BOOM! THAT'S EVERYTHING!
# FIXME! RENAME A LOT OF THIS STUFF LOL.

# so for our purposes now, we have: Angles_df. ResCode_ResNum_df. dist_aa_df.

#this must all now be merged!
#use this:
# https://stackoverflow.com/questions/6709151/how-do-i-combine-two-data-frames-based-on-two-columns

# we'll need to actually go back and rename stuff for completeness
#then merging is a triviality.

