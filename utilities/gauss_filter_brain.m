% Reads in image and does gaussian filtering 
% name_of_image = string - location of image
% sigma - sigma for guassian filtering (default for angina paper is 2)
% name of new image (include path)
% return_binary = 1 = yes, 0 = No

function gauss = gauss_filter_brain(name_of_image, sigma, return_binary)

%% Reading in image
img = spm_vol(name_of_image);




