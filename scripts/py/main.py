# main.py
import os
import os.path

# import FILENAME, this requires referncing fn's as FILENAME.fn()
# from FILENAME import *, this refernces fn's as fn()
# therefore we require to alter the scripts to be functions. let's get current functionality first.

# ligandList = "HEM,HEC,SRM,VER,VEA:"
# angstromDistance =
# sourcePath =

import convert_multi_to_mono
import calc_volume
#import calc_residues...


sourcePath = "~/heme-binding/pdb_source_data/0_raw_download"
sourcePath = os.path.expanduser(sourcePath)



# specify the desired ligands below:
