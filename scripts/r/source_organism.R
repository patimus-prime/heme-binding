library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)


#to grab the fucking pdb titles
sourceOrganismFn <- function(activeLigand,activeResultPath)
{
  
  setwd(activeResultPath)
  pdb_files_ls <- list.files(pattern = "*.pdb")
  # now read them from the list into a dataframe 
  pdb_files_df <- lapply(pdb_files_ls, function(x) {read.delim(file = x, header = FALSE)})
  
  #i think each file now has its own dataframe. now we combine them
  combined_pdb_df <- do.call("rbind", lapply(pdb_files_df, as.data.frame))
  
  combined_pdb_df %>%
    #separate(V1, c(NA ,"title_of_pdbs"), "TITLE     ") -> title_data_df
    separate(V1, c(NA ,"title_of_pdbs"), "ORGANISM_SCIENTIFIC: ") -> title_data_df
  
  title_data_df <- na.omit(title_data_df)
  
  pdb_list <- as.data.frame(pdb_files_ls)
  
  title_data_df$code = pdb_list$pdb_files_ls
  
  # naming is confusing
  src_org_df <- pdb_list
  
  names(src_org_df)[names(src_org_df) == 'pdb_files_ls'] <- 'PDB_ID'
  
  # get only the pdbs
  src_org_df %>%
    filter(grepl('\\.pdb', PDB_ID)) -> src_org_df
  
  # if only we'd imported this data a different way but whatever:
  
  src_org_df$PDB_ID <- substr(src_org_df$PDB_ID,1,4)
  
  #YAY! Just PDB_ID
  # now add in the column for the molecule names
  src_org_df['Source_Organism'] <- title_data_df$title_of_pdbs
  
  source_organism_df <- src_org_df
  
  return(source_organism_df)
}