# This is the main R file for this project. Launches other scripts used

#source("C:/Users/nobody/Documents/R/MyScript.R")

source("~/heme-binding/scripts/r/volume.R")
source("~/heme-binding/scripts/r/aa_frequency.R")
source("~/heme-binding/scripts/r/hemeSA.R")
source("~/heme-binding/scripts/r/pocketSA.R")
source("~/heme-binding/scripts/r/pdb_titles_codes.R")
#this is the way. but first must only take largest volume pocket from volume data
mega_df <- merge(max_volume_df,hemeSA_df,by.x = "PDB_ID") 
# add pocket surface area stuff. Note this is max pocket surface area
mega_df <- merge(mega_df, pocketSA_df,by.x = "PDB_ID")
# add molecule name
#FIXME! PROBABLY GO BACKWARDS. START WITH PDB_CODE_DF AND ADD VOLUME ETC.
mega_df <- merge(mega_df,pdb_code_df,by.x = "PDB_ID")


# 14 July 2021, 13:12: we need a script to acquire host organism (new function) and mol function (adapt script) 


# TIDY UP! ------------------
rm(result_files_df, 
   combined_results_df,
   temp_df, 
   volume_data_clean, 
   no_quest, 
   line_w_code,
   #clean_tbl,
   residue_table_prelim,
   result_files_df,
   combined_results_df,
   residue_table_prelim_df_w_crap,
   residues_data_df,
   #hemeSA_df,
   #max_volume_df,
   accessible_df,
   excluded_df,
   max_accessible_df,
   max_excluded_df
)
