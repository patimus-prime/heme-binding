# This is the main R file for this project. It was intended to launch other scripts used.
# However, I'm now crunched and would rather only hit one button to run everything.
# 22 August 2021 main.R for Pat's heme-binding project!
#
# So, it does the following:
# 0. Specify ligands and angstromDistance to be used
# 1. Launches all scripts to acquire the data from .txt result files
# 2. Merges those results and makes some stately dataframes
# 3. Constructs plots, which must be manually saved.
# 4. Outputs tables in latex format, which must be manually copied over.
   # This part might need to be done AFTER the graphs have been produced.
   # Therefore latex code is commented by default until needed
# might end up doing that part by itself
# -------------------------------------------------------------
#  Packages used; and comments if kableExtra gives problems ---------------
library(dplyr) 
library(data.table)
library(tidyr)
library(ggplot2) 
library(stringr)
library(knitr)
library(clipr) # Linux) sudo apt-get install xclip ... R)install.packages("clipr")  
source("~/heme-binding/scripts/r/addpdbcol.R")

# this last one was tricky, see comments underneath:
library(kableExtra) 
#install.packages("kableExtra")
# I had to download more stuff, in ubuntu terminal:
# sudo apt-get install libxml2-dev
# sudo apt-get install libssl-dev
# sudo apt-get install libcurl4-openssl-dev #not sure if competely necessary
# sudo apt-get install libfontconfig1-dev

# you could probably also tease out what you're missing from the error messages
# just keep trying to install kableExtra and download what you need, until it works

# DECLARATIONS --------------
# warning: ligandList is altered at the end of merging dataframes below
# this is because VER and VEA are merged to 'VERDOHEME'
ligandList = list("HEM","HEC","SRM","VER","VEA")
angstromDistance = 7.0 # used in figure naming but not much else


# 1. LAUNCH SCRIPTS, ACQUIRE DATA --------------------------
# Volume ---------
source("~/heme-binding/scripts/r/volume.R")
resultPath = "~/heme-binding/results/volume/"
for(ligand in 1:(length(ligandList)))
   {
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   
   volume_dfs <- volumeFn(activeLigand,activeResultPath)
   
   #this line is freaky fresh
   # paste() automates df name creation, second arg is the df assigned. BAM!
   assign(paste(activeLigand,"_maxVolDf",sep=""), volume_dfs$maxVolDf)
   }

# AA Frequency -----------------
source("~/heme-binding/scripts/r/aa_frequency.R")
resultPath = "~/heme-binding/results/aa_frequency/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   aa_freq_df <- aaFreq_fn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_aaFreqDf",sep=""), aaFreq_fn(activeLigand,activeResultPath))
}
   
# Ligand surface area ----------------------
source("~/heme-binding/scripts/r/ligandSA.R")
resultPath = "~/heme-binding/results/ligandSA/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   ligandSA_df <- ligandSA_fn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_ligandSA_df",sep = ""), ligandSA_df)
}

# Pocket Surface Area ------------------------
source("~/heme-binding/scripts/r/pocketSA.R")
resultPath = "~/heme-binding/results/pocketSA/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   pocketSA_df <- pocketSA_fn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_pocketSA_df",sep = ""), pocketSA_df)
}

# AA angles to ligand PLANE -------------
source("~/heme-binding/scripts/r/dist_angles.R")
resultPath = "~/heme-binding/results/distances_and_angles/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   planar_angles_df <- aaAnglesFn(activeLigand,activeResultPath)
   #assign(paste(activeLigand,"_planar_angles_list",sep = ""), planar_angles_list)
   assign(paste(activeLigand,"_planar_angles_DF",sep=""),planar_angles_df)
   #assign(paste(activeLigand,"_coord_Res_df",sep=""),planar_angles_list$coord_Res_df)
   #assign(paste(activeLigand,"_min_dist_df",sep=""),planar_angles_list$min_dist_df)
}

# Distances of AA atoms to Fe ------------------
source("~/heme-binding/scripts/r/only_distances.R")
resultPath = "~/heme-binding/results/only_distances/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   distancesList <- distancesFn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_distList",sep=""),distancesList)
}

