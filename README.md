# pet_analysis toolbox code explanation

## Table of Contents
1. [General Function](#general_function)
2. [Pre-Processing Pipeline](#pre_processing)
3. [Example Pre-Processing Set Up](#ex_pre)

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

## General Set Up for PET analysis
The two main folders needed for PET analysis are in ```pre_processing``` and ```main_analysis```. Additionally, for each study, there are a few files and a pipeline needed. Below is a quick checklist for setting up a new study. The functions below will be described in more detail.

File/Folder | Completed
------------|------------
**pre_processing**|
```step_1_1_realign_and_estimate.m```|
```step_1_2_normalize.m```|
```step_1_3_smooth.m```|

### Pre-Processing Pipeline <a name="pre_processing"></a>
**Step 1** is a set of functions which will automate the pre-processing steps. They are labeled with ```step_1_n``` where ```n``` is a sub-step of pre_processing. Exact details can be found within the ```.m``` file itself, but a summary of the 'design choices' will be presented along with a quick description. 

#### ```step_1_1_realign_and_estimate.m```: 
Arguments | Description
---|---
x| character of subject name - in my pipelines I extracted from data folders, so it reflected name of folder
y| path where individual subject data goes

**Function Returns:** Average image file for subject with the suffix, ```realigned_summed```

This function is essentially the image calculator utility from SPM. It starts by looking for all the raw PET files (.nii) in the subject folder. It loads all the files, creates an **average image** based on the scans available using an expression customized to the number of files for the estimation (e.g., if 3 scans: (Scan1 + Scan2 + Scan3)/ 3). 

This function uses the default variables, but in case they change in new SPM versions, they are:
* Data Matrix: No - don't read images into matrix
* No implicit zero mask
* Tri-linear interpretation
* INT16 data type

#### ```step_1_2_normalize.m```: 
Arguments | Description
---|---
x| character of subject name - in my pipelines I extracted from data folders, so it reflected name of folder
y| path where individual subject data goes
z| path to a template image - in this case '[location of MATLAB installation]/MATLAB/spm8/templates/PET.nii,1'

**Function Returns:** Copy of the raw data with a ```w``` prefix.

This function will run the image normalization step ('Old Normalize Estimate and Write' in SPM12). First, the individual scans are read in (.img files). Second, the mean image from step_1_1 (.nii file) is brought in. 

All default options are selected. In case they change, the screenshot below details the options.  
![normalize_options](manual_screenshots/normalize_options.png)

#### ```step_1_3_smooth.m```: 
Arguments | Description
---|---
x| character of subject name - in my pipelines I extracted from data folders, so it reflected name of folder
y| path where individual subject data goes

**Function Returns:** Smoothed version of each scan with a ```sw``` prefix.

This function is will read in the ```w``` prefix image file from normalization step and smooth it. This function uses a [5 5 5] full width half maximum Gaussian smoothing kernal with SAME data tyle and no implicit masking. The filename prefix is set as ```s```.

#### ```step_1_4_difference_images.m```: 
Arguments | Description
---|---
subject | character of subject name - in my pipelines I extracted from data folders, so it reflected name of folder
subject_files | path where individual subject data goes
scan_characteristics | A double with size n x 2, where n = number of different HR-PET scans
measure_name| a string with the name of stress intervention. For use in the contrast specification
contrasts| detailed below; individual contrast specifications
var | 0 or 1 - equal variance. Default runs with 1 in individual model specification; 0 will run otherwise
contrast_sum| a double of length n where n = number of contrasts specified. In the double is the sum of the contrasts. For examples, a contrast testing if A is greater than B would be [-1 1] for a contrast sum of 0. A contrast just looking at activation of A would be [1 0] (B is disregarded) and therefore has a contrast sum of 0.

**Function Returns:** Individual model SPM file with associated contrast maps (con_0001.nii) and contrast t values (spmT_0001.nii). 

This is the 'main' function within the individual data pre-processing. Importantly, **this step requires customized inputs tailored for the specific study**, which will be described in greater detail below when talking about the generation of a study-specific pipeline. Specific to this function, it looks for the ```sw``` prefix files, which are the final output for the image pre-processing. This function then sets up a basic flexible factorial model *for the specific subject* which is used to get their level of activation, deactivation, etc during different points of the experiment. There is also an error file written, ```subject_errors.txt``` placed in the study directory, which returns errors for specific contrasts (mainly during issues with lack of PET data). 

The ```var``` argument, noted above, indicates whether the variance in the factor (the second column of ```scan_characteristics```) is equal or unequal. By default, we want this to be true. However, some individual models will fail with this specification. Therefore, in order to avoid this, the function is called twice in the pre-processing pipeline with a ```try-catch``` sequence. This will try the model using equal variance (var = 1) and if not, try the model with unequal variance (var = 0). This specification is found in the line: ```matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.variance = var;```. If there are further errors, this will be returned in a variable ```errors``` printed to the workspace. It is advised to look at this after running all participants through the pipeline.

## Example Pre-Processing Stream <a name="ex_pre"></a>


###  Specific functions/scripts within each folder


## Utilities
```dir to list```: Takes in a directory (data_dir) and will output a list of all the directories in that list. Useful for getting individual subject lists from folders in a directory. Output can take a couple of formats depending on what is needed.
