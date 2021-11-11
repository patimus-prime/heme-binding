# This is the main R file for this project. It was intended to launch other scripts used.
# However, I'm now crunched and would rather only hit one button to run everything.
# 22 August 2021 main.R for Pat's heme-binding project!
#
# So, it does the following:
# 0. Specify ligands and angstromDistance to be used
# 1. Launches all scripts to acquire the data from .txt result files
# 2. Merges those results and makes some stately dataframes
# 3. These dataframes are then plotted; this code may be copied into .Rmd files
# 4. As of 2 Nov 2021, requires saving data; hit save button to the right in Environment

# NOTE: I ADVISE READING THROUGH THIS, AND THEN VOLUME.R TO UNDERSTAND THE
# GENERAL IDEA OF HOW THIS CODE ALL WORKS TOGETHER.

# -------------------------------------------------------------
#  Packages used; and comments if kableExtra gives problems ---------------

#detach("package:reshape", unload=TRUE) #maybe avoid the problem anyway lol

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

#get 5A data real quick so we overwrite all DFs it uses, below:

source("~/heme-binding/scripts/r/data5A.R") 
ls5A <- data5A_fn()
#print("the pdbs shouldnt be printed yet")

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


# AA Frequency whole PDB -----------------
source("~/heme-binding/scripts/r/aa_frequency.R")
resultPath = "~/heme-binding/results/aa_freq_all/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   aa_freq_df <- aaFreq_fn(activeLigand,activeResultPath) #lol
   assign(paste(activeLigand,"_aaFreqAllDf",sep=""), aaFreq_fn(activeLigand,activeResultPath))
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
# FIXME: RENAME THE SCRIPT INVOLVED BELOW, DIST_ANGLES.R -> PLANAR.R
source("~/heme-binding/scripts/r/dist_angles.R")
resultPath = "~/heme-binding/results/distances_and_angles/"

for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   activeResultPath = paste(resultPath,activeLigand,sep = "")
   planar_angles_df <- aaAnglesFn(activeLigand,activeResultPath)
   assign(paste(activeLigand,"_planar_angles_DF",sep=""),planar_angles_df)
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
   
   ##### DECLARE REPORTED DFs -- too large of a DF for output to PDF ###
   p1DF <- mergedDF #just codes and source orgs, done
   p2DF <- eval(parse(text = paste(activeLigand,"_pdbCodesDf$PDB_ID",sep = "")))
   p2DF <- as.data.frame(p2DF)
   p2DF %>% 
      dplyr::rename(PDB_ID = p2DF) -> p2DF #takes care of how R names stuff by default
   
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
      dplyr::rename(
         Molecule_Name = 'Molecule Name'
      ) -> p1DF
   
   p2DF %>%
      dplyr::rename(
         Volume_Data = volume_data
      ) -> p2DF
   
   assign(paste(activeLigand,"_MERGED_DF",sep = ""),mergedDF)
   assign(paste(activeLigand,"_p1DF",sep = ""),p1DF) #this gets printed in LaTeX, merged v big
   assign(paste(activeLigand,"_p2DF",sep = ""),p2DF) #this gets printed in LaTeX, merged v big
  
}

# merging VER/VEA --------
VEA_MERGED_DF %>%
   dplyr::rename(
      VXX_Excluded_SA = VEA_Excluded_SA,
      VXX_Accessible_SA = VEA_Accessible_SA
   ) -> VEA_MERGED_DF

VER_MERGED_DF %>%
   dplyr::rename(
      VXX_Excluded_SA = VER_Excluded_SA,
      VXX_Accessible_SA = VER_Accessible_SA
   ) -> VER_MERGED_DF

VERDOHEME_MERGED_DF <- rbind(VEA_MERGED_DF,VER_MERGED_DF)

VERDOHEME_MERGED_DF %>%
   dplyr::rename(
      VERDOHEME_Excluded_SA = VXX_Excluded_SA,
      VERDOHEME_Accessible_SA = VXX_Accessible_SA
   ) -> VERDOHEME_MERGED_DF

# angle stuff merging:
VERDOHEME_CACBFe_DF <- rbind(VEA_CACBFe_DF,VER_CACBFe_DF)
VERDOHEME_planar_angles_DF <- rbind(VEA_planar_angles_DF,VER_planar_angles_DF)
VERDOHEME_distList <- list(
   "mean_distances" = rbind(VEA_distList$mean_distances,VER_distList$mean_distances),
   "closest3Res" = rbind(VEA_distList$closest3Res,VER_distList$closest3Res),
   "all_distances" = rbind(VEA_distList$all_distances,VER_distList$all_distances)
)

