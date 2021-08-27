library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)
source("~/heme-binding/scripts/r/addpdbcol.R")

CACBFE_fn <- function(activeLigand,activeResultPath)
{
  paste(activeLigand,"CACBFE angle processing...")
  #setwd("~/heme-binding/results/angles_CA_CB_Fe")
  setwd(activeResultPath)
  # import all the shit that's been processed
  # currently using results specific file, all of type .txt; therefore:
  result_files_ls <- list.files(pattern = "*.CACBFe.angle.txt") #double check what's up
  
  # may need to add path = whatever from wd into the parentheses
  # result_files_ls is now a list of all the fuckin txt files
  
  # now read them from the list into a dataframe 
  result_files_df <- lapply(result_files_ls, function(x) {read.delim(file = x, header = FALSE)})
  
  # add source pdb column
  result_files_df <- addpdbcol(result_files_df)
  
  #i think each file now has its own dataframe. now we combine them
  combined_results_df <- do.call("rbind", lapply(result_files_df, as.data.frame))
  
  # 2. get data from the noise ----------------
  combined_results_df %>%
    filter(grepl('ResID',V1)) -> ResID_df
  # note as of 23 July 2021 this is recording residues within 5A of Fe
  
  combined_results_df %>%
    filter(grepl('Angle',V1)) -> angle_raw_df
  
  # rows will mismatch due to exclusion of 'Dihedral' relations. Unless we exclusively
  # focus on two-hemes per pocket, then this will not be of value
  
  # ResID_df wrangling -----------------
  
  ResID_df %>%
    separate(V1, c(NA,"Residue_Number"), "ResID: ") -> ResID_df
  ResID_df %>%
    separate(Residue_Number, c("Residue_Code","Residue_Number"), " ") -> ResID_df
  regexp <- "[[:digit:]]+"
  str_extract(ResID_df$Residue_Number,regexp) -> ResID_df$Residue_Number
  ResID_df$Residue_Number <- as.numeric(as.character(ResID_df$Residue_Number))
  
  # angle_df wrangling ---------------
  angle_raw_df %>%
    separate(V1, c('crap','CA','CB','FE','Angle'),' ') -> t
  
  # from t we only really need CA or CB and Angle. So really:
  angle_raw_df %>%
    separate(V1, c(NA,'CA',NA,NA,'Angle'),' ') -> m
  m %>%
    separate(CA,c(NA,'Residue_Number'),'#0:') -> n
  str_extract(n$Residue_Number,regexp) -> n$Residue_Number
  n$Residue_Number <- as.numeric(as.character(n$Residue_Number))
  n$Angle <- as.numeric(as.character(n$Angle))
  n -> Angle_df
  
  CACBFE_df <- merge(ResID_df,Angle_df,by = c("PDB_ID","Residue_Number"))

  CACBFE_df <- mutate_if(CACBFE_df, is.character,as.factor)
  CACBFE_df <- mutate_if(CACBFE_df, is.numeric,as.factor)
  # closest3Res_df <- mutate_if(closest3Res_df, is.character,as.factor)
  # closest3Res_df <- mutate_if(closest3Res_df, is.numeric,as.factor)
  # 
  return(CACBFE_df)  
}