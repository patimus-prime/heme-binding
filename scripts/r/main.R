# This is the main R file for this project. Launches other scripts used
library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) #thus far not used 22 June 2021
library(stringr)
source("~/heme-binding/scripts/r/addpdbcol.R")
#source("C:/Users/nobody/Documents/R/MyScript.R")

source("~/heme-binding/scripts/r/volume.R")
source("~/heme-binding/scripts/r/aa_frequency.R")
source("~/heme-binding/scripts/r/hemeSA.R")
source("~/heme-binding/scripts/r/pocketSA.R")

# for the pdb-Titles_codes script, YOU MUST NOT HAVE ANYTHING THAT COULD INTERFERE
# WITH THE REGEXP '.pdb' in the folder!!!! this will throw errors!
# now still throws an error but minor. I think it doesn't like the source dataframe only having 1 column
source("~/heme-binding/scripts/r/pdb_titles_codes.R") #error here investigate 15 July 2021
source("~/heme-binding/scripts/r/source_organism.R")
source("~/heme-binding/scripts/r/dist_angles.R")
source("~/heme-binding/scripts/r/metal_coordination.R")
source("~/heme-binding/scripts/r/only_distances.R")
source("~/heme-binding/scripts/r/anglesCACBFE.R")
# ok let's reorder

# merge all dataframes reported (not produced by functions) into mega dataframe: -----

mega_df <- merge(pdb_code_df,source_organism_df,by.x = "PDB_ID")
#this is the way. but first must only take largest volume pocket from volume data
mega_df <- merge(mega_df, max_volume_df,by.x = "PDB_ID")
mega_df <- merge(mega_df,hemeSA_df,by.x = "PDB_ID")
mega_df <- merge(mega_df, pocketSA_df,by.x = "PDB_ID")


# NOTE!!! The line immediately below cannot occur. There are multiple entries in each PDB. This is what
# necessitates grabbing the top 2 or 3 residues, and listing them. 
#mega_df <- merge(mega_df, Distance_and_Angles_df, by.x = "PDB_ID")


#WE ALSO CANNOT MERGE METAL_COORDINATION. NOT YET.

# so it's easy to see:

# the four lines below acquire the dataframes produced by functions...
temp_list <- anglesFn()
Distance_and_Angles_df <- temp_list$angleDF

metal_list <- metal_coordinating_fn()
Metal_Coordination_df <- metal_list$Metal_coordination_df

CACBFE_df <- CACBFE_fn()

# put into the easily visibile DF 
mega_df -> AAAA_MEGA_DF
Distance_and_Angles_df -> AAAA_DISTANG_DF
Metal_Coordination_df -> AAAA_METAL_DF

# Graphs: ----------------------------------

# declare a list to add all plots to, makes exporting easier
plots <- list()

# AA FREQ PLOT --------------------

aa_freq_df <- aaFreq_fn()
aa_freq_plot <- barplot(aa_freq_df$Freq,
        main = "Frequency of Residues within 7A of Heme",
        xlab = "Residues",
        ylab = "Frequency",
        col = "orange",
        names.arg = aa_freq_df$Var1,
)
plots <- aa_freq_plot

# METAL COORD FREQ PLOT ------------
metal_freq <- metal_list$Frequency_df

metal_coord_plot <- barplot(metal_freq$Freq,
        main = "Metal Coordinating Residue Freq for Heme, as determined by Chimera",
        xlab = "Residues",
        ylab = "Frequency",
        col = "hotpink",
        names.arg =metal_freq$Var1,
        
)
plots <- metal_coord_plot



# Histograms/barplots of the MEGA dataframe data --------------------
# see this link for adding more stats: https://www.stattutorials.com/R/R_Describe_data2,%20Histograms.html

volume_hist <- hist(mega_df$volume_data,
     main = "Volume of Pockets in ea PDB, A^3",
     xlab = "Volume, A^3",
     #ylab = "Frequency",
     col = "darkmagenta"
     )
plots <- volume_hist

heme_excSA <- hist(mega_df$Heme_Excluded_SA,
     main = "Heme Excluded Surface Area in ea PDB, square A",
     xlab = "Excluded Surface Area, A^2",
     col = "blue"
     )
plots <- heme_excSA