# === ALL OF THE BELOW JUST TO MERGE THESE TWO FOR AMINO ACID...

VERDOHEME_aaFreqDf <- rbind(VEA_aaFreqDf,VER_aaFreqDf)
VERDOHEME_aaFreqDf$Freq <- as.numeric(as.character(VERDOHEME_aaFreqDf$Freq))
VERDOHEME_aaFreqDf$Residue <- as.character(VERDOHEME_aaFreqDf$Residue)
verdotemp <- tapply(VERDOHEME_aaFreqDf$Freq,VERDOHEME_aaFreqDf$Residue,FUN=sum)
verdotemp <- as.data.frame(verdotemp)
VERDOHEME_aaFreqDf <- tibble::rownames_to_column(verdotemp, "Residue")
VERDOHEME_aaFreqDf %>%
   dplyr::rename(
      Freq = verdotemp
   ) -> VERDOHEME_aaFreqDf
#almost done, have to order it:
VERDOHEME_aaFreqDf <- arrange(VERDOHEME_aaFreqDf,desc(Freq))

### this for the all aa per pdb
VERDOHEME_aaFreqAllDf <- rbind(VEA_aaFreqAllDf,VER_aaFreqAllDf)
VERDOHEME_aaFreqAllDf$Freq <- as.numeric(as.character(VERDOHEME_aaFreqAllDf$Freq))
VERDOHEME_aaFreqAllDf$Residue <- as.character(VERDOHEME_aaFreqAllDf$Residue)
verdotemp <- tapply(VERDOHEME_aaFreqAllDf$Freq,VERDOHEME_aaFreqAllDf$Residue,FUN=sum)
verdotemp <- as.data.frame(verdotemp)
VERDOHEME_aaFreqAllDf <- tibble::rownames_to_column(verdotemp, "Residue")
VERDOHEME_aaFreqAllDf %>%
   dplyr::rename(
      Freq = verdotemp
   ) -> VERDOHEME_aaFreqAllDf
#almost done, have to order it:
VERDOHEME_aaFreqAllDf <- arrange(VERDOHEME_aaFreqAllDf,desc(Freq))


########################################
########################################
# BELOW IS OUTDATED AS OF 2 NOV 2021
# ALL GRAPHS WERE CONSTRUCTED IN .RMD,
# BUT THE BELOW CODE WAS USED AS REFERENCE.
# IT MAY STILL BE USED TO SEE MULTIPLE GRAPHS IMMEDIATELY
# BELOW IN THE BOTTOM RIGHT.
########################################
########################################


# 2.5) Distances stuff, merging the distances/angles DF's --------------------
   # for use below in plots

#nonpolar for sure
nonpolar_ref_ls <- c("LEU", "PHE", "ALA", "VAL", "ILE", "TYR", "GLY","GLX")
#polar... the rest. some very weakly polar and more just spicy
polar_ref_ls <- c("ARG","ASN","ASP","ASX","CYS","GLU","GLN","HIS","LYS",
                  "MET","PRO","SER","THR","TRP")


# INTERSECTING DISTANCES AND ANGLES --------------------
ligandList = list("HEM","HEC","SRM","VERDOHEME")
for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   # may need to set shit as factor etc.
   print(activeLigand)
   
   tmp_meanDist <- eval(parse(text = (paste(activeLigand,"_distList$mean_distances",sep=""))))
   tmp_CAB <-  eval(parse(text = (paste(activeLigand,"_CACBFe_DF",sep=""))))
   tmp_closest3 <-  eval(parse(text = (paste(activeLigand,"_distList$closest3Res",sep=""))))
   tmp_closest3
   HEM_distList$closest3Res
   HEC_distList$closest3Res
   # careful not to use accidentally use distance on the planar angles DF until we've removed it!
   tmp_planar <-  eval(parse(text = (paste(activeLigand,"_planar_angles_DF",sep=""))))
   print("tmps set")
   
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

# 3. Construct Plots/Graphs (NOTE: ligandList is altered here!!!) ----------------------------------



