library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
source("~/heme-binding/scripts/r/addpdbcol.R")
#for filtering: https://www.youtube.com/watch?v=PsSqn0pxouM

ligandSA_fn <- function(activeLigand,activeResultPath)
{
  #activeLigand = c("HEM")
  #activeResultPath = "~/heme-binding/results/ligandSA/HEM"
  paste(activeLigand,"ligand SA processing...")
  setwd(activeResultPath)  
  # 0. Notes on global variables...---------------------------
  
  #may need to specify this option every run/change for running ALL PROCESSED FILES
  #options(max.print = 999999999999999999999) #or whatever number
  
  
  # 1. Assembling all results into one dataframe -----------------------------
  
  #set working directory to the folder w files!
  #hemeSA_path = "~/heme-binding/results/hemeSA" 
  #setwd(hemeSA_path)
  #setwd("~/heme-binding/results/hemeSA")
  
  # import all the shit that's been processed
  # currently using results specific file, all of type .txt; therefore:
  result_files_ls <- list.files(pattern = "*.ligandSA.txt") #double check what's up
  
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
  
  
  # 2. Acquire data from noise ------------
  
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
  
  
  # acquire only the numeric data
  
  # THIS ONE TO CHECK, BUT SEEMS 100% OK!
  #excluded_df %>%
  #  separate(V1, c(NA ,"exc_sa"), "= ") -> excluded_df[['exc_sa']]
  
  excluded_df %>%
    separate(V1, c(NA ,"Excluded_SA"), "= ") -> excluded_df
  
  accessible_df %>%
    separate(V1, c(NA,paste("Accessible_SA")),"= ") -> accessible_df#[['perf']]
  
  
  # only max, in case of duplicate heme 
  
  excluded_df %>%
    group_by(PDB_ID) %>% slice(which.max(Excluded_SA)) -> max_excluded_df
  
  accessible_df %>%
    group_by(PDB_ID) %>% slice(which.max(Accessible_SA)) -> max_accessible_df
  
  max_excluded_df$Excluded_SA <- as.numeric(as.character(max_excluded_df$Excluded_SA))
  max_accessible_df$Accessible_SA <- as.numeric(as.character(max_accessible_df$Accessible_SA))
  
  # 4 into one dataframe --------------------
  
  ligandSA_df <- max_excluded_df
  ligandSA_df[paste(activeLigand,'_Accessible_SA',sep = "")] <- max_accessible_df$Accessible_SA
  # mut rename first column 
  #names(df)[names(df) == 'old.var.name'] <- 'new.var.name'
  names(ligandSA_df)[names(ligandSA_df) == 'Excluded_SA'] <- (paste(activeLigand,'_Excluded_SA',sep = ""))
  
  #hemeSA_df <- max_excluded_df
  #hemeSA_df['Heme_Accessible_SA'] <- max_accessible_df$Heme_Accessible_SA
  
  # and convert into numerics lol!!!!
  # 
  # hemeSA_df$Heme_Excluded_SA <- as.numeric(as.character(hemeSA_df$Heme_Excluded_SA))
  # hemeSA_df$Heme_Accessible_SA <- as.numeric(as.character(hemeSA_df$Heme_Accessible_SA))
  # 
  
  # put into one dataframe
  
  #hemeSA_df <- excluded_df
  #hemeSA_df['Heme_Accessible_SA'] <- accessible_df$Heme_Accessible_SA
  
  #BING BANG BOOM! hemeSA_df is the final result of all this painful work lol
  
  
  
  #colnames(hemeSA_df)[which(names(hemeSA_df) == "V1")] <- "Excluded_SA"
  #colnames(dataframe)[which(names(dataframe) == "columnName")] <- "newColumnName"
  #https://stackoverflow.com/questions/6081439/changing-column-names-of-a-data-frame
  
  return(ligandSA_df)
}
