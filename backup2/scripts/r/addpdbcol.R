# this is a function to add the PDB code to a column of a dataframe.
# returns a list of df that's been altered. Use x <- func(x) when invoking

#https://stackoverflow.com/questions/19460120/looping-through-list-of-data-frames-in-r

# NOTE!! FOR BELOW FOR LOOP, INDEXES IN R START AT 1


addpdbcol <- function(listofdf) 
{
  for(i in 1:(length(listofdf)))
  {
    # we're now in per DF. so...
    # 1. Find line with the PDB code
    listofdf[[i]] %>%
      filter(grepl('opened', V1)) -> line_w_code #'opened' can also be used
    #changed to 'opened' as weird things can happen in 2nd line if something is slightly off/monomer algorithm fucks it
    
    # 2. Get that code
    # line_w_code is correctly identified, but is a df right now.
    
    # change to str
    str_w_code <- sapply(line_w_code, as.character)
    
    # pull only the code from the str
    the_code <- substr(str_w_code, start = 1, stop = 4)

    # 3. Create a new column populated only with the PDB code
    temp_df <- listofdf[[i]] # use temp_df to properly use index
    temp_df['PDB_ID'] = the_code
    temp_df <- temp_df %>%
      select(PDB_ID, everything()) #place the pdb col as first col
    listofdf[[i]] <- temp_df
  } 
  return(listofdf)
}
