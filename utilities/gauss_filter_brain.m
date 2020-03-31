% Reads in image and does gaussian filtering 
% name_of_image = string - location of image
% sigma - sigma for guassian filtering (default for angina paper is 2)
% name of new image (include path)
% return_binary = 1 = yes, 0 = No

function gauss = gauss_filter_brain(name_of_image, sigma, name_of_new_image, return_binary)

%% Reading in image
img = spm_vol(name_of_image);
img_vol = spm_read_vols(img);

%% Doing filtering (first need to remove NA from data)
img_vol(isnan(img_vol)) = 0;
img_vol_gauss = imgaussfilt3(img_vol, sigma);

%% Changing output name
img.fname = name_of_new_image;

%% If needing a binary brain, doing so
if return_binary == 1

    

end







