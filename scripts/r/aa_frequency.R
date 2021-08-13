library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021


aaFreq_fn <- function(activeLigand,activeResultPath)
{
  paste(activeLigand,"AA_freq data processing...")
  setwd(activeResultPath)
  #set working directory to the folder w files!
  #aa_freq_path = "~/heme-binding/results/aa_frequency" 
  #setwd(aa_freq_path)
  
  # import all the shit that's been processed
  # currently using results specific file, all of type .txt; therefore:
  result_files_ls <- list.files(pattern = "*.txt")
  
  # may need to add path = whatever from wd into the parentheses
  # result_files_ls is now a list of all the fuckin txt files
  
  # now read them from the list into a dataframe 
  result_files_df <- lapply(result_files_ls, function(x) {read.delim(file = x, header = FALSE)})
  
  #i think each file now has its own dataframe. now we combine them
  combined_results_df <- do.call("rbind", lapply(result_files_df, as.data.frame))
  
  
  # 3. Residues Results ----------------------------------
  
  # now split by " " to create a df we can use to count the residues present around hemes
  combined_results_df %>%
    separate(V1, c("Residues",NA), " ") -> residues_data_df
  
  # create a table of all occurrences of the residues (and some noise, which is removed in next lines)
  residue_table_prelim <- table(unlist(residues_data_df))
  
  # specify the residues, so we can filter the table just for this data. otherwise we retain noise and crap
  residues_ref_ls <- c("ALA","ARG","ASN","ASP","ASX","CYS",
                       "GLU","GLN","GLX","GLY","HIS","ILE",
                       "LEU","LYS","MET","PHE","PRO","SER",
                       "THR","TRP","TYR","VAL")
  
  # convert the table w occurrences into a dataframe, so we can perform cleaning and later plot
  residue_table_prelim_df_w_crap <- as.data.frame(residue_table_prelim)
  
  # remove all the noise, keep the residues
  clean_tbl <- subset(residue_table_prelim_df_w_crap, Var1 %in% residues_ref_ls)
  
  
  # RESIDUE FREQ PLOT! --------------
  
  # order data before we plot
  clean_tbl <- clean_tbl[order(clean_tbl$Freq, decreasing = TRUE), ] #this comma is necessary
  
  clean_tbl -> aa_freq_df
  
  # this 100% works and plots everything
  # NOTE: just zoom + maximize to see ALL NAMES
  
  
  
  # Cleanup!
  rm(#clean_tbl,
     residue_table_prelim,
     result_files_df,
     combined_results_df,
     residue_table_prelim_df_w_crap,
     residues_data_df
     )
  
  return(aa_freq_df)
}