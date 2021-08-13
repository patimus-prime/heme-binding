# This script is to import all distance/angle data into R. 
# slightly dependent uponn Python script details as to what 
# additional... helper information is printed out into the replylog.
# here we go:

library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)
source("~/heme-binding/scripts/r/addpdbcol.R")
#for filtering: https://www.youtube.com/watch?v=PsSqn0pxouM


aaAnglesFn <- function(activeLigand,activeResultPath)
{
   paste(activeLigand,"aa to ligand plane processing...")
   # 0. Notes on global variables...---------------------------
   
   #may need to specify this option every run/change for running ALL PROCESSED FILES
   #options(max.print = 999999999999999999999) #or whatever number
   
   
   # 1. Assembling all results into one dataframe -----------------------------
   
   #set working directory to the folder w files!
   #hemeSA_path = "~/heme-binding/results/hemeSA" 
   #setwd(hemeSA_path)
   #setwd("~/heme-binding/results/distances_and_angles")
   setwd(activeResultPath)
   # import all the shit that's been processed
   # currently using results specific file, all of type .txt; therefore:
   #XXXXX THIS WILL PROBABLY CHANGE... THE EXTENSION, EVENTUALLY MANNNNN
   result_files_ls <- list.files(pattern = "*.dist.angle.txt") #double check what's up
   
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
   
   # 2. Acquire data from noise ---------------------------------------
   
   # aight, this reply log kinda sucks so we're gonna need multiple data frames to cope
   # kinda gonna reference *SA.R to deal with multiple outputs in one file
   # forgive me for the extra dataframes! Will try to sweep up at the end.
   
   # this grabs only the lines containing the grepl. We'll grab
   # specific results first into respective dataframes, then join at the end.
   # so, e.g. Distance df. AA# and residue code df. Angle df. Join by AA or whatever later.
   
   # distance_raw_df contains all lines with 'Distance'
   combined_results_df %>%
     filter(grepl('Distance', V1)) -> distance_raw_df
   # 'to a' can be used to get residue number
   
   # aa_num_raw_df contains all lines with the residues and residue number.
   combined_results_df %>%
     filter(grepl('currently processing residue...', V1)) -> aa_num_raw_df
   
   # angle_raw_df contains all lines listing residue num and angle
   combined_results_df %>%
     filter(grepl('Angle', V1)) -> angle_raw_df
   # 'and a" can be used to get the residue number.
   
   # PDB ID will be needed to correctly link results/avoid doubling up on the residue #s
   # if necessary, add a separate column for 'unique ID' like 1-90 for ea. pdb I guess
   # hopefully unnecessary!
   
   # So, distance first:
   # 3. Process Distance -------------------------------------
   # angle row # == dist row #, so we're doing great so far. GJ me.
   
   distance_raw_df %>%
     separate(V1, c(NA,"Residue_Number"), "to a") -> Distance_df
   Distance_df %>%
     separate(Residue_Number, c('Residue_Number', 'Distance'), "is ") -> Distance_df
   #volume_data_df$volume_data <- as.numeric(as.character(volume_data_df$volume_data))
   Distance_df$Distance <- as.numeric(as.character(Distance_df$Distance))
   Distance_df$Residue_Number <- as.numeric(as.character(Distance_df$Residue_Number))
   #this separates 'em up by a delimiter, and surprisingly splits each line perfectly
   #update it for less confusion. but change the name if you'd like to verify it worked
   
   # YAAAAAAAASSSS THAT WORKED WTFFFFFFF AMAZING
   # 4. Process Amino acid residues/codes -----------------------------
   
   #aa and num: same thing as above. use '...' to get the line. Then split by ' '
   # NOTE: DO NOT SPLIT BY '...' ALONE. IT FUCKS EVERYTHING UP, likely due to regular expressions
   aa_num_raw_df %>%
     separate(V1, c(NA,"another_step_req"), "processing residue...") -> aa_num_raw_df
   aa_num_raw_df %>%
     separate(another_step_req, c('Residue_Code','Residue_Number'),' ') -> aa_num_raw_df
   # next two lines to get JUST the number in the second column.
   regexp <- "[[:digit:]]+"
   str_extract(aa_num_raw_df$Residue_Number,regexp) -> aa_num_raw_df$Residue_Number
   aa_num_raw_df -> ResCode_ResNum_df
   ResCode_ResNum_df$Residue_Number <- as.numeric(as.character(ResCode_ResNum_df$Residue_Number))
   
   # 5. PRocess angles ------------------------------------
   # linking by PDB ID and residue NUM now possible! would give + Residue Code, in this case
   # FINALLY! We get angle!
   # delimiter ' and ' to get the: aNN and angle.
   angle_raw_df %>%
     separate(V1, c(NA,'raw_angle_lines'), 'and ') -> angle_raw_df
   #split by ' is '
   angle_raw_df %>%
     separate(raw_angle_lines, c('Residue_Number','Angle'),' is ') -> Angles_df
   
   str_extract(Angles_df$Residue_Number,regexp) -> Angles_df$Residue_Number
   Angles_df$Residue_Number <- as.numeric(as.character(Angles_df$Residue_Number))
   # so for our purposes now, we have: Angles_df. ResCode_ResNum_df. Distance_df
   
   #this must all now be merged!
   #use this:
   # https://stackoverflow.com/questions/6709151/how-do-i-combine-two-data-frames-based-on-two-columns
   
   # NOTE: ALL THE ABOVE 'AS.NUMERIC, AS.CHARACTER' ARE TO GET THE DISTANCE FROM STR -> NUMERIC,
   # SO THAT THE MERGE BELOW CAN ACTUALLY OCCUR.
   
   # 6. Merge ---------------------------
   omega_df <- merge(Distance_df,Angles_df,by = c("PDB_ID","Residue_Number"))#,"Residue_Number"))
   omega_df <- merge(omega_df,ResCode_ResNum_df, by = c("PDB_ID","Residue_Number"))
   
   Distance_and_Angles_df <- omega_df
   
   # 7. Plotting ---------------------------
   
   # all data in Distances...df, and we are only interested in the angles.
   # btw we can probably revert to'plane' for HEM. Since only interested in angles
   
   # we must convert type to factor, for this plot
   
   Distance_and_Angles_df$Angle <- as.numeric(as.character(Distance_and_Angles_df$Angle))
   Distance_and_Angles_df$Residue_Number <- as.numeric(as.character(Distance_and_Angles_df$Residue_Number))
   
   Distance_and_Angles_df$Residue_Code <- as.factor(Distance_and_Angles_df$Residue_Code)
   #head(Distance_and_Angles_df)
   angleplot <- ggplot(Distance_and_Angles_df, aes(x=Residue_Code, y=Angle, fill = Residue_Code)) +
      geom_violin(trim=FALSE) +
      labs(title = "Angles of Residues v. Heme (defined as axis) in each PDB", x="Residue",y="Angle")
   #angleplot #ENSURE YOU CONVERT TO NUMERIC DATA TYPES ABOVE
   
   #welp, that's not conclusive, at all.
   
   # let's look at the angles of the closest residues:
   # those are: Cys, His, and Tyr, as the exclusive residues picked up by minimum distance
   coord_Res_ls <- c("CYS","HIS","TYR")
   coord_Res_df <- subset(Distance_and_Angles_df, Residue_Code %in% coord_Res_ls)
   
   coord_angle_plot <- ggplot(coord_Res_df, aes(x=Residue_Code,y=Angle,fill=Residue_Code)) +
      geom_violin(trim=FALSE) +
      labs(title = "Angles of Residues MOST LIKELY to coordinate. 
           Does not select for residues that are actually confirmed as coordinating",
           x="Residue",y="Angle") +
      stat_summary(fun.data = mean_sdl, mult =1,geom="pointrange")
      
   Distance_and_Angles_df %>%
      group_by(PDB_ID) %>% slice(which.min(Distance)) -> min_dist_df
   
   min_dist_angles_plot <- ggplot(min_dist_df, aes(x=Residue_Code,y=Angle,fill=Residue_Code)) +
      geom_violin(trim=FALSE) +
      labs(title = "Angles of each PDB's closest residue to Heme, where heme is defined as an axis",
           x = "Residue",y="Angle") +
      stat_summary(fun.data = mean_sdl, mult=1,geom="pointrange")
   
   # nonpolar_plot <- ggplot(nonpolar_res_df,aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
   #    geom_violin(trim=FALSE) +
   #    labs(title = "Nonpolar Residues to Fe in each PDB - Mean+SD", x="Residue", y="Distance") +
   #    stat_summary(fun.data = mean_sdl, mult =1,geom = "pointrange")
   # 
   
   

   # CLEANUP ---------------------------
   rm(awesome_df,
      combined_results_df,
      dist_aa_df,
      distance_raw_df,
      omega_df,
      result_files_df,
      regexp,
      result_files_ls,
      aa_num_raw_df,
      aa_super_df,
      ang1_df,
      angle_raw_df
   )
   #return stuff ----------
   distAngleList <- list(
      "angleplot" = angleplot,
      "coordinating_res_plot" = coord_angle_plot,
      "angleDF" = Distance_and_Angles_df,
      "min_dist_angles_plot" = min_dist_angles_plot
   )
   
   return(distAngleList)
   # return(list(
   # angleplot,
   # coord_angle_plot,
   # ), Distance_and_Angles_df)
}