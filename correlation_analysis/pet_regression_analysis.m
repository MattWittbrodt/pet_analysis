% Information on variables:
% subjects = file with all of the subject groupings and covariates of
% interst
% contrast_type = character with either 'activation' or 'deactivation'
% data_dir = brain activation network
% subj_list = list of subjects to be included within the analysis
% cov_col = column in excel file with column for covariate - if none, empty
% wb = whole brain- an indexed double with all brain locations
 
function matlabbatch = pet_regression_analysis(regressor_file, regressor_col, cov_col, output_dir, data_dir, subj_list, wb)
 
    
%% Step 1: Reading in Subject Groupings and Files
%subjects = xlsread(subject_file);
 
% Getting list of subjects
%subject_data = dir(data_dir);
%subject_data(1:2) = []; % Removing first two rows
%subject_data = {subject_data.name}.'; %.' fills vertically
 
%% Step 2: Read in regressor and then cross reference with subject files
regressor = xlsread(regressor_file);
 
% Remove missing NaN
regressor = rmmissing(regressor(:,[1,regressor_col, cov_col]));
[~,ncol] = size(regressor);
ncol = ncol - 1; % correcting for Cov_col on the end

% Running equivalency check - removing subjects without regressor data
remove_subjects = [];
for ii = 1:length(subj_list)
    s = subj_list(ii);
    if ~any(regressor(:) == s)
        remove_subjects = [remove_subjects,ii];
    end
end
 
subj_list(remove_subjects) = [];
 
% Running if statement not run analysis with too few data
if length(subj_list) <= 2
    too_few = fopen('~/Desktop/regression_errors.txt','w');
    fprintf(too_few, '%s; Too few subjects, n = %d\n', regressor_file, length(subj_list));
    fclose(too_few);
    matlabbatch = [];
 
