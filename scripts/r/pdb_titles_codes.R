library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)


#to grab the fucking pdb titles

pdb_path = test_path = "~/heme-binding/pdb_source_data/0_raw_download" 
setwd(pdb_path)
pdb_files_ls <- list.files(pattern = "*.pdb")
# now read them from the list into a dataframe 
pdb_files_df <- lapply(pdb_files_ls, function(x) {read.delim(file = x, header = FALSE)})

#i think each file now has its own dataframe. now we combine them
combined_pdb_df <- do.call("rbind", lapply(pdb_files_df, as.data.frame))

combined_pdb_df %>%
  #separate(V1, c(NA ,"title_of_pdbs"), "TITLE     ") -> title_data_df
  separate(V1, c(NA ,"title_of_pdbs"), "COMPND   2 MOLECULE: ") -> title_data_df

title_data_df <- na.omit(title_data_df)

pdb_list <- as.data.frame(pdb_files_ls)

title_data_df$code = pdb_list$pdb_files_ls

#pdb_list %>%
#  separate(pdb_files_ls, c(NA,"Code"), ".txt") -> pdb_list

# naming is confusing
pdb_code_df <- pdb_list

names(pdb_code_df)[names(pdb_code_df) == 'pdb_files_ls'] <- 'PDB_ID'

# get only the pdbs
pdb_code_df %>%
  filter(grepl('\\.pdb', PDB_ID)) -> pdb_code_df

# if only we'd imported this data a different way but whatever:

pdb_code_df$PDB_ID <- substr(pdb_code_df$PDB_ID,1,4)

#YAY! Just PDB_ID
# now add in the column for the molecule names
pdb_code_df['Molecule Name'] <- title_data_df$title_of_pdbs

#pdb_code_df <- title_data_df$title_of_pdbs
#pdb_code_df <- as.data.frame(pdb_code_df)
#new_title_df <- title_data_df$title_of_pdbs
#new_title_df <- as.data.frame(new_title_df)
#id_title_df <- merge(pdb_code_df,new_title_df,by.x = "PDB_ID")

#mega_df <- merge(max_volume_df,hemeSA_df,by.x = "PDB_ID") 