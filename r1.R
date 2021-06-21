library(dplyr) 
library(data.table)
library(tidyr)


#############################
# It is now uh, appropriate-seeming to add in a table of contents.
# So, by header in this code we have:
# 0. Notes on global variables that must be altered for this code to run properly
# 1. Assemble all lines/results from the result log from Chimera into one data_frame
# 2. Volume results and cleaning code
# 3. Residue results and cleaning
# 4. Plotting
############################

# 0. Notes on global variables...---------------------------

#may need to specify this option every run/change for running ALL PROCESSED FILES
#options(max.print = 999999999999999999999) #or whatever number

# 1. Assembling all results into one dataframe -----------------------------

#set working directory to the folder w files!
test_path = "~/0_Pat_Project/test_folder/results" 
setwd(test_path)

# import all the shit that's been processed
# currently using results specific file, all of type .txt; therefore:
result_files_ls <- list.files(pattern = "*.txt")

# may need to add path = whatever from wd into the parentheses
# result_files_ls is now a list of all the fuckin txt files

# now read them from the list into a dataframe 
result_files_df <- lapply(result_files_ls, function(x) {read.delim(file = x, header = FALSE)})

#i think each file now has its own dataframe. now we combine them
combined_results_df <- do.call("rbind", lapply(result_files_df, as.data.frame))

# combined_results_df is now the final output of this section and the primary df

# 2. Volume Data ------------------------------------------


# this line splits the lines by delimiter "volume =" to create the volume_data_df
# NOTE!!! This removes some data for tracability if we want to look back at specific pockets. But this seems highly improbably desirable
combined_results_df %>%
  separate(V1, c(NA ,"volume_data"), "volume = ") -> volume_data_df

# remove the NA values from the dataframe (this is a result of rows that did not contain volume data)
volume_data_clean <- na.omit(volume_data_df)

# shit was imported from the text file as strings, convert to numbers
volume_data_df$volume_data <- as.numeric(as.character(volume_data_df$volume_data))

# achieved volume dataframe with just volume data


# 3. Residues Results ----------------------------------

# now split by " " to create a df we can use to count the residues present around hemes
combined_results_df %>%
  separate(V1, c("Residues",NA), " ") -> residues_data_df

# create a table of all occurrences of the residues (and some noise, which is removed in next lines)
residue_table_prelim <- table(unlist(residues_data_df))

# specify the residues, so we can filter the table just for this data. otherwise we retain noise and crap
residues_ref_ls <- c("ALA","ARG","ASN","ASP","ASX","CYS",
                     "GLU","GLN","GLX","GLY","HIS","ILE",
                     "LEU","LYS","MET","PHE","PRO","SER",
                     "THR","TRP","TYR","VAL")

# convert the table w occurrences into a dataframe, so we can perform cleaning and later plot
residue_table_prelim_df_w_crap <- as.data.frame(residue_table_prelim)

# remove all the noise, keep the residues
clean_tbl <- subset(residue_table_prelim_df_w_crap, Var1 %in% residues_ref_ls)
  

# 4. Plotting -------------------------

# VOLUME DATA PLOT! 
# this histogram shit doesn't work as well as it should
hist(volume_data_df$volume_data,
     main = "Distribution of Volume of Pockets",
     xlab = "Volume, A3",
     col="darkmagenta",
     xlim=c(0,5000),
     breaks = c(0,100,150,200,250,300,350,400,450,500,5000))

# RESIDUE FREQ PLOT!

# order data before we plot
clean_tbl <- clean_tbl[order(clean_tbl$Freq, decreasing = TRUE), ]

# this 100% works and plots everything
# NOTE: just zoom + maximize to see ALL NAMES
hist(clean_tbl$Freq)
barplot(clean_tbl$Freq,
        main = "Residue Freq around Hemes",
        xlab = "Residues",
        names.arg = clean_tbl$Var1)
