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
regressor = rmmissing(regressor(:,[1,regressor_col]));
 
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
    regressor_data = cell(length(subj_list),1); % Open array to place files in
    
    % Checking if covariate has been specified
    if ~(isempty(cov_col))
        cov_data = cell(length(subj_list),1); % Open array to place files in
    else
        cov_data = [];
    end
    
    for sub = 1:length(subj_list)
 
        s = subj_list(sub);
        row_num = find(regressor == s);
 
        % getting the regressor and placing into the covariate structure
        reg = regressor(row_num, 2);
        regressor_data(sub,1) = num2cell(reg);
        
        % adding covariate if specified
        if ~(isempty(cov_data))
            cov_data(sub,1) = num2cell(reg);
        end
        
    end
 
 
 
    %% Step 2: Getting Design Elements (first batch run)
    for con = 1:2
        
        if con == 1
            con_type = 'activation';
        else
            con_type = 'deactivation';
        end
 
        % Create array with file paths of scan (1 row per subject) and place into
        % scans batch script
        scan_data = cell(length(subj_list),1); % Open array to place files in
 
        for sub = 1:length(subj_list)
 
            % Get subject #
            s = subj_list(sub);
 
            % Retrieving file
            if strcmp(con_type,'activation')
                contrast = 'con_0001.nii'; % 001 = activation
                batch = 1;
            else
                contrast = 'con_0002.nii'; % 002 = deactivation
                batch = 4;
            end
            
            % Zeroing out negative values
            zeroing_image([data_dir,'/',num2str(s),'/',contrast], wb);
 
            file = [data_dir,'/',num2str(s),'/',contrast,',1'];
            scan_data{sub} = file;
        end
        
        % Identify ouptput directory for .SPM
        matlabbatch{batch}.spm.stats.factorial_design.dir = {[output_dir,'/',con_type]};
 
        % Adding into batch file
        matlabbatch{batch}.spm.stats.factorial_design.des.mreg.scans = scan_data;
 
        %% Step 3: Adding data to regression against (called covariate in SPM)
 
        % Place into regression array
        matlabbatch{batch}.spm.stats.factorial_design.des.mreg.mcov.c = cell2mat(regressor_data);
        matlabbatch{batch}.spm.stats.factorial_design.des.mreg.mcov.cname = 'regressor';
        matlabbatch{batch}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1; %centered with mean
 
        %% Step 4: Adding covariates (nuscience variables)
 
        % Getting covariates similar to main regressor data
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
 
        %% Adding other generic information into batch
        matlabbatch{batch}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{batch}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{batch}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{batch}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{batch}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{batch}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{batch}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{batch}.spm.stats.factorial_design.globalm.glonorm = 1;
 
        %% Batch 2 - Model Estimation - Keeping Vanilla for now
        
        matlabbatch{batch + 1}.spm.stats.fmri_est.spmmat = {[output_dir,'/',con_type,'/','SPM.mat']};
        matlabbatch{batch + 1}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{batch + 1}.spm.stats.fmri_est.method.Classical = 1;
 
        %% Batch 3 - Contrast
 
        % Keeping dependency from estimated model
        matlabbatch{batch + 2}.spm.stats.con.spmmat = {[output_dir,'/',con_type,'/','SPM.mat']};
 
        % Creating contrasts - only 1 (positive) given the contrast image leading
        % into it. If entering covariates into scan data, will appear before
        % study-wide covariate
        matlabbatch{batch+2}.spm.stats.con.consess{1}.tcon.name = 'positive';
        matlabbatch{batch+2}.spm.stats.con.consess{1}.tcon.convec = [0 1];
        matlabbatch{batch+2}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{batch+2}.spm.stats.con.consess{2}.tcon.name = 'negative';
        matlabbatch{batch+2}.spm.stats.con.consess{2}.tcon.weights = [0 -1];
        matlabbatch{batch+2}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{batch+2}.spm.stats.con.delete = 0;
 
    end
 
end
 
end
 