#  Angles CACBFe -------------------------------
source("~/heme-binding/scripts/r/anglesCACBFE.R")
resultPath = "~/heme-binding/results/angles_CA_CB_Fe/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   CACBFE_df <- CACBFE_fn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_CACBFe_DF",sep = ""),CACBFE_df)
}

# PDBs titles codes ---------------
source("~/heme-binding/scripts/r/pdb_titles_codes.R") 
resultPath = "~/heme-binding/pdb_source_data/0_raw_download/"
for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   pdbCodeDf <- pdbTitlesCodesFn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_pdbCodesDf",sep=""),pdbCodeDf)
}

# PDB source organism ---------------------
source("~/heme-binding/scripts/r/source_organism.R")
resultPath = "~/heme-binding/pdb_source_data/0_raw_download/"
for(ligand in 1:(length(ligandList)))
{
   paste(activeLigand,"source org processing...")
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   sourceOrganismDf <- sourceOrganismFn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_sourceOrganismDf",sep=""),sourceOrganismDf)
}



# 2. Merge dataframes (includes VER/VEA merging) ------------

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   
   
   mergedDF <- merge(eval(parse(text = paste(activeLigand,"_pdbCodesDf",sep = ""))),
                eval(parse(text = paste(activeLigand,"_sourceOrganismDf",sep = ""))),
                by.x = "PDB_ID")
   ##### DECLARE REPORTED DFs ###
   p1DF <- mergedDF #just codes and source orgs, done
   p2DF <- eval(parse(text = paste(activeLigand,"_pdbCodesDf$PDB_ID",sep = "")))
   p2DF <- as.data.frame(p2DF)
   p2DF %>%
      rename(PDB_ID = p2DF) -> p2DF #takes care of how R names stuff by default
   
   # V
   mergedDF <- merge(mergedDF,
                     eval(parse(text = paste(activeLigand,"_maxVolDf",sep = ""))),
                     by.x= "PDB_ID")
   
   p2DF <- merge(p2DF,
                 eval(parse(text = paste(activeLigand,"_maxVolDf",sep = ""))),
                 by.x= "PDB_ID")
   # ligandSA
   
   mergedDF <- merge(mergedDF,
                     eval(parse(text = paste(activeLigand,"_ligandSA_df",sep = ""))),
                     by.x = "PDB_ID")
   p2DF <- merge(p2DF,
                 eval(parse(text = paste(activeLigand,"_ligandSA_df",sep = ""))),
                 by.x = "PDB_ID")
   #pocketSA
   
   mergedDF <- merge(mergedDF,
                     eval(parse(text = paste(activeLigand,"_pocketSA_df",sep = ""))),
                     by.x = "PDB_ID")
   p2DF <- merge(p2DF,
                 eval(parse(text = paste(activeLigand,"_pocketSA_df",sep = ""))),
                 by.x = "PDB_ID")

   # rename a little so we can be presentable, still avoid spaces no time for debugging
   p1DF %>%
      rename(
         Molecule_Name = 'Molecule Name'
      ) -> p1DF
   
   p2DF %>%
      rename(
         Volume_Data = volume_data
      ) -> p2DF
   
   assign(paste(activeLigand,"_MERGED_DF",sep = ""),mergedDF)
   assign(paste(activeLigand,"_p1DF",sep = ""),p1DF) #this gets printed in LaTeX, merged v big
   assign(paste(activeLigand,"_p2DF",sep = ""),p2DF) #this gets printed in LaTeX, merged v big
  
}

# merging VER/VEA --------
VEA_MERGED_DF %>%
   rename(
      VXX_Excluded_SA = VEA_Excluded_SA,
      VXX_Accessible_SA = VEA_Accessible_SA
   ) -> VEA_MERGED_DF

VER_MERGED_DF %>%
   rename(
      VXX_Excluded_SA = VER_Excluded_SA,
      VXX_Accessible_SA = VER_Accessible_SA
   ) -> VER_MERGED_DF

VERDOHEME_MERGED_DF <- rbind(VEA_MERGED_DF,VER_MERGED_DF)

