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
import re #necessary to strip down to only residue number
#######
# 16 July 2021: Acquire distances, and the angles between 1) Ca,Cb, and Fe;
# 2) the angle between a plane at HEM, and axes roughly representing the orientation
# of the residues with 7A of HEM. So, 3 data streams here. May be necessary
# to separate out the script later for easier parsing. But this is the attempt now
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
    rc("del solvent")
    rc("del ions") #this WILL fuck up if you get a chlorine or something as a 'residue'

    # declare the plane at the heme. This will be referenced in for loop below
    rc("define plane number 1 :HEM")

    currentResidue = -1 #this will throw an error if currentResidue # ever gets fucked below in another pdb
    # GET RESIDUES.
    HEMstr = "HEM"
    allResidueString = "ALA,ARG,ASN,ASP,ASX,CYS,GLU,GLN,GLX,GLY,HIS,ILE,LEU,LYS,MET,PHE,PRO,SER,THR,TRP,TYR,VAL"

    rc("sel :HEM zr < 7.0")

    for currentResidue in chimera.selection.currentResidues():
        #this will loop through all residues within 7A, so
        #currentResidue is some object type _molecule.Residue, so convert to string
        currentResidue = str(currentResidue)
        residueCode = currentResidue[0 : 3] #only first 3 of string
        print "currently processing residue..." + currentResidue
        print "stipped to only code..." + residueCode

        # don't compare heme to itself
        if HEMstr in currentResidue:
            print "Oops! HEM shouldn't be compared to itself, Do nothing."
        # don't process bullshit like NO2
        if residueCode in allResidueString:
            currentResidue = re.sub("[^0-9]","", currentResidue)

            print "stripped to only the number, this is residue " + currentResidue

            rc("define axis number " + currentResidue + " :" + currentResidue)

            rc("distance p1 a" + currentResidue)
            # we now have the plane p1 above defined, and now axis whatever
            rc("angle p1 a" + currentResidue) #in this way each time we get another residue we get its axis
            #NOTE: AXIS HAS NOTHING TO DO WITH... HMM. NOTE: AXIS NUMBER == RESIDUE NUMBER
        else:
            print "SHIT! Weird molecule, do nothing."

    rc("center")


    #rc("pause")


    # specifying path to the results folder!
    results_path = "~/heme-binding/results/distances_and_angles"
    full_results_path = os.path.expanduser(results_path)

    # this looks funky but it' just within results_path, with processed_file.txt being saved
    saveReplyLog((full_results_path + "/%s") %(fn + ".dist.angle.txt"))


    #close current file, avoid extreme memory use
    rc("close all")

# exit Chimera when the script is done
rc("stop now")
