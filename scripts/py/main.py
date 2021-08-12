# main.py
import os
import os.path

# import FILENAME, this requires referncing fn's as FILENAME.fn()
# from FILENAME import *, this refernces fn's as fn()
# therefore we require to alter the scripts to be functions. let's get current functionality first.

# we'll use wildcard import here, as it is one function per script/module, not much confusion atm.
from convert_multi_to_mono import *
from calc_volume import *
#import calc_residues...


# where the data is, folder containing all ligand/PDBs
#sourcePath = "~/heme-binding/pdb_source_data/"
#sourcePath = os.path.expanduser(sourcePath)
#resultPath = "~/heme-binding/results/"
#resultPath = os.path.expanduser(resultPath)

# specify the desired ligands below:
ligandList = [
    "HEM"
]
#"HEM"#,HEC,SRM,VER,VEA"
# desired distance from Fe to examine:
angstromDistance = 5.0

# begin calling scripts, likely one loop per script:

###### VOL #######
#sourcePath = "~/heme-binding/pdb_source_data/1_monomers_processed/"
#resultPath = "~/heme-binding/results/volume/"

for activeLigand in ligandList:
    activeSourcePath = os.path.expanduser(sourcePath + activeLigand)
    activeResultPath = os.path.expanduser(resultPath + activeLigand)
    #activeSourcePath = os.path.expanduser("~/heme-bining/pdb_source_data/1_monomers_processed/HEM/")
    #activeResultPath = os.path.expanduser("~/heme-binding/results/volume/HEM/")
    #activeSourcePath = "home/pat/heme-bining/pdb_source_data/1_monomers_processed/HEM/"
    #activeResultPath = "home/pat/heme-binding/results/volume/HEM/"
    calculate_volume(activeLigand,activeSourcePath,activeResultPath)