VERDOHEME_MERGED_DF %>%
   rename(
      VERDOHEME_Excluded_SA = VXX_Excluded_SA,
      VERDOHEME_Accessible_SA = VXX_Accessible_SA
   ) -> VERDOHEME_MERGED_DF

# angle stuff:
VERDOHEME_CACBFe_DF <- rbind(VEA_CACBFe_DF,VER_CACBFe_DF)
VERDOHEME_planar_angles_DF <- rbind(VEA_planar_angles_DF,VER_planar_angles_DF)
VERDOHEME_distList <- list(
   "mean_distances" = rbind(VEA_distList$mean_distances,VER_distList$mean_distances),
   "closest3Res" = rbind(VEA_distList$closest3Res,VER_distList$closest3Res)
)
#VERDOHEME_distList$mean_distances
#VERDOHEME_coord_Res_df <- rbind(VEA_coord_Res_df,VER_coord_Res_df)
#VERDOHEME_min_dist_df <- rbind(VEA_min_dist_df, VER_min_dist_df)

# === ALL OF THE BELOW JUST TO MERGE THESE TWO FOR AMINO ACID...

VERDOHEME_aaFreqDf <- rbind(VEA_aaFreqDf,VER_aaFreqDf)
VERDOHEME_aaFreqDf$Freq <- as.numeric(as.character(VERDOHEME_aaFreqDf$Freq))
VERDOHEME_aaFreqDf$Residue <- as.character(VERDOHEME_aaFreqDf$Residue)
verdotemp <- tapply(VERDOHEME_aaFreqDf$Freq,VERDOHEME_aaFreqDf$Residue,FUN=sum)
verdotemp <- as.data.frame(verdotemp)
VERDOHEME_aaFreqDf <- tibble::rownames_to_column(verdotemp, "Residue")
VERDOHEME_aaFreqDf %>%
   rename(
      Freq = verdotemp
   ) -> VERDOHEME_aaFreqDf
#almost done, have to order it:
VERDOHEME_aaFreqDf <- arrange(VERDOHEME_aaFreqDf,desc(Freq))
# 2.5) Distances stuff, merging the distances/angles DF's --------------------
   # for use below in plots

#nonpolar for sure
nonpolar_ref_ls <- c("LEU", "PHE", "ALA", "VAL", "ILE", "TYR", "GLY","GLX")
#polar... the rest. some very weakly polar and more just spicy
polar_ref_ls <- c("ARG","ASN","ASP","ASX","CYS","GLU","GLN","HIS","LYS",
                  "MET","PRO","SER","THR","TRP")

# v <- as.data.frame(HEM_distList$mean_distances)
# w <- as.data.frame(HEM_distList$all_distances)
# w
# z <- v
ligandList = list("HEM","HEC","SRM","VERDOHEME")
for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   # may need to set shit as factor etc.
   #activeLigand = "HEM"
   print(activeLigand)
   #assign(paste(activeLigand,"_sourceOrganismDf",sep=""),sourceOrganismDf)
   #eval(parse(text=(paste(activeLigand,"_aaFreqDf$Freq",sep="")))),
   #activeLigand = "SRM"
   
   tmp_meanDist <- eval(parse(text = (paste(activeLigand,"_distList$mean_distances",sep=""))))
   tmp_CAB <-  eval(parse(text = (paste(activeLigand,"_CACBFe_DF",sep=""))))
   tmp_closest3 <-  eval(parse(text = (paste(activeLigand,"_distList$closest3Res",sep=""))))
   # careful not to use accidentally use distance on the planar angles DF until we've removed it!
   tmp_planar <-  eval(parse(text = (paste(activeLigand,"_planar_angles_DF",sep=""))))
   print("tmps set")
   #HEM_planar_angles_DF
   #    HEM_distList$closest3Res
   # HEM_CACBFe_DF
   # # w0 <- HEM_distList$all_distances
   # w1 <- HEM_distList$mean_distances
   # w2 <- HEM_CACBFe_DF
   #HEM_distList$closest3Res
   
   # use inner_join I think, I loooked through ?inner_join and see a way by mult vectors
   #tmp_meanDist
   print("start second temps")
   allDistCab <- inner_join(tmp_meanDist,tmp_CAB,by=c("PDB_ID","Residue_Number")) #keep = FALSE does squat here
   minDistCab <- inner_join(tmp_closest3,tmp_CAB,by=c("PDB_ID","Residue_Number"))
   allDistPlanar <- inner_join(tmp_meanDist,tmp_planar,by=c("PDB_ID","Residue_Number"))
   minDistPlanar <- inner_join(tmp_closest3,tmp_planar,by=c("PDB_ID","Residue_Number"))
   print("start assigns")
   assign(paste(activeLigand,"_allDistCabDf",sep=""),allDistCab)
   assign(paste(activeLigand,"_minDistCabDf",sep=""),minDistCab)
   assign(paste(activeLigand,"_allDistPlanarDf",sep = ""),allDistPlanar)
   assign(paste(activeLigand,"_minDistPlanarDf",sep = ""),minDistPlanar)
   print("fin")
   print(activeLigand)
   rm(tmp_CAB)
   rm(tmp_closest3)
   rm(tmp_meanDist)
   rm(tmp_planar)
}
#assign(paste(activeLigand,"_sourceOrganismDf",sep=""),sourceOrganismDf)

