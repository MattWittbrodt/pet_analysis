# pet_analysis toolbox code explanation

## Table of Contents
1. [General Function](#general_function)

## General function of code <a name="general_function"></a>
The code is separated into two main components: data cleaning and analysis. All scripts can be accessed natively through the MATLAB terminal by adding folder to path (assuming the folder is in your documents folder:
```matlab
addpath(genpath('~/Documents/pet_analysis'));
```
The general structre of the toolbox is such:

Folder | Purpose
------------ | -------------
cluster_finding | 
correlation_analysis | 
main_analysis |
pre_processing |
utilities | Functions to help ease import of directories and small processing tasks


## Specific functions/scripts within each folder


## Utilities
```dir to list```: Takes in a directory (data_dir) and will output a list of all the directories in that list. Useful for getting individual subject lists from folders in a directory. Output can take a couple of formats depending on what is needed.
