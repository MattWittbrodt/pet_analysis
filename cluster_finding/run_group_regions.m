%% Clean the workspace

% clear;
clc;
% close all;

%% Load the data
% TODO - Put into function
% load('subjects.mat');    % Sample subject
% load('control.mat');     % Average activation

path = '/Users/mattwittbrodt/Desktop/angina/';

% Whole Brain
wb = spm_vol('/Volumes/Seagate Expansion Drive/DARPA/darpa_roi/wholeBrain.nii');
wb_img = spm_read_vols(wb);

% Average Pre-processing - (contrast with average activations)
avg = spm_vol([path,'con_0003.img']); %load in image
avg_img = spm_read_vols(avg); 
avg_img(isnan(avg_img)) = 0;
avg_img(wb_img == 0) = 0;
avg_img(avg_img < 1.6) = 0;
avg_img = imgaussfilt3(avg_img, 2);

% Contrast of Interest
contrast = spm_vol([path,'con_0002.img']);
con_img = spm_read_vols(contrast);
con_img(isnan(con_img)) = 0;
con_img(avg_img < 0.1) = 0;
con_img(con_img < 2.3) = 0;
con_img = imgaussfilt3(con_img, 2);
con_img(wb_img == 0) = 0;
%%

% FWHM = 4;
% sigma = FWHM / (2*sqrt(2*log(2)));
sigma = 2;
min_t = 2;
min_t_filt = 0.5; % could chane this inside the function to be like the mean (of filtered values) minus 2 stds or something...

groupActivationRegions(con_img, avg_img, sigma, min_t, min_t_filt, 1);
