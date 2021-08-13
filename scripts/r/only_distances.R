library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)
source("~/heme-binding/scripts/r/addpdbcol.R")

distancesFn <- function(activeLigand,activeResultPath)
{
    
  # data acquisition ----------------------------------
  setwd(activeResultPath)
  setwd("~/heme-binding/results/only_distances")
  
  # import all the shit that's been processed
  # currently using results specific file, all of type .txt; therefore:
  result_files_ls <- list.files(pattern = "*.only.dist.txt") #double check what's up
  
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
  
  # drop anything but results, incl. header rows or warnings
  # note the 4 .... is due to my uh, affinity for ... and spaces in the python script. Changing this may avoid confusing dots below:
  combined_results_df %>%
    filter(grepl('Atom being analyzed...', V1)) -> combined_results_df 
  
  combined_results_df %>%
    separate(V1, c(NA,'V1'),'Atom being analyzed....') -> OnlyDistance_df
  
  OnlyDistance_df %>%
    separate(V1, c('Residue_Analyzed','Distance'),'....Distance to Fe....') -> OnlyDistance_df
  
  OnlyDistance_df %>%
    separate(Residue_Analyzed, c('Residue_Code','Residue_Number','Atom'),' ') -> OnlyDistance_df
  
  # Remove .A from residue number in next two lines
  regexp <- "[[:digit:]]+"
  str_extract(OnlyDistance_df$Residue_Number,regexp) -> OnlyDistance_df$Residue_Number
  
  # May want to remove Atom entries containing 'FE' as these are all 0 or ~0. 
  # May also want to remove all 'HEM'
  # done easily via grepl:
  
  # NOTE: THIS DOES REMOVE AN INTERESTING FE THAT IS NOT AT 0. THIS IS THE DOUBLE HEME POCKET.
  # HOWEVER, THIS RESULT IS NOT RELEVANT FOR DETERMINING BINDING CHARACTERISTICS OF HEME POCKET,
  # RATHER IT'S NOISE DUE TO THE ENVIRONMENT OF THESE TWO HEMES.
  
  # remove iron self-reporting
  OnlyDistance_df %>%
    filter(!grepl("FE",Atom)) -> OnlyDistance_df
  
  #XX
  # remove HEM distances
  OnlyDistance_df %>%
    filter(!grepl(activeLigand,Residue_Code)) -> OnlyDistance_df
  
  # Now, measurements of distance ----------------
  # I don't think I've subsetted per row before. 
  
  # need: for each Residue_Num, a unique row in another dataframe
  # get max, min, avg, median distance to Fe. This will be input to Res_num, Res_Code. Can be linked
  # only to the DISTANG_DF and REPLACE DISTANCE IN THAT DF, OR NOT REPORT IT THERE TO BEGIN WITH. BOOM.
  
  # we already did something similar in volumes, woohoo!
  # convert to numerics real quick
  
  OnlyDistance_df$Distance <- as.numeric(as.character(OnlyDistance_df$Distance))
  OnlyDistance_df$Residue_Number <- as.numeric(as.character(OnlyDistance_df$Residue_Number))
  
  # elimination of non-residues --------------------------
  
  #distance_table_prelim <- table(unlist(OnlyDistance_df))
  residues_ref_ls <- c("ALA","ARG","ASN","ASP","ASX","CYS",
                       "GLU","GLN","GLX","GLY","HIS","ILE",
                       "LEU","LYS","MET","PHE","PRO","SER",
                       "THR","TRP","TYR","VAL")
  
  # FIXME!!! CHANGE HERE TO ERRRRRADICATE THE NON-RES DATAPOINTS
  OnlyDistance_df <- subset(OnlyDistance_df, Residue_Code %in% residues_ref_ls)
  
  
  # STATS DF DECLARATIONS -------------------------------
   
  # 1. Minimum distance to Fe
  OnlyDistance_df %>%
    group_by(PDB_ID) %>% slice(which.min(Distance)) -> min_distance_df
  
  # maybe of interest later
  #barplot(min_distance_df$Distance) 
  
  # 2. Maximum distnace to Fe
  OnlyDistance_df %>%
    group_by(PDB_ID) %>% slice(which.max(Distance)) -> max_distance_df
  
  #barplot(max_distance_df$Distance) #FIXME! NEED TO CONVERT TO NUMERICS
    # sensible result, we select only atoms <= 7A away. NOT RESIDUES
  
  # next part tricky!!!!!!!!!11
  # no it's not: https://stackoverflow.com/questions/21982987/mean-per-group-in-a-data-frame
  
  # 3. Average distance to Fe
  mean_dist_df <- aggregate(OnlyDistance_df[, 5], list(OnlyDistance_df$PDB_ID), mean)
  # rename nasty defaults
  mean_dist_df %>%
    rename(
      PDB_ID = Group.1,
      Mean_Distance = x
    ) -> mean_dist_df
  #hist(mean_dist_df$Mean_Distance) #so, the mean distance across all PDBs
  
  # 4. Median distance to Fe
  median_dist_df <- aggregate(OnlyDistance_df[, 5], list(OnlyDistance_df$PDB_ID), median)
  #rename
  median_dist_df %>%
    rename(
      PDB_ID = Group.1,
      Median_Distance = x
    ) -> median_dist_df
  #hist(median_dist_df$Median_Distance) # median distance across all PDBs
  
  # GRAPHING HISTOGRAMS OF STATISTICS, MEANS AND MEDIANS OF ALL PDBS --------------------
  # upon furher thought none of this is useful to see
  
  
  
  # GRAPHING AS VIOLIN PLOT LET'S GO!!!!!  -----------------------------
  
  #using: http://www.sthda.com/english/wiki/ggplot2-violin-plot-quick-start-guide-r-software-and-data-visualization
  
  # we must convert type to factor, for this plot
  OnlyDistance_df$Residue_Code <- as.factor(OnlyDistance_df$Residue_Code)
  #head(OnlyDistance_df)
  
  distancePlot <- ggplot(OnlyDistance_df, aes(x=Residue_Code, y=Distance, fill = Residue_Code)) +
    geom_violin(trim = FALSE) +
    labs(title = "All Residues' Distance to Fe in each PDB", x="Residue", y="Distance")
   #INCLUDES ALL SMALL MOLS
  
  # note change OnlyDistance_df for just the residues
  mean_SD_distPlot <- ggplot(OnlyDistance_df,aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
    geom_violin(trim=FALSE) +
    labs(title = "All Residues to Fe in each PDB - MEAN+SD", x="Residue", y="Distance") + 
    stat_summary(fun.data = mean_sdl, mult =1, 
                                   geom = "pointrange")
  
  # crap if you decide two groups of plots: wih and without small molecules ---------------------------
  
  #distance_table_prelim <- table(unlist(OnlyDistance_df))
  residues_ref_ls <- c("ALA","ARG","ASN","ASP","ASX","CYS",
                       "GLU","GLN","GLX","GLY","HIS","ILE",
                       "LEU","LYS","MET","PHE","PRO","SER",
                       "THR","TRP","TYR","VAL")
  #distance_df_prelim <- as.data.frame(distance_table_prelim)
  
  #trial_df <- subset(OnlyDistance_df, Residue_Code %in% residues_ref_ls)
  
  #tp <- ggplot(trial_df, aes(x=Residue_Code, y=Distance)) +
   # geom_violin(trim=FALSE)
  #tp #ONLY RESIDUEs
  
  ######################################33333
  #not just minimums, all data with SD/emean
  #########################################33
  # # just residues, same plot as immediatly above: 
  # 
  # distance_table_prelim <- table(unlist(OnlyDistance_df))
  # residues_ref_ls <- c("ALA","ARG","ASN","ASP","ASX","CYS",
  #                      "GLU","GLN","GLX","GLY","HIS","ILE",
  #                      "LEU","LYS","MET","PHE","PRO","SER",
  #                      "THR","TRP","TYR","VAL")
  # distance_df_prelim <- as.data.frame(distance_table_prelim)
  # 
  # trial_df <- subset(OnlyDistance_df, Residue_Code %in% residues_ref_ls)
  # mean_SD_distPlot <- ggplot(trial_df,aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
  #   geom_violin(trim=FALSE) +
  #   labs(title = "Closest Residues to Fe in each PDB", x="Residue", y="Distance")
  # mean_SD_distPlot + stat_summary(fun.data = mean_sdl, mult =1, 
  #                                 geom = "pointrange")
  
  
  
  # not so interesting results!!!! ---------------------
  # TRIM DOWN TO < 5A AWAY, SHOULD BE THOSE RESIDUES THEN WITHIN 3A
  # closer_df <- trial_df[trial_df$Distance <= 5.0,]
  # closer_df <- as.data.frame(closer_df)
  # 
  # u <- ggplot(closer_df, aes(x=Residue_Code,y=Distance)) +
  #   geom_violin(trim=FALSE)
  # u #less than 5A away
  
  
  # CLOSEST RESIDUE PLOTS, V. INTERESTING ----------------
  min_dist_violin <- ggplot(min_distance_df, aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
    geom_violin(trim=FALSE) +
    labs(title = "Closest Residues to Fe in each PDB - Boxplot, Median+Quartiles", x="Residue", y="Distance") +
    geom_boxplot(width=0.1, fill="white") + #adds MEDIAN and QUARTILE
    theme_classic()
   # the closest residue for each PDB. And how their distances fluctuate
                  # now this is remarkable! the coordinating residues are ALWAYS HIS, TYR OR CYS
  
  
  # or mean + SD. I like this the most, let's use this.
  mean_SD_of_min_df <- ggplot(min_distance_df,aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
    geom_violin(trim=FALSE) +
    labs(title = "Closest Residues to Fe in each PDB - Mean+SD", x="Residue", y="Distance") +
    stat_summary(fun.data = mean_sdl, mult =1, 
                                   geom = "pointrange")
  
  # nonpolar plot -------------------------------
  
  nonpolar_ref_ls <- c("LEU", "PHE", "ALA", "VAL", "ILE", "TYR", "GLY")
  nonpolar_res_df <- subset(OnlyDistance_df, Residue_Code %in% nonpolar_ref_ls)
  
  #OnlyDistance_df <- subset(OnlyDistance_df, Residue_Code %in% residues_ref_ls)
  
  
  nonpolar_plot <- ggplot(nonpolar_res_df,aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
    geom_violin(trim=FALSE) +
    labs(title = "Nonpolar Residues to Fe in each PDB - Mean+SD", x="Residue", y="Distance") +
    stat_summary(fun.data = mean_sdl, mult =1,geom = "pointrange")
  # 
  # nonpolar_plot + stat_summary(fun.data = mean_sdl, mult =1, 
  #                                  geom = "pointrange")
  # 
  #
  # ggplot(nonpolar_res_df,aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
  #   geom_violin(trim=FALSE) +
  #   labs(title = "SUPER Nonpolar Residues to Fe in each PDB - Mean+SD", x="Residue", y="Distance") +
  #   stat_summary(fun.data = mean_sdl, mult =1, 
  #                              geom = "pointrange")
  # 
  #return(nonpolar_plot)
  
  # OPTIonS FOR VIOLIN PLOTS: -----------------------------
  
  # p + scale_x_discrete(limits=c("2", "0.5", "1")) #where p is the plot you <- into
  # could add groups per residue, e.g. full spread v. just minimum
  
  #  full example of code:
  # # Basic violin plot
  # ggplot(ToothGrowth, aes(x=dose, y=len)) +
  #   geom_violin(trim=FALSE, fill="gray")+
  #   labs(title="Plot of length  by dose",x="Dose (mg)", y = "Length")+
  #   geom_boxplot(width=0.1)+
  #   theme_classic()
  # # Change color by groups
  # dp <- ggplot(ToothGrowth, aes(x=dose, y=len, fill=dose)) +
  #   geom_violin(trim=FALSE)+
  #   geom_boxplot(width=0.1, fill="white")+
  #   labs(title="Plot of length  by dose",x="Dose (mg)", y = "Length")
  # dp + theme_classic()
  
  
  
  
  # yaaaaaaaay
  # not going to clean the data yet. But you may use this code from th amino acid freq script: -----------------
  
  # here is why this has become a function: here, we can return all plots and call in main.
  return(list(
    "dataframe" = OnlyDistance_df,
    "nonpolar_plot" = nonpolar_plot,
    "min_dist_violin" = min_dist_violin,
    "mean_SD_of_minimum_dist_df" = mean_SD_of_min_df,
    "mean_SD_of_minimum_dist_plot" = mean_SD_distPlot,
    "distance_Plot" = distancePlot
  ))
}
