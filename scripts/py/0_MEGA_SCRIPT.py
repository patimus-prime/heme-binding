# main.py

import os
import os.path
import chimera
from chimera import selection
from chimera import runCommand as rc
# this script assumes file structure has already been set up
# if that's not the case... I'm not being paid for this, so that can be implemented after the master's

# NOTE: DO NOT USE WILDCART IMPORT IT FUCKS UP AND CALLS SOMEONE IN FUCKING TAZMANIA IDK WHAT SCRIPT
import settings
import convert_multi_to_mono
import calc_volume
import get_residues_within_xA
#import calc_only_distances #FIXME!! RENAME
import calc_distances
import calc_CA_CB_Fe_angle
#import calc_dist_angles #FIXME!! RENAME
#import angles_planar
import calc_planar_angles
import calc_SA_ligand
import calc_SA_pocket

# specify the desired ligands below:
# could also put this into the settings file with angstromDistance, but... later
# ligandList = [
#     "HEM"
# ]
ligandList = settings.setLigandList
#"HEM"#,HEC,SRM,VER,VEA"
# desired distance from Fe to examine:

#
# begin calling scripts, likely one loop per script:
# if it were in one big loop, failure/erratic behavior more difficult to diagnose
#
# NOTE ON BELOW, DO NOT MISS A / IN FILE LOCATION, MESSES UP THE SCRIPTS
# ALSO CHECK IF "RC"STOPNOW"" IS PRESENT/ACTIVE IN A SCRIPT IF STUFF STOPS/DOESNT EXECUTE

##### PRODUCE MONOMERS FROM SOURCE PDBS ######
sourcePath = "~/heme-binding/pdb_source_data/0_raw_download/"
resultPath = "~/heme-binding/pdb_source_data/1_monomers_processed/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    convert_multi_to_mono.multi_to_mono_fn(activeLigand,activeSourcePath,activeResultPath,resultPath)

##### CALCULATE VOLUME OF POCKETS #######
sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
resultPath = "~/heme-binding/results/volume/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    calc_volume.calculate_volume(activeLigand,activeSourcePath,activeResultPath)

#### GET RESIDUES WITHIN angstromDistance ##############
sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
resultPath = "~/heme-binding/results/aa_frequency/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    get_residues_within_xA.fn(activeLigand,activeSourcePath,activeResultPath)


#### CALCULATE CA-CB-FE ANGLEs ####################
sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
resultPath = "~/heme-binding/results/angles_CA_CB_Fe/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    calc_CA_CB_Fe_angle.ccf(activeLigand,activeSourcePath,activeResultPath)


##### CALCULATE HEME SA ######
sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
resultPath = "~/heme-binding/results/ligandSA/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    calc_SA_ligand.SA_ligand(activeLigand,activeSourcePath,activeResultPath)

##### CALCULATE POCKET SA #######
sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
resultPath = "~/heme-binding/results/pocketSA/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    calc_SA_pocket.SA_pocket(activeLigand,activeSourcePath,activeResultPath)

##### CALCULATE ANGLES WHOLE AA TO HEME PLANE #######
##### KEEP AT BOTTOM, TAKES FOREVER TO RUN #######
# sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
# resultPath = "~/heme-binding/results/distances_and_angles/"
#
# for activeLigand in ligandList:
#     activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
#     activeResultPath = os.path.expanduser(resultPath + activeLigand)
#     calc_planar_angles.angle_aa_ligand_plane(activeLigand,activeSourcePath,activeResultPath)

#rc("pause")
rc("stop now")
