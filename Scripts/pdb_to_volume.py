import os #necessary to define file path
import os.path #this is necessary to overcome python not recognizing ~
from chimera import runCommand as rc
from Surfnet import interface_surfnet
from HideDust import show_only_largest_blobs
from chimera.tkgui import saveReplyLog # to save the results, which also appear in IDLE
from chimera import replyobj # gives status messages

#####
# you likely need to first change the names of the files downloaded, and also unpack them, use these two commands
# applicable for .ent.gz downloads
# gunzip *
# rename 's/.ent$/.pdb/' *.ent #this changes file extension. it requires rename to be installed, linux will let you know
#####


# CHANGE to folder with data files
# the path immediately below is set so as to conform with python's path-ing
# from: https://www.geeksforgeeks.org/python-os-path-expanduser-method/

# specifying path:
path = "~/0_Pat_Project/test_folder"
full_path = os.path.expanduser(path)

# :'( you may also be able to use "home/pat/0_Pat_Project/test_folder"

# actually changing to path:
os.chdir(full_path)

# gather the names of .pdb files in the folder (UNPACK/RENAME IF STILL .GZ)
file_names = [fn for fn in os.listdir(".") if fn.endswith(".pdb")]

# loop through the files, opening, processing, and closing each in turn
for fn in file_names:
	replyobj.status("Processing " + fn) # show what file we're working on
	rc("open " + fn)

	# conduct analysis
	rc("sel :HEM zr <7.0")
	rc("sel sel &~:HEM")
	interface_surfnet("sel","sel")

	# split the surfaces
	rc("sop split #")
	rc("measure volume #") #same result # or #1

	# specifying path to the results folder!
	results_path = "~/0_Pat_Project/test_folder/results"
	full_results_path = os.path.expanduser(results_path)

	# this looks funky but it' just within results_path/processed_file.txt being saved
	saveReplyLog((full_results_path + "/%s") %(fn + ".processed.txt"))

	#close current file, avoid extreme memory use
	rc("close all")

# uncommenting the line below will cause Chimera to exit when the script is done
rc("stop now")

#this will need some work to organize the reply log
#but after we have this automated for more molecules

# the # sign specifies all applicable surfaces.
# if you add #x where x is a number, you specify a surface # or range of #s.


# ------------ STUFF THAT DIDN'T WORK:
#saveReplyLog("home/0_Pat_Project/test_folder/results/%s") %(fn...)

#home = expanduser("~")