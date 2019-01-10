%% Clean the workspace

% TODO: turn into a function
% variables in function call:
%   Sigma size, path, location of whole brain volume
% 


% clear;
clc;
% close all;

%% Load the data
% TODO - Put into function
% load('subjects.mat');    % Sample subject
% load('control.mat');     % Average activation

path = '/Users/mattwittbrodt/Desktop/angina/';

% Whole Brain - reading in and getting coordinates of whole brain
wb = spm_vol('/Volumes/Seagate Expansion Drive/DARPA/darpa_roi/wholeBrain.nii');
wb_img = spm_read_vols(wb);

% Average Pre-processing - (contrast with average activations)
avg = spm_vol([path,'con_0003.img']); %load in contrast image of averagerage activations
avg_img = spm_read_vols(avg); %3d matrix with values 
avg_img(isnan(avg_img)) = 0; %zeroing values which are returned as NaN
avg_img(wb_img == 0) = 0; % zeroing areas within the contrast not part of whole brain
avg_img(avg_img < 1.6) = 0; % using a p value of 0.05 (t = 1.6) to threshold (only get active areas)
avg_img = imgaussfilt3(avg_img, 2); % 3d gaussian filtering with sigma of 2 (smoothing)

% Contrast of Interest
contrast = spm_vol([path,'con_0002.img']); % load in contast image of specific contrast
con_img = spm_read_vols(contrast); %getting 3d matrix with values
con_img(isnan(con_img)) = 0; %zeroing values which are returned as NaN
con_img(avg_img < 0.1) = 0; %zeroing based on the average activation image
con_img(con_img < 2.3) = 0; % thresholding at p < 0.005 (to match natural SPM
                            % we have to fudge a bit and drop t threshold)
con_img = imgaussfilt3(con_img, 2); % 3d gaussian filtering to smooth
con_img(wb_img == 0) = 0; % zeroing abberant values outside of brain
%%

% FWHM = 4;
% sigma = FWHM / (2*sqrt(2*log(2)));
sigma = 2;
min_t = 2;
min_t_filt = 0.5; % could chane this inside the function to be like the mean (of filtered values) minus 2 stds or something...

groupActivationRegions(con_img, avg_img, sigma, min_t, min_t_filt, 1);
