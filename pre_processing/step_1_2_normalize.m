% Arguments
% x = subject
% y = subject_dir (string to location)
% z = template_image (string to location)

function matlabbatch = step_1_2_normalize(x,y,z)

%%% Step 3 - Normalize

%% Creating cell array with files from Step 2
subject_search_string = ['*',x,'*.img'];
files = dir(fullfile(y,subject_search_string));

file_array = cell(length(files),1); %Predifine cell array

for i = 1:length(files)
    file_array{i} = [files(i).folder,'/',files(i).name,',1'];
end

%% Load in mean image from the realigning
mean_file = dir(fullfile(y,'*.nii'));

% Select source image - mean image from the Realign and Estimate Step
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {[mean_file(1).folder,'/',mean_file(1).name,',1']};
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = ''; % 0 files for source weighting

% Select the images to write - the images which resulted from Step 2
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = file_array;

%% Locating Template Image - ONLY FOR WATER SCANS
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {z};

% The rest is kept at default
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = ''; 
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50
                                                             78 76 85];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

end