ligandList = list("HEM","HEC","SRM","VERDOHEME")
for(ligand in 1:(length(ligandList)))
{
   activeLigand = ligandList[[ligand]]
   
   # AA FReq ----
   zx <- ggplot(eval(parse(text=paste(activeLigand,"_aaFreqDf",sep=""))),aes(x= reorder(Residue,-Freq),y=Freq))  +
      geom_bar(stat="identity",position = "identity", alpha=1) +
      labs(x = "Residue",y="Frequency", title = paste(activeLigand,": AA Frequency at 7A",sep='')) 
   
   print(zx)
   
   
   # AA FReqAll ----
   zy <- ggplot(eval(parse(text=paste(activeLigand,"_aaFreqAllDf",sep=""))),aes(x= reorder(Residue,-Freq),y=Freq))  +
      geom_bar(stat="identity",position = "identity", alpha=0.65) +
      labs(x = "Residue",y="Frequency", title = paste(activeLigand,": AA Frequency of Monomer",sep='')) 
   
   print(zy)
   
   # AA Freq in pocket tbut with 5A and 7A overlaid
   rm(tmp5A,tmp7A,tmpBoth)
   head(HEM_aaFreqDf)
   tmp7A <- data.frame(df7A = eval(parse(text=(paste(activeLigand,"_aaFreqDf",sep="")))))
                          #HEM_aaFreqDf)
   tmp5A <- data.frame(df5A = eval(parse(text=(paste("ls5A$",activeLigand,"_5A_aaFreqDf",sep="")))))
   tmp7A$ang = '7'
   tmp5A$ang = '5'
   head(tmp7A)
   tmp7A
   tmp7A %>%
      dplyr::rename(
         df5A.Residue = df7A.Residue
      ) -> tmp7A
   merge(tmp5A,tmp7A,by = 'df5A.Residue') -> tmpBoth
   #alternative: left_join(tmp5A,tmp7A,by='df5A.Residue')
   tmpBoth %>%
      dplyr::rename(
         Residue = df5A.Residue
      ) -> tmpBoth
   tmpBoth
   
   library(reshape) #ONLY LOAD THIS HERE. IF YOU LOAD EALIER,
   # ALL CASE OF RENAME() FROM DPLYR PACKAGE IN ALL SCRIPTS GETS FUCKED UP.
   # PUTTING IT HERE, ONLY BELOW THIS LIBRARY LOAD DO YOU NEED NEED TO SPECIFY DPLYR::XXX
   
   to_plot <- reshape::melt((data.frame(x=tmpBoth$Residue,`Distance_5Å`=tmpBoth$df5A.Freq,`Distance_7Å`=tmpBoth$df7A.Freq)),id="x")
#   detach("package:reshape", unload=TRUE) #maybe avoid the problem anyway lol
   
   print(ggplot(to_plot,aes(x= reorder(x,-value),y=value,fill=variable)) + 
            geom_bar(stat="identity",position = "identity", alpha=.4) +
            labs(x = "Residue",y="Frequency", title = paste(activeLigand,": AA Frequency",sep='')) +
            scale_fill_discrete(name = "Distance Cutoff"))
   
   ### DISTANCES ####
   eval(parse(text=paste(activeLigand,"_distList$mean_distances",sep=""))) %>%
      dplyr::select(Residue_Code,Mean_Distance) -> tmpDist 
   
   distanceDist <- ggplot(tmpDist,aes(x=Residue_Code,y=(as.numeric(as.character(Mean_Distance))),fill=Residue_Code)) + 
      geom_violin(trim=FALSE) +
      labs(title = paste(activeLigand,": Distribution of Residues by Distance",sep=''), x="Residue",y="Distance (Å)")
   print(distanceDist)
   
   
   
   # ### VOLUME ####
   
   rm(tmp5A,tmp7A,tmpBoth)
   colName = 'volume_data'
   tmp7A <- data.frame(df7A = eval(parse(text=(paste(activeLigand,"_MERGED_DF$",colName,sep="")))))
   tmp5A <- data.frame(df5A = eval(parse(text=(paste("ls5A$",activeLigand,"_5A_MERGED_DF$",colName,sep="")))))
   tmp7A$Distance_Cutoff = '7Å'
   tmp5A$Distance_Cutoff = '5Å'
   tmp7A %>%
      dplyr::rename(
         df5A = df7A #hopefuly does not append, rm() should take care of that
      ) -> tmp7A
   tmpBoth <- rbind(tmp5A,tmp7A)
   print(
      ggplot(tmpBoth, aes(x=df5A,fill=Distance_Cutoff,color=)) +
         geom_histogram(position="identity",alpha=0.4)
      + labs(x="Volume (Å³)",y="Frequency",title = paste(activeLigand,": Volume (Å³)"))
   )
   
   # Ligand Excluded Surface Area 
   
   rm(tmp5A,tmp7A,tmpBoth)
   colName = paste(activeLigand,"_Excluded_SA",sep="")
   tmp7A <- data.frame(df7A = eval(parse(text=(paste(activeLigand,"_MERGED_DF$",colName,sep="")))))
   tmp5A <- data.frame(df5A = eval(parse(text=(paste("ls5A$",activeLigand,"_5A_MERGED_DF$",colName,sep="")))))
   tmp7A$Distance_Cutoff = '7Å'
   tmp5A$Distance_Cutoff = '5Å'
   tmp7A %>%
      dplyr::rename(
         df5A = df7A #hopefuly does not append, rm() should take care of that
      ) -> tmp7A
   tmpBoth <- rbind(tmp5A,tmp7A)
   print(
      ggplot(tmpBoth, aes(x=df5A,fill=Distance_Cutoff,color=)) +
         geom_histogram(position="identity",alpha=0.4)
      + labs(x="Surface Area (Å²)",y="Frequency",title = paste(activeLigand,": Ligand Excluded SA (Å²)"))
   )
   
   
   # Ligand Accessible Surface Area 
   
   rm(tmp5A,tmp7A,tmpBoth)
   colName = paste(activeLigand,"_Accessible_SA",sep="")
   tmp7A <- data.frame(df7A = eval(parse(text=(paste(activeLigand,"_MERGED_DF$",colName,sep="")))))
   tmp5A <- data.frame(df5A = eval(parse(text=(paste("ls5A$",activeLigand,"_5A_MERGED_DF$",colName,sep="")))))
   tmp7A$Distance_Cutoff = '7Å'
   tmp5A$Distance_Cutoff = '5Å'
   tmp7A %>%
      dplyr::rename(
         df5A = df7A #hopefuly does not append, rm() should take care of that
      ) -> tmp7A
   tmpBoth <- rbind(tmp5A,tmp7A)
   print(
      ggplot(tmpBoth, aes(x=df5A,fill=Distance_Cutoff,color=)) +
         geom_histogram(position="identity",alpha=0.4)
      + labs(x="Surface Area (Å²)",y="Frequency",title = paste(activeLigand,": Ligand Accessible SA (Å²)"))
   )
   
   # Pocket Excluded SA
    
   rm(tmp5A,tmp7A,tmpBoth)
   colName = "Pocket_Excluded_SA"
   tmp7A <- data.frame(df7A = eval(parse(text=(paste(activeLigand,"_MERGED_DF$",colName,sep="")))))
   tmp5A <- data.frame(df5A = eval(parse(text=(paste("ls5A$",activeLigand,"_5A_MERGED_DF$",colName,sep="")))))
   tmp7A$Distance_Cutoff = '7Å'
   tmp5A$Distance_Cutoff = '5Å'
   tmp7A %>%
      dplyr::rename(
         df5A = df7A #hopefuly does not append, rm() should take care of that
      ) -> tmp7A
   tmpBoth <- rbind(tmp5A,tmp7A)
   print(
      ggplot(tmpBoth, aes(x=df5A,fill=Distance_Cutoff,color=)) +
         geom_histogram(position="identity",alpha=0.4)
      + labs(x="Surface Area Å²",y="Frequency",title = paste(activeLigand,": Pocket Excluded SA (Å²)"))
   )
   
   
   # Pocket Acessible histo
   rm(tmp5A,tmp7A,tmpBoth)
   colName = "Pocket_Accessible_SA"
   tmp7A <- data.frame(df7A = eval(parse(text=(paste(activeLigand,"_MERGED_DF$",colName,sep="")))))
   tmp5A <- data.frame(df5A = eval(parse(text=(paste("ls5A$",activeLigand,"_5A_MERGED_DF$",colName,sep="")))))
   tmp7A$Distance_Cutoff = '7Å'
   tmp5A$Distance_Cutoff = '5Å'
   tmp7A %>%
      dplyr::rename(
         df5A = df7A #hopefuly does not append, rm() should take care of that
      ) -> tmp7A
   tmpBoth <- rbind(tmp5A,tmp7A)
   print(
      ggplot(tmpBoth, aes(x=df5A,fill=Distance_Cutoff,color=)) +
         geom_histogram(position="identity",alpha=0.4)
      + labs(title = paste(activeLigand,"Pocket Acessible SA (Å²)"))
   )
   
   
# plots of intersected distances with...
   
   # all planar angles   
   # yeah keep the as.numeric(as.character),easiest way to solve the problem
   planarAllPlot <- ggplot(eval(parse(text=paste(activeLigand,"_allDistPlanarDf",sep=''))),
                           aes(x=Residue_Code.x,y=as.numeric(as.character(Angle)),fill=Residue_Code.x)) +   
      geom_violin(trim=FALSE) +
      labs(title = paste(activeLigand,": All Planar Angles",sep=''), x="Residue",y="Angle")
   print(planarAllPlot)
   
   # closest residues' planar angles
   planarMinPlot <- ggplot(eval(parse(text=paste(activeLigand,"_minDistPlanarDf",sep=''))),
                           aes(x=Residue_Code.x,y=as.numeric(as.character(Angle)),fill=Residue_Code.x)) +
      geom_violin(trim = FALSE) +
      labs(title = paste(activeLigand,": Planar Angles of Closest Residues",sep = ''),x="Residue",y="Angle")
   print(planarMinPlot)
   
   # all cabs with distance intersect
   cabAllPlot <- ggplot(eval(parse(text=paste(activeLigand,"_allDistCabDf",sep=''))),
                        aes(x=Residue_Code.x,y=as.numeric(as.character(Angle)),fill=Residue_Code.x)) +   
      geom_violin(trim=FALSE) +
      labs(title = paste(activeLigand,": All CA-CB-Fe Angles",sep=''), x="Residue",y="Angle")
   print(cabAllPlot)
   
   # cabs for closest 3 residues
   cabMinPlot <- ggplot(eval(parse(text=paste(activeLigand,"_minDistCabDf",sep=''))),
                        aes(x=Residue_Code.x,y=as.numeric(as.character(Angle)),fill=Residue_Code.x)) +   
      geom_violin(trim=FALSE) +
      labs(title = paste(activeLigand,": CA-CB-Fe Angles of Closest Residues",sep=''), x="Residue",y="Angle")
   print(cabMinPlot)
   
   
   }