else
 
    % Looping through regressor data and covariate and placing into array
    regressor_data = cell(length(subj_list),length(regressor_col)); % Open array to place files in
    
    % Checking if covariate has been specified
    if ~(isempty(cov_col))
        cov_data = cell(length(subj_list),length(cov_col)); % Open array to place files in
    else
        cov_data = [];
    end
    
    % Any empty subjects?
    no_data = [];
    
    for sub = 1:length(subj_list)
 
        s = subj_list(sub);
        row_num = find(regressor == s);
 
        % getting the regressor and placing into the covariate structure
        if ncol == 1
            reg = regressor(row_num, 2);
        else
            reg = regressor(row_num, (2:ncol));
        end
        
        % Removing if not present in data
        if isempty(reg)
            no_data = [no_data;row_num];
        else
            regressor_data(sub,:) = num2cell(reg);
        end
        
        % adding covariate if specified
        if ~(isempty(cov_data))
            
            for c = 1:length(cov_col)
                cov = regressor(row_num, 2+c);
                cov_data(sub,c) = num2cell(cov);
            end
        end
        
    end
    
    % Removing some subjects without data
    subj_list(no_data,:) = [];
  
    %% Step 2: Getting Design Elements (first batch run)
    for con = 1:3
        
        % Making loop-specific copy of regressor data for missing data
        regressor_data_tmp = regressor_data;
        
        if con == 1
            %con_type = 'activation';
            con_type = 'math';
        elseif con == 2
            %con_type = 'deactivation';
            con_type = 'speaking';
        else
            con_type = 'combined';
        end
 
        % Create array with file paths of scan (1 row per subject) and place into
        % scans batch script
        scan_data = cell(length(subj_list),1); % Open array to place files in
        no_data = [];
        
        for sub = 1:length(subj_list)
 
            % Get subject #
            s = subj_list(sub);
 
            % Retrieving file
            if strcmp(con_type,'math')
                contrast = 'con_0001.nii'; % 001 = activation
                batch = 1;
            elseif strcmp(con_type, 'speaking')
                contrast = 'con_0003.nii'; % 002 = deactivation
                batch = 2;
            else
                contrast = 'con_0005.nii';
                batch = 3;
            end
            
            % Zeroing out negative values
            %tic
            %zeroing_image([data_dir,'/',num2str(s),'/',contrast], wb);
            %toc
            
            % Checking if file exists
            file = [data_dir,'/',num2str(s),'/',contrast];
            
            if exist(file,'file')
                scan_data{sub} = [file,',1'];
            else
                no_data = [no_data,s];
            end
        end
        
        % Removing subjects without data
        scan_data(no_data) = [];
        regressor_data_tmp(no_data) = [];
        
        % Identify ouptput directory for .SPM
        initialbatch{1}.spm.stats.factorial_design.dir = {[output_dir,'/',con_type]};
 
        % Adding into batch file
        initialbatch{1}.spm.stats.factorial_design.des.mreg.scans = scan_data;
 
        %% Step 3: Adding data to regression against (called covariate in SPM)
 
        % Place into regression array
        for r = 1:length(regressor_col)
            initialbatch{1}.spm.stats.factorial_design.des.mreg.mcov(r).c = cell2mat(regressor_data(:,r));
            initialbatch{1}.spm.stats.factorial_design.des.mreg.mcov(r).cname = ['regressor ',num2str(r)];
            initialbatch{1}.spm.stats.factorial_design.des.mreg.mcov(r).iCC = 1; % centered with mean
        end
        
        %% Step 4: Adding covariates (nuscience variables)
        
        for c = 1:length(cov_col) 
            initialbatch{1}.spm.stats.factorial_design.cov(c).c = cell2mat(cov_data(:,c));
            initialbatch{1}.spm.stats.factorial_design.cov(c).cname = ['covariate_',num2str(c)];
            initialbatch{1}.spm.stats.factorial_design.cov(c).iCFI = 1; % no interaction
            initialbatch{1}.spm.stats.factorial_design.cov(c).iCC = 1; % overall mean
        end
        
        %% Adding other generic information into batch
        %matlabbatch{batch}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        %matlabbatch{batch}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        initialbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        initialbatch{1}.spm.stats.factorial_design.masking.im = 1;
        initialbatch{1}.spm.stats.factorial_design.masking.em = {''};
        initialbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        initialbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        initialbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
 
        %% Batch 2 - Model Estimation - Keeping Vanilla for now
        
        initialbatch{2}.spm.stats.fmri_est.spmmat = {[output_dir,'/',con_type,'/','SPM.mat']};
        initialbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        initialbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        % Running jobs up until now
        spm_jobman('run', initialbatch)
        
        %% Examining if beta values are not unique
        
        %loading in SPM
        SPM = spm_load([output_dir,'/',con_type,'/','SPM.mat']);
        
        % getting logic array: 1 = unique, 0 = not unique
        unique = spm_SpUtil('IsCon',SPM.SPM.xX.nKX);
               
        %% Batch 3 - Contrast
 
        % Keeping dependency from estimated model
        matlabbatch{batch}.spm.stats.con.spmmat = {[output_dir,'/',con_type,'/','SPM.mat']};
 
        % Creating contrasts - only 1 (positive) given the contrast image leading
        % into it. If entering covariates into scan data, will appear before
        % study-wide covariate
        for c = 1:length(regressor_col)
            array = zeros(1,length(regressor_col));
            
            % if the regressor is not unique, put in a dummy contrast
            if ~unique(1+length(cov_col) + c)
                contrast_vector = [1, (1:length(cov_col))*0, array];
            else
                array(c) = 1;
                contrast_vector = [0, (1:length(cov_col))*0, array];
            end
            
            matlabbatch{batch}.spm.stats.con.consess{c}.tcon.name = 'positive';
            matlabbatch{batch}.spm.stats.con.consess{c}.tcon.convec = contrast_vector;
            matlabbatch{batch}.spm.stats.con.consess{c}.tcon.sessrep = 'none';
            matlabbatch{batch}.spm.stats.con.consess{c+length(regressor_col)}.tcon.name = 'negative';
            matlabbatch{batch}.spm.stats.con.consess{c+length(regressor_col)}.tcon.weights = contrast_vector*-1;
            matlabbatch{batch}.spm.stats.con.consess{c+length(regressor_col)}.tcon.sessrep = 'none';
            matlabbatch{batch}.spm.stats.con.delete = 0;
        end
 
    end
 
end
 
end
 

