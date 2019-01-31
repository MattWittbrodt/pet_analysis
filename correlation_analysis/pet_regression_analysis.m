% Information on variables:
% subjects = file with all of the subject groupings and covariates of
% interst
% contrast_type = character with either 'activation' or 'deactivation'
% data_dir = brain activation network
% subj_list = list of subjects to be included within the analysis

function matlabbatch = pet_regression_analysis(regressor_file, regressor_col, output_dir, data_dir, subj_list, contrast_type)

    
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
    if isempty(find(regressor(:,1) == s))
        remove_subjects = [remove_subjects,ii];
    end
end

subj_list(remove_subjects) = [];

% Running if statement not run analysis with too few data
if length(subj_list) <= 2
    fprintf('Too few subjects, n = %d\n', length(subj_list))
    matlabbatch = [];

else

    % Looping through regressor data and placing into array
    regressor_data = cell(length(subj_list),1); % Open array to place files in
    for sub = 1:length(subj_list)

        s = subj_list(sub);
        row_num = find(regressor == s);

        % getting the regressor and placing into the covariate structure
        reg = [];
        reg = regressor(row_num, 2);
        regressor_data(sub,1) = num2cell(reg);

    end



    %% Step 2: Getting Design Elements (first batch run)

    % Identify ouptput directory for .SPM
    matlabbatch{1}.spm.stats.factorial_design.dir = {output_dir};

    % Create array with file paths of scan (1 row per subject) and place into
    % scans batch script
    scan_data = cell(length(subj_list),1); % Open array to place files in

    for sub = 1:length(subj_list)

        % Get subject #
        s = subj_list(sub);

        % Retrieving file
        if contrast_type == 'activation'
            contrast = 'con_0001.img'; % 001 = activation
        else contrast = 'con_002.img'; % 002 = deactivation
        end

        file = [data_dir,'/',num2str(s),'/',contrast,',1'];
        scan_data{sub} = file;
    end

    % Adding into batch file
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scan_data;

    %% Step 3: Adding data to regression against (called covariate in SPM)

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

    %% Adding other generic information into batch
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    %%



    % 

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

end

end

