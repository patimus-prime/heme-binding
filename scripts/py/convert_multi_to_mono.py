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

#NOTE FOR WHEN WRITING CODE: CTRL+SHIFT+P "WHITESPACE" to convert tabs to spaces and avoid horrror!!!!
# or ctrl + alt + ]

#########################
# 13 July 2021
# this shit right here automates trimming shit down to one chain, A. This has the danger of excluding other chains
# that may compose one subunit, if a subunit is made up of multiple chains.
##########################

replyDialog = dialogs.find("reply")
replyDialog.Clear()

# specifying path:
path = "~/heme-binding/pdb_source_data/0_raw_download"
full_path = os.path.expanduser(path)

# specifying path to the results folder!
monomers_path = "~/heme-binding/pdb_source_data/1_monomers_processed"
full_monomers_path = os.path.expanduser(monomers_path)

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

    # select chain A, a single unit
    rc("sel :.a")
    # select everything else
    rc("sel invert sel")
    # delete everything else besides that chain A
    rc("del sel")

    # done, we examine the result below, confirm there's a heme I guess:
    rc("center :HEM") #if there ain't no heme we got PROBLEMS
    # if this is in fact the case, go to reply log and remove that shit from the pdbs. Relaunch script


    #rc("pause")

    # now save the monomer:
    # this looks funky but it's just within results_path, with processed_file.txt being saved
    rc("write format pdb 0 ~/heme-binding/pdb_source_data/1_monomers_processed/%s" %(fn + ".mono.pdb"))
    # 0 for the model selected; it will be 0 if we close/reopen each time, not multiple pdbs open
    # the /%s shoold put out originalpdb.mono.pdb

    # e.g. with command line the following worked:
    # write format pdb 0 amazeballsturbo.pdb

    rc("close all")
rc("stop now")

# aight, now you may need to rename using what's in pdb volume script if necessar, or let's see if we can ignore funky ending