# DON'T USE BELOW JUST LEAVING SO YOU KNOW NOT TO USE THIS UNTIL WE DONE FAM....-----

# keep irrelevant, just need to drop one of the Residue_Code columns and rename
# 
# w3 <- merge(w1,w2,by.x = "Residue_Code")
# xboth = intersect(rownames(w1),rownames(w2)) #good, gets all common residue names I guess
# yy = cbind(w1[xboth,],w2[xboth,])
# yboth = rbin
# 
# InBoth = intersect(colnames(df1), colnames(df2))
# df3=rbind(df1[,InBoth], df2[,InBoth])
# df3
#   
#    mergedDF <- merge(eval(parse(text = paste(activeLigand,"_pdbCodesDf",sep = ""))),
#                      eval(parse(text = paste(activeLigand,"_sourceOrganismDf",sep = ""))),
#                      by.x = "PDB_ID")
#    



# 3. Construct Plots/Graphs (NOTE: ligandList is altered here!!!) ----------------------------------
ligandList = list("HEM","HEC","SRM","VERDOHEME")
for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   aafreqplot <- barplot(eval(parse(text=(paste(activeLigand,"_aaFreqDf$Freq",sep="")))),
                main = paste(activeLigand, ": Frequency of Residues within ",angstromDistance,"Å of ",activeLigand,sep = ""),
                xlab = "Residues",
                ylab = "Frequency",
                col = "orange",
                cex.names = 0.8, #to fit the screen of my poor laptop
                names.arg = 
                   eval(parse(text = (paste(activeLigand,"_aaFreqDf$Residue",sep="")))))

   #see this link for adding more stats: https://www.stattutorials.com/R/R_Describe_data2,%20Histograms.html
   
   volume_hist <- hist(eval(parse(text = paste(activeLigand,"_MERGED_DF$volume_data",sep = ""))),
                       main = paste(activeLigand,": Volume of Binding Pocket (Å³)", sep=""),
                       xlab = "Volume, Å³",
                       ylab = "Frequency",
                       col = "darkmagenta")
   
   LigExcSA <- hist(eval(parse(text = paste(activeLigand,"_MERGED_DF$",activeLigand,"_Excluded_SA",sep = ""))),
                    main = paste(activeLigand,": Excluded Surface Area of ",activeLigand," (Å²)",sep = ""),
                    xlab = "Excluded Surface Area, Å²",
                    col = "blue")
    
   LigAccSA <- hist(eval(parse(text = paste(activeLigand,"_MERGED_DF$",activeLigand,"_Accessible_SA",sep = ""))),
        main = paste(activeLigand,": Accessible Surface Area of ",activeLigand," (Å²)",sep = ""),
        xlab = "Accessible Surface Area, Å²",
        col = "lightblue")
   
   HEM_MERGED_DF$Pocket_Excluded_SA
   pocket_excSA <- hist(eval(parse(text = paste(activeLigand,"_MERGED_DF$","Pocket_Excluded_SA",sep = ""))),
        main = paste(activeLigand,": Pocket Excluded Surface Area (Å²)", sep=''),
        xlab = "Excluded Surface Area, Å²",
        col = "green"
        )
   
   pocket_accSA <- hist(eval(parse(text = paste(activeLigand,"_MERGED_DF$","Pocket_Accessible_SA",sep = ""))),
        main = paste(activeLigand, ": Pocket Accessible Surface Area (Å²)", sep = ''),
        xlab = "Accessible Surface Area, Å²",
        col = "lightgreen"
        )
   
   cabplot <- ggplot(eval(parse(text=paste(activeLigand,"_CACBFe_DF",sep=''))),
                       aes(x=Residue_Code,y=Angle,fill=Residue_Code)) +   geom_violin(trim=FALSE) +
      labs(title = paste(activeLigand,": Angles CA-CB-Fe per type of residue to Fe atom of ",activeLigand,sep=''), x="Residue",y="Angle")
   print(cabplot)
   
   # angleplot <- ggplot(eval(parse(text=paste(activeLigand,"_planar_angles_DF",sep=""))), aes(x=Residue_Code, y=Angle, fill = Residue_Code)) +
   #    geom_violin(trim=FALSE) +
   #    labs(title = paste(activeLigand,": Angles of Residues v. ",activeLigand," in each PDB",sep = ""), x="Residue",y="Angle")
   # print(angleplot)
   # 
