def d(activeLigand,activeSourcePath,activeResultPath):
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
    from chimera import openModels, Molecule # for distance measurements
    import settings
    ############################################
    #
    # 21 July 2021:
    #
    # This script is to calculate the distances in a more accurate way than the
    # calc_dist_angles.py script, which relies upon effectively averaging up
    # the distances. We will conduct a more thorough examination of distances.
    # With, however, a great limitation: we will be getting, with the script
    # as of July 2021, only acquiring distances between Fe and atoms around it.
    # Ideally the distance to heme would be calculated, but this is quite
    # resource intensive and does not seem commensurate with a Master's
    #
    #
    ############################################

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
    #path = "~/heme-binding/pdb_source_data/1_monomers_processed"
    #full_path = os.path.expanduser(path)

    # :'( you may also be able to use "home/pat/0_Pat_Project/test_folder"

    # actually changing to path:
    os.chdir(activeSourcePath)

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

        ###############################################################
        # SELECT IRON ATOM WITHIN HEME, and WITHIN 7A from IRON #####

        rc("sel :"+activeLigand+"@Fe") #select the Fe atom. DO NOT del ions above.
        fe = chimera.selection.currentAtoms()[0] # index to acquire the one atom selected; manual sel defines a list

        rc("sel sel za < "+settings.angstromDistance)#7") # select all atoms within 5A of Fe (also de-selects Fe)
        nearbyAtoms = chimera.selection.currentAtoms()

        for i in nearbyAtoms:
            print "Atom being analyzed...", i, "... Distance to Fe...",i.coord().distance(fe.coord()) #prints distance between atom i and the Fe atom

        ################################################################
        # BELOW SEEMS TO AVERAGE OUT HEM POSITION. VERY POOR RESULTS.
        # # SELECT HEME, and WITHIN 5A from HEME. 7 too much. ######
        #
        # rc("sel :HEM")
        # hem = chimera.selection.currentAtoms()[0] #get heme selected
        # rc("sel sel za < 5")
        # nearbyAtoms = chimera.selection.currentAtoms()
        #
        # for i in nearbyAtoms:
        #     print "Atom being analyzed...", i, "... Distance to HEM...",i.coord().distance(hem.coord()) #prints distance between atom i and the Fe atom

        #############################################################

        rc("center")


        #rc("pause")


        # specifying path to the results folder!
        # change to .../test if.... testing
        #results_path = "~/heme-binding/results/only_distances"
        #full_results_path = os.path.expanduser(results_path)

        # this looks funky but it' just within results_path, with processed_file.txt being saved
        saveReplyLog((activeResultPath + "/%s") %(fn + ".only.dist.txt"))
        rc(("copy png file " + activeResultPath + "/%s") %(fn+".only.dist.image.png"))

        #close current file, avoid extreme memory use
        rc("close all")

    # exit Chimera when the script is done
    #rc("stop now")
