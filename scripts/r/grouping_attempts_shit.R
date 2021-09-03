print(ggplot(HEM_aaFreqDf,aes(x=Residue,y=as.numeric(as.character(Freq))) +
               geom_bar()#stat="identity",position='identity')
        labs(x = "Residue",y="Frequency", title = paste(activeLigand,": AA Frequency",sep=''))

        
        aa_freq_plot <- barplot(HEM_aaFreqDf$Freq,
                                main = "Frequency of Residues within 7A of Heme",
                                xlab = "Residues",
                                ylab = "Frequency",
                                col = "orange",
                                names.arg = aa_freq_df$Var1)
        activeLigand = "SRM"
        #paste(activeLigand,"_aaFreqDf$Freq",sep="")
        zx <- ggplot(eval(parse(text=paste(activeLigand,"_aaFreqDf",sep=""))),aes(x= reorder(Residue,-Freq),y=Freq))  +
                geom_bar(stat="identity",position = "identity", alpha=1) +
          labs(x = "Residue",y="Frequency", title = paste(activeLigand,": AA Frequency",sep='')) +
        print(zx)
        
        
        dat <- data.frame(value=runif(26)*10,
                         grouping=c(rep("Group 1",10),
                                    rep("Group 2",10),
                                    rep("Group 3",6)),
                         letters=LETTERS[1:26])
        
        head(dat)
        ggplot(dat, aes(letters,value, label = letters)) + 
          geom_bar(stat="identity") + 
          facet_wrap(~grouping, scales="free")
        ggplot(dat, aes(grouping, value, fill=letters, label = letters)) + 
          geom_bar(position="dodge", stat="identity") + 
          geom_text(position = position_dodge(width = 1), aes(x=grouping, y=0))

        ggplot(eval(parse(text=paste(activeLigand,"_aaFreqDf",sep=""))),aes(x= reorder(Residue,-Freq),y=Freq,fill=Residue))  +
          geom_bar(stat="identity",position = "identity", alpha=1) +
          labs(x = "Residue",y="Frequency", title = paste(activeLigand,": AA Frequency",sep='')) +
          facet_wrap(~Residue, scales = "free")

        ggplot(data=dat, aes(x=HUC_12_NAM, y=perc_veg, fill=variable)) + 
          geom_bar(stat='identity') +
          facet_grid(. ~ HUC_10_NAM, scales="free")        
                    