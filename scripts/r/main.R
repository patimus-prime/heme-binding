# This is the main R file for this project. Launches other scripts used

#source("C:/Users/nobody/Documents/R/MyScript.R")

source("~/heme-binding/scripts/r/volume.R")
source("~/heme-binding/scripts/r/aa_frequency.R")
# not sure what the 'expected 2 pieces' error references with these guys.

#this is how, but first must only take largest volume pocket from volume data
mega_df <- merge(max_volume_df,hemeSA_df,by.x = "PDB_ID")

# TIDY UP! ------------------
rm(result_files_df, 
   combined_results_df,
   temp_df, 
   volume_data_clean, 
   no_quest, 
   line_w_code,
   clean_tbl,
   residue_table_prelim,
   result_files_df,
   combined_results_df,
   residue_table_prelim_df_w_crap,
   residues_data_df
)