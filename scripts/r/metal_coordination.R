library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)
source("~/heme-binding/scripts/r/addpdbcol.R")

metal_coordinating_fn <- function()
{
  setwd("~/heme-binding/results/metalCoordination")
  
  # import all the shit that's been processed
  # currently using results specific file, all of type .txt; therefore:
  result_files_ls <- list.files(pattern = "*.processed.metals.txt") #double check what's up
  
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
  
  # from: https://stackoverflow.com/questions/22850026/filter-rows-which-contain-a-certain-string
  # remove the heme coordination within porphyrin
  coordRes_df <- dplyr::filter(combined_results_df, !grepl("HEM",V1))
  
  # now filter for just amino acids. 
  
  # following the steps in aa_Freq script. Need to first convert to a table.
  # then see what rows match having a residue. 
  # remove those that do not, put that into a table
  # convert that to a dataframe and continue processing.
  
  
  # gonna use this, not a beauitful solution but I'm tired and this is EXTRA
  # https://stackoverflow.com/questions/25391975/grepl-in-r-to-find-matches-to-any-of-a-list-of-character-strings
  # ctrl+F, highlight, check in selection, replace ',' with '|'
  # ata$keep <- ifelse(grepl(paste(matches, collapse = "|"), data$animal), "Keep","Discard")
  
  # combined_results_df %>%
  # filter(grepl('Angle', V1)) -> angle_raw_df
  
  coordRes_df %>%
    filter(grepl("ALA|ARG|ASN|ASP|ASX|CYS|
                       GLU|GLN|GLX|GLY|HIS|ILE|
                       LEU|LYS|MET|PHE|PRO|SER|
                       THR|TRP|TYR|VAL",V1)) -> coordRes_df
  
  coordRes_df %>%
    filter(!grepl("warning",V1)) -> coordRes_df
  
  # ok now we need to split by spaces. Then throw out the last row lol
  
  coordRes_df %>%
    separate(V1, c("Residue_Code","Residue_Number")," ") -> coordRes_df
  
  # get rid of .A
  regexp <- "[[:digit:]]+"
  str_extract(coordRes_df$Residue_Number,regexp) -> coordRes_df$Residue_Number
  
  # convert to numeric so we can correctly merge later, if desirable. likely. Can 
  # add two columns of coordination. Then check if same as the two or three closest residue columns.
  # report a boolean column 'TRUE' if the same. IDK if particularly useful.
  coordRes_df$Residue_Number <- as.numeric(as.character(coordRes_df$Residue_Number))
  
  #not sure if this is necessary, but whatever
  coordRes_df$Residue_Code <- as.character(coordRes_df$Residue_Code)
  
  # alright, so, that's it until we start comparing and stuff with mega_df entries
  
  coordRes_df -> Metal_Coordination_df
  
  # let's do a frequency of residues reported as coordinating
  # table() outputs the freq of occurrences of residue_code
  metal_tbl <- table(Metal_Coordination_df)
  metal_tbl <- as.data.frame(metal_tbl)
  # rm(combined_results_df,
  #    coordRes_df,
  #    result_files_df)
  metal_return_list <- list(
    "Frequency_df" = metal_tbl,
    "Metal_coordination_df" = Metal_Coordination_df
  )
  return(metal_return_list)
}