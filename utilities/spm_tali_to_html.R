###
### Function to take 
###

# talairach = location of a .txt file from Tal Client output
# spm = location of a .csv from the SPM output 
# name = character; descriptive name of contrast

create_pet_table <- function(data = "~/Desktop/DARPA_regression/pep_active_vNS_activation.txt") {
  library(tidyverse)
  library(xtable)
  
  # Output from SPM
  s <- read.table(data, sep = ',', skip = 1, header = T, fill = T) %>% 
       select(equivk,X_Tal, Y_Tal, Z_Tal,equivZ, X, X.1, X.2,X.4) %>%
       mutate(hemisphere = str_extract(X, "[RL]"),
              cerebellum_presence = str_detect(X, "Cerebellum"),
              hemisphere_lobe = ifelse(cerebellum_presence == TRUE, paste(hemisphere, "Cerebellum", sep = " "),
                                       ifelse(str_detect(X.1, "Sub-lobar") & str_detect(X.4, "[:punct:]"), paste(hemisphere, X.2, sep = " "),
                                                         ifelse(str_detect(X.1, "Sub-lobar") & !str_detect(X.4, "[:punct:]"), paste(hemisphere, X.2, sep = " "),
                                                                paste(hemisphere, X.1, sep = " ")))),
              Brodmann_Area = str_replace_all(X.4, "[^[:digit:]]",""),
              X.2 = str_replace(X.2, "Frontal|Parietal|Temporal|Occipital", ""),
              Area = ifelse(cerebellum_presence == T | str_detect(X.1, "Sub-lobar"), hemisphere_lobe,
                            paste(hemisphere_lobe, X.2, sep = ", "))) %>%
      select(-X, -X.1, -X.2, -X.4, -hemisphere, -cerebellum_presence, -hemisphere_lobe)
            
  # rearranging order for table
  df <- s %>%
        select(equivk,Area,Brodmann_Area,X_Tal,Y_Tal,Z_Tal,equivZ)
  
  colnames(df) <-c("Voxel Number" ,"Brain Region", "Brodmann Area", "X", "Y", "Z", "Z Score")
  
  ### Getting name of file
  n <- str_split(data, "/") 
  n <- str_replace(n[[1]][[length(n[[1]])]],".txt", "")
  
  ### Exporting as HTML for pasting into word
  xt <- xtable(df)
  print.xtable(xt, 
               type="html", 
               file = paste("C:/Users/mattw/Desktop/",n,".html", sep = ""), include.rownames = F)
  
}
