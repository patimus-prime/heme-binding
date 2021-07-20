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

########################
# Ctrl+F "pause" to pause each mol in Chimera to visually examine!!
########################


#######
# this script so far, 2 June 2021, prints the volume of pockets detected
# within x Angstroms from heme molecules. also prints the residues WITHIN
# the x Angstroms of the heme molecules
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
    rc("del ions")


    # conduct analysis below ----------------------------

    # select residues within x Angstroms from the heme molecules

    #for an unclear reeason this does not transfer to the below to print only selected residues
    # 7A selected in order to accomodate for all potential chemical interactions with heme
    # this is potentially inaccurate, but a more case-specific A-distance study can be conducted in not a Master's

    # OK NOW GO TO GET THE VOLUME.
    # Select the atoms within 7A of heme. Then, of that selection, keep everything but heme.
    rc("sel :HEM za < 7.0")
    rc("sel sel &~:HEM")
    # weird way to specify heme and vol around heme without selecting heme
    interface_surfnet("sel","sel")
    # ADD AFTER FINAL "SEL" TO PUT IN SOME SETTINGS: ,cutoff=12.0,interval = 0.5)
    # split the surfaces, FIXME! not sure why actually 6 June 2021
    rc("sop split #")
    rc("measure volume #") #same result # or #1
    # the # sign specifies all applicable surfaces.

    rc("center")
    # now save an image of our surfnet calculation, this is how:
    #copy png file ~/bullshit.png #only change "bullshit"
    #rc("pause")


    # specifying path to the results folder!
    results_path = "~/heme-binding/results/volume"
    full_results_path = os.path.expanduser(results_path)

    # this looks funky but it' just within results_path, with processed_file.txt being saved
    saveReplyLog((full_results_path + "/%s") %(fn + ".processed.txt"))
    
    rc(("copy png file " + full_results_path + "/%s") %(fn+".pocketimage.png"))
    #close current file, avoid extreme memory use
    rc("close all")

# exit Chimera when the script is done
rc("stop now")

# if you add #x where x is a number, you specify a surface # or range of #s.


# ------------ STUFF THAT DIDN'T WORK:
#saveReplyLog("home/0_Pat_Project/test_folder/results/%s") %(fn...)

#home = expanduser("~")
