function matlabbatch = regression_analysis_darpa2(subjects, physiol, measure_col, measure_dir, subject_dir)

%% Batch 1 - Setting up design

% Identify directory for files
matlabbatch{1}.spm.stats.factorial_design.dir = {measure_dir};

% Load in scans, create array with the actual scan file paths
% Scans should take form of one / subject
scan_data = cell(length(subjects),1); % Open array to place files in
physiological_data = cell(length(subjects),1);

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
     
        % Activation during trauma scripts deal with con_0001 (from first level),
        % deactivation is the con_0002 images
        %if strcmp(analysis_type,'activation')      
        %    contrast = 'con_0001.img';
        %else
        %    contrast = 'con_0002.img';
        %end
           
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

