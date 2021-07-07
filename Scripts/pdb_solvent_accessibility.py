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
path = "~/0_Pat_Project/test_folder/small_sample"
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

    # conduct analysis below

    # select residues within x Angstroms from the heme molecules

    #for an unclear reeason this does not transfer to the below to print only selected residues
    # 7A selected in order to accomodate for all potential chemical interactions with heme
    # this is potentially inaccurate, but a more case-specific A-distance study can be conducted in not a Master's
    #rc("sel :HEM zr <7.0")
    #for i in chimera.selection.currentResidues():
    #    print i

    # next 3 lines to print those residues within specified distance from heme
    # NOTE: JUST PRINTS RESIDUES WITHIN SPECIFIED VOL. NOT CLEAR WHERE THEY ARE/EXACT distance
    # if desired later, change zr < x and run again and again


    #heme_residues = chimera.selection.currentResidues()


    # select the residues around the heme but not the heme mols itself, some how also the volume
    #rc("sel sel &~:HEM")
    # weird way to specify heme and vol around heme without selecting heme
    #interface_surfnet("sel","sel")

    # split the surfaces, FIXME! not sure why actually 6 June 2021
    #rc("sop split #")
    #rc("measure volume #") #same result # or #1

    rc("del Fe")
    rc("surf :HEM")
    rc("center")
    rc("pause")
    # specifying path to the results folder!
    results_path = "~/0_Pat_Project/test_folder/turbo_results"
    full_results_path = os.path.expanduser(results_path)

    # this looks funky but it' just within results_path, with processed_file.txt being saved
    saveReplyLog((full_results_path + "/%s") %(fn + ".solventaccess.txt"))

    #close current file, avoid extreme memory use
    rc("close all")

# exit Chimera when the script is done
rc("stop now")




#this will need some work to organize the reply log
#but after we have this automated for more molecules

# the # sign specifies all applicable surfaces.
# if you add #x where x is a number, you specify a surface # or range of #s.


# ------------ STUFF THAT DIDN'T WORK:
#saveReplyLog("home/0_Pat_Project/test_folder/results/%s") %(fn...)

#home = expanduser("~")
