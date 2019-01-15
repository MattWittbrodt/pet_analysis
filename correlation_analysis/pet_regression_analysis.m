% Information on variables:
% subjects = file with all of the subject groupings and covariates of
% interst
% contrast_type = character with either 'activation' or 'deactivation'
% data_dir = brain activation network

function matlabbatch = pet_regression_analysis(subject_file, regressor_file, regressor_col, measure_col, output_dir, data_dir, contrast_type)

%% Step 1: Reading in Subject Groupings and Files
subjects = xlsread(subject_file);

% Getting list of subjects
subject_data = dir(data_dir);
subject_data(1:2) = []; % Removing first two rows
subject_data = {subject_data.name}.'; %.' fills vertically

%% Step 2: Getting Design Elements (first batch run)

% Identify ouptput directory for .SPM
matlabbatch{1}.spm.stats.factorial_design.dir = {output_dir};

% Create array with file paths of scan (1 row per subject) and place into
% scans batch script
scan_data = cell(length(subject_data),1); % Open array to place files in

for sub = 1:length(subject_data)
    
    % Get subject #
    s = subject_data{sub};
    
    % Retrieving file
    if contrast_type == 'activation'
        contrast = 'con_0001.img'; % 001 = activation
    else contrast = 'con_002.img'; % 002 = deactivation
    end
    
    file = [data_dir,'/',s,'/',contrast];
    scan_data{sub} = file;
end

%% Step 3: Adding data to regression against (called covariate in SPM)
regressor = xls_read(regressor_file);

regressor_data = cell(length(subject_data),1); % Open array to place files in

% Looping through regressor data and placing into array
for sub = 1:length(subject_data)
    
    s = subject_data{sub};
    row_num = find(subjects == str2num(s));
    
    % getting the regressor and placing into the covariate structure
    reg = [];
    reg = cell2mat(regressor(row_num, regressor_col));
    regressor_data(sub,1) = num2cell(reg);

end

% Place into regression array
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = cell2mat(regressor_data);
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = 'regressor';
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1; %centered with mean

%% Step 4: Adding covariates (nuscience variables)

% Getting number of covariates and creating an empty array for values
% cov_number = length(measure_col);
% cov_data = cell(length(subject_data),cov_number);
% 
% % Looping through covariates and placing into array
% for sub = 1:length(subject_data)
%     
%     s = subject_data{sub};
%     row_num = find(subjects == str2num(s));
%     
%     % getting the covariates and placing into the covariate structure
%     cov = [];
%     if cov_number == 1
%         cov = subjects(row_num, 1+length(cov_number));
%         cov_data(sub, 1) = num2cell(cov);
%     else
%         final_col = 1+cov_number;
%         cov = subjects(row_num, 2:final_col);
%         cov_data(sub, 1:length(cov)) = num2cell(cov);
%     end
% 
% end

% Get files
skipped_subj = 0; %for row numbering 
for kk = 1:length(subjects)
    
    % Get subject #
    s = subjects{kk};
    
    % Getting subject data by ID row with subject data
    [ii,~] = find(physiol == str2num(subjects{kk})); % gets [row,colum] for subject
    value = physiol(ii, measure_col);
    
    % Do a check to see if data is there. If not, skip subject.
    if isempty(value) == 0
        physiological_data{kk} = value;
       
        % Retrieving file
        contrast = 'con_0001.img'; % only activation for now
        file = [subject_dir,s,'\',contrast];
        scan_data{kk} = file;
    end
end

% Removing empty rows in physiological data and scan data
physiological_data(all(cellfun('isempty',physiological_data),2),:) = [];
scan_data(all(cellfun('isempty',scan_data),2),:) = [];

% Need to check for NaN's in data
if isnan(cell2mat(physiological_data)) == false
    
    % Place into design structure
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scan_data;

    % For now, no covariate so do not enter anything
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});

    % Include intercept in model
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;

    % Adding covariate (i.e., what we are going to regress against)
    matlabbatch{1}.spm.stats.factorial_design.cov.c = cell2mat(physiological_data);
    matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'feature';

    % Rest are standard arguments
    matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    %% Batch 2 - Model Estimation - Keeping Vanilla for now
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'Factorial design specification: SPM.mat File';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


    %% Batch 3 - Contrast

    % Keeping dependency from estimated model
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep;
    matlabbatch{3}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{3}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
    matlabbatch{3}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{3}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');

    % Creating contrasts - only 1 (positive) given the contrast image leading
    % into it. If entering covariates into scan data, will appear before
    % study-wide covariate
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'positive';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [0 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

else
    matlabbatch = [];
end

end

