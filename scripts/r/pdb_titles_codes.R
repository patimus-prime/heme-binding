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

write.csv(title_data_df, "~/0_Pat_Project/test_folder/titles_codes.csv", row.names = FALSE)
#write.csv(Your DataFrame,"Path to export the DataFrame\\File Name.csv", row.names = FALSE)




# attempts and trash ----------------

#IDK HOW TO GET RID OF THE .PDB
#pdb_list[pdb_files_ls] = pdb_list[pdb_files_ls].str.replace(".pdb","")
#df[pdb_list] = df[pdb_list].str.replace(".pdb","")
#pdb_list["pdb_files_ls"] = pdb_list["pdb_files_ls"].str_replace(".pdb","")
#pdb_list$pdb_files_ls = pdb_list$pdb_files_ls.str.replace(".pdb","")

#df["Date"] = df["Date"].str.replace("\s:00", "")
#pdb_list <- strsplit(as.character(pdb_list$pdb_files_ls),".pdb")

#pdb_list <- as.data.frame(t(pdb_list))
