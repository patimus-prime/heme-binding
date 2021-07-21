library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)
source("~/heme-binding/scripts/r/addpdbcol.R")


setwd("~/heme-binding/results/only_distances")

# import all the shit that's been processed
# currently using results specific file, all of type .txt; therefore:
result_files_ls <- list.files(pattern = "*.only.dist.txt") #double check what's up

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

# 2. Get the data from the noise ---------------------------

# drop anything but results, incl. header rows or warnings
# note the 4 .... is due to my uh, affinity for ... and spaces in the python script. Changing this may avoid confusing dots below:
combined_results_df %>%
  filter(grepl('Atom being analyzed...', V1)) -> combined_results_df 

combined_results_df %>%
  separate(V1, c(NA,'V1'),'Atom being analyzed....') -> OnlyDistance_df

OnlyDistance_df %>%
  separate(V1, c('Residue_Analyzed','Distance'),'....Distance to Fe....') -> OnlyDistance_df

OnlyDistance_df %>%
  separate(Residue_Analyzed, c('Residue_Code','Residue_Number','Atom'),' ') -> OnlyDistance_df

# Remove .A from residue number in next two lines
regexp <- "[[:digit:]]+"
str_extract(OnlyDistance_df$Residue_Number,regexp) -> OnlyDistance_df$Residue_Number

# May want to remove Atom entries containing 'FE' as these are all 0 or ~0. 
# May also want to remove all 'HEM'
# done easily via grepl:

# NOTE: THIS DOES REMOVE AN INTERESTING FE THAT IS NOT AT 0. THIS IS THE DOUBLE HEME POCKET.
# HOWEVER, THIS RESULT IS NOT RELEVANT FOR DETERMINING BINDING CHARACTERISTICS OF HEME POCKET,
# RATHER IT'S NOISE DUE TO THE ENVIRONMENT OF THESE TWO HEMES.

# remove iron self-reporting
OnlyDistance_df %>%
  filter(!grepl("FE",Atom)) -> OnlyDistance_df

# remove HEM distances
OnlyDistance_df %>%
  filter(!grepl("HEM",Residue_Code)) -> OnlyDistance_df

# Now, measurements of distance ----------------
# I don't think I've subsetted per row before. 

# need: for each Residue_Num, a unique row in another dataframe
# get max, min, avg, median distance to Fe. This will be input to Res_num, Res_Code. Can be linked
# only to the DISTANG_DF and REPLACE DISTANCE IN THAT DF, OR NOT REPORT IT THERE TO BEGIN WITH. BOOM.

# we already did something similar in volumes, woohoo!
# convert to numerics real quick

OnlyDistance_df$Distance <- as.numeric(as.character(OnlyDistance_df$Distance))
OnlyDistance_df$Residue_Number <- as.numeric(as.character(OnlyDistance_df$Residue_Number))

# 1. Minimum distance to Fe
OnlyDistance_df %>%
  group_by(PDB_ID) %>% slice(which.min(Distance)) -> min_distance_df
  #dank

# 2. Maximum distnace to Fe
OnlyDistance_df %>%
  group_by(PDB_ID) %>% slice(which.max(Distance)) -> max_distance_df
  # sensible result, we select only atoms <= 7A away. NOT RESIDUES

# next part tricky!!!!!!!!!11
# no it's not: https://stackoverflow.com/questions/21982987/mean-per-group-in-a-data-frame

# 3. Average distance to Fe
mean_dist_df <- aggregate(OnlyDistance_df[, 5], list(OnlyDistance_df$PDB_ID), mean)
# rename nasty defaults
mean_dist_df %>%
  rename(
    PDB_ID = Group.1,
    Mean_Distance = x
  ) -> mean_dist_df

# 4. Median distance to Fe
median_dist_df <- aggregate(OnlyDistance_df[, 5], list(OnlyDistance_df$PDB_ID), median)
#rename
median_dist_df %>%
  rename(
    PDB_ID = Group.1,
    Median_Distance = x
  ) -> median_dist_df

#well, that was easy.