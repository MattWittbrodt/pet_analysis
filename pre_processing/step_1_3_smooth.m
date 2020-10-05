% Arguments
% x = string of subject ID (generally, name of folder)
% y = string of folder path

function matlabbatch = step_1_3_smooth(x,y)

%%% Step 4 - Smooth

%% Creating cell array with files from Step 3
subject_search_string = ['w',x,'*.img'];
files = dir(fullfile(y,subject_search_string));

file_array = cell(length(files),1); %Predifine cell array

for i = 1:length(files)
    file_array{i} = [files(i).folder,'/',files(i).name,',1'];
end

%% Load images from Step 3 into cell array
matlabbatch{1}.spm.spatial.smooth.data = file_array;

%% Change smooth FWHM from 8 8 8  to 5 5 5
matlabbatch{1}.spm.spatial.smooth.fwhm = [5 5 5];

% Other parameters are kept at default
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

end