heme_accSA <- hist(mega_df$Heme_Accessible_SA,
     main = "Heme Accessible Surface Area, A^2",
     xlab = "Accessible Surface Area, A^2",
     col = "lightblue"
     )
plots <- heme_accSA

pocket_excSA <- hist(mega_df$Pocket_Excluded_SA,
     main = "Pocket Excluded Surface Area, A^2",
     xlab = "Excluded Surface Area, A^2",
     col = "green"
     )
plots <- pocket_excSA

pocket_accSA <- hist(mega_df$Pocket_Accessible_SA,
     main = "Pocket Accessible Surface Area, A^2",
     xlab = "Accessible Surface Area, A^2",
     col = "lightgreen"
     )
plots <- pocket_accSA


# distance plots ------------------
# return from that shit!
distance_plots <- onlyDist() # returns of all fancy plots to put in
# print the dank plots!
distance_plots
plots <- distance_plots

# angle plots -------------------
# we return a dataframe from angles also, so we use this protocol.
# found here. may be applied above: https://stackoverflow.com/questions/8936099/returning-multiple-objects-in-an-r-function

angle_plots <- anglesFn()
angle_plots$angleplot
angle_plots$coordinating_res_plot
plots <- angle_plots

# line below confirms this is a shit way to find distance
#angle_plots$min_dist_angles_plot #THIS USES DISTANCES FROM AXES PROTOCOL



# CACBFE angle plots --------------------------
# we have CACBFE_df
# only one figure to make we can do it here

CACBFE_plot <- ggplot(CACBFE_df, aes(x=Residue_Code,y=Angle,fill=Residue_Code)) +
   geom_violin(trim=FALSE) +
   labs(title = "Angles CA-CB-Fe per type of residue to Fe within pocket", x="Residue",y="Angle")
   #stat_summary(fun.data = mean_sdl, mult=1, geom="pointrange")
CACBFE_plot

# 
# nonpolar_plot <- ggplot(nonpolar_res_df,aes(x=Residue_Code,y=Distance, fill=Residue_Code)) +
#    geom_violin(trim=FALSE) +
#    labs(title = "Nonpolar Residues to Fe in each PDB - Mean+SD", x="Residue", y="Distance") +
#    stat_summary(fun.data = mean_sdl, mult =1,geom = "pointrange")
# # 


# EXPORTING ALL PLOTS, AS IN THE ORDER THEY APPEAR IN THE IDE TO THE RIGHT: ------------
# from: https://stackoverflow.com/questions/35321775/save-all-plots-already-present-in-the-panel-of-rstudio/53809715
# another solution that might preserve plot name: https://stackoverflow.com/questions/24182349/r-plot-saving-and-file-name
# 

# BIG NOTE: WAIT LIKE 30 SEC BEFORE RUNNING THIS CODE. IT SEEMS TO WAIT FOR STUFF
# TO PROPERLY LOAD AT THE PANEL ON THE RIGHT. IDK MAN.

plots.dir.path <- list.files(tempdir(), pattern="rs-graphics", full.names = TRUE);
plots.png.paths <- list.files(plots.dir.path, pattern=".png", full.names = TRUE)

file.copy(from=plots.png.paths, to="~/heme-binding/results/0_figures_and_tables/")

#ordering:
plots.png.details <- file.info(plots.png.paths)
plots.png.details <- plots.png.details[order(plots.png.details$mtime),]
sorted.png.names <- gsub(plots.dir.path, "~/heme-binding/results/0_figures_and_tables/", row.names(plots.png.details), fixed=TRUE)
numbered.png.names <- paste0("~/heme-binding/results/0_figures_and_tables/", 1:length(sorted.png.names), ".png")

# Rename all the .png files as: 1.png, 2.png, 3.png, and so on.
file.rename(from=sorted.png.names, to=numbered.png.names)

# for(i in 1:(length(plots)))
#    {
#    print(plots[[i]]) #<- ggplot() + geom_point(aes(x=runif(10), y=runif(10))))
#    #print(plots[[2]] <- ggplot() + geom_point(aes(x=runif(10), y=runif(10))))
#    #print(plots[[3]] <- ggplot() + geom_point(aes(x=runif(10), y=runif(10))))
# #    }
# invisible(
#    lapply(
#       seq_along(plots), 
#       function(x) ggsave(filename=paste0("myplot", x, ".png"), plot=plots[[x]])
#    ) )


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
