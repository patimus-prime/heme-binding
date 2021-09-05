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
import get_all_residues

# specify the desired ligands below:
# could also put this into the settings file with angstromDistance, but... later
# ligandList = [
#     "HEM"
# ]
ligandList = settings.setLigandList
#"HEM"#,HEC,SRM,VER,VEA"
# desired distance from Fe to examine:
angstromDistance = str(7.0) #changes after we run once for 7A


#
# begin calling scripts, likely one loop per script:
# if it were in one big loop, failure/erratic behavior more difficult to diagnose
#
# NOTE ON BELOW, DO NOT MISS A / IN FILE LOCATION, MESSES UP THE SCRIPTS
# ALSO CHECK IF "RC"STOPNOW"" IS PRESENT/ACTIVE IN A SCRIPT IF STUFF STOPS/DOESNT EXECUTE

#### get this shit I'm so done lol #####
sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
resultPath = "~/heme-binding/results/aa_freq_all/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    get_all_residues.fn(activeLigand,activeSourcePath,activeResultPath)
rc("stop now")
