def SA_pocket(activeLigand,activeSourcePath,activeResultPath,angstromDistance):
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
    import settings

    #######
    # 13 July 2021
    # Calculate the solvent accessibility/surface area of the pocket containing
    # heme. Note there's a column that gets put in due to the lack of a chemical
    # bond in this space. CASTp also does this and maybe it's sufficient for
    # our purposes but it seems scientifically shit. But it's a failure of the
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

        # conduct analysis below
        # remove stuff that can affect results
        rc("del solvent")
        rc("del ions")

        # select residues within x Angstroms from the heme molecules

        #for an unclear reeason this does not transfer to the below to print only selected residues
        # 7A selected in order to accomodate for all potential chemical interactions with heme
        # this is potentially inaccurate, but a more case-specific A-distance study can be conducted in not a Master's


        rc("sel :"+activeLigand+" za <"+angstromDistance)#7.0")
        rc("del :"+activeLigand)#HEM")
        rc("surf sel")
        rc("center")


        #rc("pause")


        # specifying path to the results folder!
        #results_path = "~/heme-binding/results/pocketSA"
        #full_results_path = os.path.expanduser(results_path)

        # this looks funky but it' just within results_path, with processed_file.txt being saved
        saveReplyLog((activeResultPath + "/%s") %(fn + ".pocketSA.txt"))
        rc(("copy png file " + activeResultPath + "/%s") %(fn+".surfpocket.png"))
        #close current file, avoid extreme memory use
        rc("close all")

    # exit Chimera when the script is done
    #rc("stop now")
