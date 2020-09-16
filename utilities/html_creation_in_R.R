#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

print("We have loaded the script")

source("C:/Users/mattw/Documents/pet_analysis/utilities/spm_tali_to_html.R")

create_pet_table(args[1])

print(paste0("We have completed the script with the input file of: ", args[1]))