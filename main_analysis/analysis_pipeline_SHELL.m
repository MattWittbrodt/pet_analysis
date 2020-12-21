%%%%%%%%%%%
%%%%%%%%%%% Analysis Pipeline for Angina Data
%%%%%%%%%%%

%% Referring code and cleaning space
addpath(genpath('PATH TO pet_analysis FOLDER'));
clear;

%% Identify subject and analysis file directory
subject_files = 'PATH TO FOLDER WITH SUBJECT DATA THAT INCLUDES {SUBJID}/con_0001.nii FILE';
subject_groupings = xlsread('PATH TO FILE OF SUBJECT GROUPINGS');
% example: subject_groupings = xlsread('C:/Users/mattw/Documents/Research/darpa/script_files/subject_groupings.xlsx');

% Getting list of subjects
subjects = dir(subject_files);
subjects = remove_dots(subjects); % Removing first two rows
subjects = remove_imaging_files(subjects);
subjects = {subjects.name}.'; %.' fills vertically

% Read in contrast excel file
[~,~,contrasts] = xlsread('PATH TO CONTRASTS .xlsx', 'SHEET NAME');
%example: [~,~,contrasts] = xlsread('C:/Users/mattw/Documents/Research/darpa/script_files/contrasts_darpa.xlsx', 'Sheet3');

%% Adding covariates
% Columns of interest- 3 (gender), 18 (age)
covariate_data = xlsread('C:/.../.../{file_name}.xlsx');
covariate_data = covariate_data(:,[1,3,18]); % takes the whole file and returns 3 columns - 1 (subject ID), 3 (gender), 18 (age)
[nrow,ncol] = size(covariate_data); % getting size of data
[~,grouping_factors] = size(subject_groupings); % returning the number of factors

% Looping over and adding to subject_groupings
for s = 1:length(covariate_data)
    sub = covariate_data(s,1);
    
    % Getting row in subject grouping file
    row = find(subject_groupings == sub,1);
    
    % Adding data from covariates to subject_groupings
    for cc = 2:ncol
        cov = covariate_data(s,cc);
        %-1 because we are starting to count at 2, +cc for the count
        subject_groupings(row,(grouping_factors-1+cc)) = cov;
    end
    
end
    
% Adding names
cov_names = {'COV1_NAME','COV2_NAME'};

%% Looping over activation, deactivation, VNS
runs = {'RUN1_NAME', 'RUN2_NAME', 'RUN2_NAME'}; 

for run = 1:length(runs)
    
    % brain activity type
    analysis_type = cell2char(runs(run));
    
    % Getting subject images
    if strcmp(analysis_type,'activation')
        subj_images = 1;
    elseif strcmp(analysis_type,'deactivation')
        subj_images = 2;
    else
        subj_images = 3;
    end
    
    %% Step 1: Setting up Research Design
    clear jobs
    factors = {'ptsd','sham'};
    covariates = [4,5];
    covariate_names = cov_names;
    scans_as_factors = 0;

    tic
    design = step_2_1_design_and_files_difference(subjects,...
                                                  subject_groupings,...
                                                  subject_files,...
                                                  analysis_type,...
                                                  factors,...
                                                  subj_images,...
                                                  covariates,...
                                                  covariate_names,...
                                                  scans_as_factors);
    toc
    spm_jobman('run', design)

    %% Step 2: Estimation and Contrasts 
    clear jobs
    study_contrasts = step_2_2_estimation_contrasts_darpa(subject_files, contrasts, analysis_type);
    spm_jobman('run', study_contrasts)
end