# 4. Create VERDOHEME PRESENTABLE TABLES

#dealing with verdoheme
v1df <- VERDOHEME_MERGED_DF$PDB_ID
v1df <- cbind(v1df,VERDOHEME_MERGED_DF$`Molecule Name`)
v1df <- cbind(v1df,VERDOHEME_MERGED_DF$Source_Organism)
v1df <- as.data.frame(v1df)
v1df %>% 
   dplyr::rename(
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
   dplyr::rename(
      PDB_ID = v2df,
      Volume_Data = V2,
      VERDOHEME_EXCLUDED_SA = V3,
      VERDOHEME_ACCESSIBLE_SA = V4,
      POCKET_EXCLUDED_SA = V5,
      POCKET_ACCESSIBLE_SA = V6
   ) -> v2df

VERDOHEME_p1DF <- v1df
VERDOHEME_p2DF <- v2df



########################################
########################################
# BELOW IS SOME CODE IF YOU REALLY, REALLY
# WANT TO EXPORT TO LATEX. BUT DON'T DO THAT.
# LEARN AND USE RMARKDOWN (.RMD)
# DO NOT, DO NOT USE LATEX. LEARN .RMD
# IT WILL SAVE YOU SOOOOOOOOOOOOOOO MUCH TIME.
# LOOK UP 'BOOKDOWN' OR 'THESISDOWN' TO GET STARTED
#
# USE LATEX FOR A RESUME/CV THO, SO MUCH EASIER
#
# SERIOUSLY DO NOT DO NOT DO NOT USE LATEX FOR THIS
########################################
########################################

## EXPORT TO LATEX ---------------------
##

# splitting shit up worked!!!
# irrelevant as of discovery of Rmd
# 

#FIXME!!! GOOD KNITR/KABLE OPTIONS HERE HOMIE
# rownames(HEM_coord_Res_df) <- NULL
# omg <- kable(HEM_coord_Res_df, longtable = T, booktabs = T, caption = "perhaps","latex") %>%
#    kable_styling(full_width = T, latex_options = c("striped","repeat_header"))
# write_clip(as.character(omg))


# volume_data_df$volume_data <- as.numeric(as.character(volume_data_df$volume_data))
# # therefore, below code filters >50, conv back to df, filter <= 1000, conv back to df
# volume_data_df <- volume_data_df[volume_data_df$volume_data >= 50, ]
# volume_data_df <- as.data.frame(volume_data_df)
# 

