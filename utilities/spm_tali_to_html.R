###
### Function to take 
###

# talairach = location of a .txt file from Tal Client output
# spm = location of a .csv from the SPM output 
# name = character; descriptive name of contrast

create_pet_table <- function(talairach = "~/Desktop/tali_coords.td.txt",spm = "~/Desktop/spm_tali.txt", name) {
  library(tidyverse)
  library(xtable)
  
  # Output from SPM
  s <- read.table(spm, sep = ',', header = T, skip = 1) %>%
       .[,-ncol(.)] %>%
       select(equivk,X_Tal, Y_Tal, Z_Tal,equivZ) %>%
       filter(is.na(X_Tal) == F)
  
  # Output from Talairach Client
  t <- read.table(talairach, sep = "\t", header = T) %>%
       .[,-c(1,8,10,11)] %>%
       mutate(Level.1 = substr(Level.1,1,1),
              Brodmann_Area = str_replace(Level.5,"Brodmann area ",""),
              Area = paste(Level.1, Level.2, Level.3, sep = ", ")) %>%
       select(-Level.1, -Level.2, -Level.3,-Level.5)
  
  df <- cbind(s,t) %>%
        select(equivk,Area,Brodmann_Area,X_Tal,Y_Tal,Z_Tal,equivZ)
  
  colnames(df) <-c("Voxel Number" ,"Brain Regions", "Brodmann Area", "X", "Y", "Z", "Z Score")
  
  ### Exporting as HTML for pasting into word
  xt <- xtable(df)
  print.xtable(xt, 
               type="html", 
               file = paste("~/Desktop/",name,".html", sep = ""), include.rownames = F)
  
}
