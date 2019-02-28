function matlabbatch = step_2_2_estimation_contrasts_darpa(subject_files, contrasts, analysis_type)
    
    %% Estimating Model - Step 2 in the Analysis Pipeline
    % First step is to read in SPM file
    path = strsplit(subject_files, '/');
    analysis_path = strjoin(path(1:length(path)-1),'/');
    
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {[analysis_path,'/',analysis_type,'/','SPM.mat']};
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    %% Creating Contrasts - Step 3 in the Analysis Pipeline
    % Load in SPM.mat file
    matlabbatch{2}.spm.stats.con.spmmat = {[analysis_path,'/',analysis_type,'/','SPM.mat']};

    % Get number of rows in contrast file
    [nrow,ncol] = size(contrasts);

    % Iterate over all contrasts
    for ii = 1:nrow
        matlabbatch{2}.spm.stats.con.consess{ii}.tcon.name = char(contrasts(ii));
        matlabbatch{2}.spm.stats.con.consess{ii}.tcon.convec = cell2mat(contrasts(ii,2:ncol));
        matlabbatch{2}.spm.stats.con.consess{ii}.tcon.sessrep = 'none';
    end
    
    % Do not delete after finishing
    matlabbatch{2}.spm.stats.con.delete = 0;

end
