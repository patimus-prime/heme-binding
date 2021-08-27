data5A_fn <- function() {

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
angstromDistance = 5.0 # used in figure naming but not much else


# 1. LAUNCH SCRIPTS, ACQUIRE DATA --------------------------
# Volume ---------
source("~/heme-binding/scripts/r/volume.R")
resultPath = "~/heme-binding/results/volume/5A/"
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
resultPath = "~/heme-binding/results/aa_frequency/5A/"

for(ligand in 1:(length(ligandList)))
{
  activeLigand = ligandList[[ligand]]
  activeResultPath = paste(resultPath,activeLigand,sep = "")
  aa_freq_df <- aaFreq_fn(activeLigand,activeResultPath)
  assign(paste(activeLigand,"_aaFreqDf",sep=""), aaFreq_fn(activeLigand,activeResultPath))
}

# Ligand surface area ----------------------
source("~/heme-binding/scripts/r/ligandSA.R")
resultPath = "~/heme-binding/results/ligandSA/5A/"

for(ligand in 1:(length(ligandList)))
{
  activeLigand = ligandList[[ligand]]
  activeResultPath = paste(resultPath,activeLigand,sep = "")
  ligandSA_df <- ligandSA_fn(activeLigand,activeResultPath)
  assign(paste(activeLigand,"_ligandSA_df",sep = ""), ligandSA_df)
}

# Pocket Surface Area ------------------------
source("~/heme-binding/scripts/r/pocketSA.R")
resultPath = "~/heme-binding/results/pocketSA/5A/"

for(ligand in 1:(length(ligandList)))
{
  activeLigand = ligandList[[ligand]]
  activeResultPath = paste(resultPath,activeLigand,sep = "")
  pocketSA_df <- pocketSA_fn(activeLigand,activeResultPath)
  assign(paste(activeLigand,"_pocketSA_df",sep = ""), pocketSA_df)
}

# FIXME! Maybe not FIXME. Just a note
# likely don't need to comment out below... just report what you want.
# slower, but avoid some errors if I comment shit out that shouldn't be


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


# now we have a lot of extra dataframes that already exist, which we will NOT
# be returning...

# this part I'm just going to hard code, which is sad, but I don't wanna fuck this up.
# just CTRL+F replace over HEM and do it for all portions of the list

# strucutre will be:
# list5A$HEM_xxx
# list5A$VERDOHEME_xxxxx 
# etc. so just one big ass list :)

ls5A <- list(
  "HEM_5A_aaFreqDf" = HEM_aaFreqDf,
  "HEM_5A_MERGED_DF" = HEM_MERGED_DF,
  
  "HEC_5A_aaFreqDf" = HEC_aaFreqDf,
  "HEC_5A_MERGED_DF" = HEC_MERGED_DF,
  
  "SRM_5A_aaFreqDf" = SRM_aaFreqDf,
  "SRM_5A_MERGED_DF" = SRM_MERGED_DF,
  
  "VERDOHEME_5A_aaFreqDf" = VERDOHEME_aaFreqDf,
  "VERDOHEME_5A_MERGED_DF" = VERDOHEME_MERGED_DF
)
return(ls5A)
}