# # coordinating residue declaration (maybe change by ligand) -------------------
#    coord_Res_ls <- c("CYS","HIS","TYR")
#    
#    tmp_coord_Res_df <- subset(eval(parse(text=paste(activeLigand,"_coord_Res_df",sep = ""))), Residue_Code %in% coord_Res_ls)
#    tmp_coord_Res_df
#    coord_angle_plot <- ggplot(tmp_coord_Res_df, aes(x=Residue_Code,y=Angle,fill=Residue_Code)) +
#       geom_violin(trim=FALSE) +
#       labs(title = paste(activeLigand,": Angles of Cys, His, Tyr Residues to ",activeLigand,"",sep=''),
#            x="Residue",y="Angle") +
#       stat_summary(fun.data = mean_sdl, mult =1,geom="pointrange")
#    print(coord_angle_plot)
#    
#    min_dist_angles_plot <- ggplot(eval(parse(text=paste(activeLigand,"_min_dist_df",sep=""))), aes(x=Residue_Code,y=Angle,fill=Residue_Code)) +
#       geom_violin(trim=FALSE) +
#       labs(title = paste(activeLigand, ": Angles of each PDB's closest residue to ",activeLigand,"", sep=''),
#            x = "Residue",y="Angle") +
#       stat_summary(fun.data = mean_sdl, mult=1,geom="pointrange")
#    print(min_dist_angles_plot)
#    
   }



# 4. Export to LaTeX --------------------------
# I guess highlight below and replace the ligand each time you run
#ligandList # to check what to replace

# kable(HEM_aaFreqDf, booktabs = T) %>%
#    kable_styling(latex_options = "striped")
# 
# kbl(HEM_MERGED_DF, booktabs = T, "latex") %>%
#    kable_styling(latex_options = "striped")

#dealing with verdoheme
v1df <- VERDOHEME_MERGED_DF$PDB_ID
v1df <- cbind(v1df,VERDOHEME_MERGED_DF$`Molecule Name`)
v1df <- cbind(v1df,VERDOHEME_MERGED_DF$Source_Organism)
v1df <- as.data.frame(v1df)
v1df %>%
   rename(
      PDB_ID = v1df,
      Molecule_Name = V2,
      Source_Organism = V3
   ) -> v1df

v2df <- VERDOHEME_MERGED_DF$PDB_ID
v2df <- cbind(v2df,VERDOHEME_MERGED_DF$volume_data)
v2df <- cbind(v2df,VERDOHEME_MERGED_DF$VERDOHEME_Excluded_SA)
v2df <- cbind(v2df,VERDOHEME_MERGED_DF$VERDOHEME_Accessible_SA)
v2df <- cbind(v2df,VERDOHEME_MERGED_DF$Pocket_Excluded_SA)
v2df <- cbind(v2df,VERDOHEME_MERGED_DF$Pocket_Accessible_SA)
v2df <- as.data.frame(v2df)
v2df %>%
   rename(
      PDB_ID = v2df,
      Volume_Data = V2,
      VERDOHEME_EXCLUDED_SA = V3,
      VERDOHEME_ACCESSIBLE_SA = V4,
      POCKET_EXCLUDED_SA = V5,
      POCKET_ACCESSIBLE_SA = V6
   ) -> v2df

VERDOHEME_p1DF <- v1df
VERDOHEME_p2DF <- v2df

## EXPORT TO LATEX ---------------------
# splitting shit up worked!!!

rownames(HEM_coord_Res_df) <- NULL
omg <- kable(HEM_coord_Res_df, longtable = T, booktabs = T, caption = "perhaps","latex") %>%
   kable_styling(full_width = T, latex_options = c("striped","repeat_header"))
write_clip(as.character(omg))

# latex attempt to automate, not too much sense in it and doesn't seem to work...
# for(ligand in 1:(length(ligandList)))
# {
#    activeLigand = ligandList[[ligand]]
#    kable(eval(parse(text = (paste(activeLigand,"_aaFreqDf",sep="")))),
#          booktabs = T,
#          "latex") %>%
#       kable_styling(latex_options = "striped")
#   # aafreqplot <- barplot(eval(parse(text=(paste(activeLigand,"_aaFreqDf$Freq",sep="")))),
#                          
# }



# alternative solution to plot saving, but they look poor quality -----------

# # EXPORTING ALL PLOTS, AS IN THE ORDER THEY APPEAR IN THE IDE TO THE RIGHT:
# # from: https://stackoverflow.com/questions/35321775/save-all-plots-already-present-in-the-panel-of-rstudio/53809715
# # another solution that might preserve plot name: https://stackoverflow.com/questions/24182349/r-plot-saving-and-file-name
# # 
# 
# # BIG NOTE: WAIT LIKE 30 SEC BEFORE RUNNING THIS CODE. IT SEEMS TO WAIT FOR STUFF
# # TO PROPERLY LOAD AT THE PANEL ON THE RIGHT. IDK MAN.
# 
# plots.dir.path <- list.files(tempdir(), pattern="rs-graphics", full.names = TRUE);
# plots.png.paths <- list.files(plots.dir.path, pattern=".png", full.names = TRUE)
# 
# file.copy(from=plots.png.paths, to="~/heme-binding/results/0_figures_and_tables/")
# 
# #ordering:
# plots.png.details <- file.info(plots.png.paths)
# plots.png.details <- plots.png.details[order(plots.png.details$mtime),]
# sorted.png.names <- gsub(plots.dir.path, "~/heme-binding/results/0_figures_and_tables/", row.names(plots.png.details), fixed=TRUE)
# numbered.png.names <- paste0("~/heme-binding/results/0_figures_and_tables/", 1:length(sorted.png.names), ".png")
# 
# # Rename all the .png files as: 1.png, 2.png, 3.png, and so on.
# file.rename(from=sorted.png.names, to=numbered.png.names)
# 
# # for(i in 1:(length(plots)))
# #    {
# #    print(plots[[i]]) #<- ggplot() + geom_point(aes(x=runif(10), y=runif(10))))
# #    #print(plots[[2]] <- ggplot() + geom_point(aes(x=runif(10), y=runif(10))))
# #    #print(plots[[3]] <- ggplot() + geom_point(aes(x=runif(10), y=runif(10))))
# # #    }
# # invisible(
# #    lapply(
# #       seq_along(plots), 
# #       function(x) ggsave(filename=paste0("myplot", x, ".png"), plot=plots[[x]])
# #    ) )
# 
# 
# # TIDY UP! ------------------
# rm(result_files_df,
#    combined_results_df,
#    temp_df,
#    volume_data_clean,
#    no_quest,
#    line_w_code,
#    #clean_tbl,
#    residue_table_prelim,
#    result_files_df,
#    combined_results_df,
#    residue_table_prelim_df_w_crap,
#    residues_data_df,
#    #hemeSA_df,
#    #max_volume_df,
#    accessible_df,
#    excluded_df,
#    max_accessible_df,
#    max_excluded_df
# )
