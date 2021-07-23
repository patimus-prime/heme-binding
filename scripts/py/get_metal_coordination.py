import os #necessary to define file path
import os.path #this is necessary to overcome python not recognizing ~
import chimera
from chimera import selection
from chimera import runCommand as rc
from Surfnet import interface_surfnet
from HideDust import show_only_largest_blobs
from chimera.tkgui import saveReplyLog # to save the results, which also appear in IDLE
from chimera import replyobj # gives status messages
from chimera import dialogs # LOL the reply log keeps spilling over
from MetalGeom.gui import MetalsDialog # to get metal coordination
dlg = dialogs.find(MetalsDialog.name, create=True)
metals = dlg.metalsMenu.valueMap.keys()
#for i in metals:
    #print i
#should output one HEME, if you desire to check.

#######
# 13 July 2021: Print a list of all residues within 7A of heme molecules.
# 7A is some cutoff for potential interactions with the heme. Not necessarily reflective
# of the chemistry in each molecule. Further refinement may be desirable depending on investigation.
######

#####
# you likely need to first change the names of the files downloaded, and also unpack them, use these two commands
# applicable for .ent.gz downloads, use both lines:
# if just .gz due to batch download script, just use the next line:
#
# gunzip *
# rename 's/.ent$/.pdb/' *.ent #this changes file extension. it requires rename to be installed, linux will let you know
#####


# CHANGE to folder with data files
# the path immediately below is set so as to conform with python's path-ing
# from: https://www.geeksforgeeks.org/python-os-path-expanduser-method/

replyDialog = dialogs.find("reply")
replyDialog.Clear()

# specifying path:
path = "~/heme-binding/pdb_source_data/1_monomers_processed"
full_path = os.path.expanduser(path)

# :'( you may also be able to use "home/pat/0_Pat_Project/test_folder"

# actually changing to path:
os.chdir(full_path)

# gather the names of .pdb files in the folder (UNPACK/RENAME IF STILL .GZ)
file_names = [fn for fn in os.listdir(".") if fn.endswith(".pdb")]

# loop through the files, opening, processing, and closing each in turn
for fn in file_names:
    replyDialog = dialogs.find("reply")
    replyDialog.Clear()
    replyobj.status("Processing " + fn) # show what file we're working on
    rc("open " + fn)

    # remove stuff that can affect results
    #rc("del solvent")
    #rc("del ions")

    # GET RESIDUES.
    #rc("sel :HEM zr < 7.0")
    #for i in chimera.selection.currentResidues():
    #    print i
    print "This is the metal(s) present in this file..."
    for i in metals:
        print i
    #should output one Fe belonging to heme, if you desire to check.

    coordinatingAtoms = dlg.coordinationTable.data
    print "These are the coordinating residues in the file..."
    for j in coordinatingAtoms:
        print j
    # should output everything coordinating Fe.
    #this includes stuff within the porphyrin ring,
    # and then the coordinating residues.
    # so in R, filter everything NOT 'HEM' out as coordinating residue
    rc("center")



    #rc("pause")


    # specifying path to the results folder!
    results_path = "~/heme-binding/results/metalCoordination"
    full_results_path = os.path.expanduser(results_path)

    # this looks funky but it' just within results_path, with processed_file.txt being saved
    saveReplyLog((full_results_path + "/%s") %(fn + ".processed.metals.txt"))


    #close current file, avoid extreme memory use
    rc("close all")

# exit Chimera when the script is done
rc("stop now")
