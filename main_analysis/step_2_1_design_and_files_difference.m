% subjects = cell array with subject IDs (with scan data)
% subject groupings = array with subject IDs and groupings
% subject_files = location of raw PET data
% analysis_type = string- generally 'activation' or 'deactivation'
% factors = what are the factors. Equal to n columns - 1 from subject_groupings 

function matlabbatch = step_2_1_design_and_files_difference(subjects,subject_groupings, subject_files,analysis_type, factors)
    
    %% Getting list of subjects with groupings and scan data
    % Removing NaN's from data
    subject_groupings(any(isnan(subject_groupings), 2), :) = [];

    % Routine to remove subjects in groupings file but no scans
    rows_to_delete = [];
       
    for ii = 1:length(subject_groupings)
       
       s = num2str(subject_groupings(ii));
 
       % Check if subject in grouping data has PET data. If not, skip
       check_if_subject = find(strcmp(subjects, s), 1);
       
       if isempty(check_if_subject) == 1
          rows_to_delete = [rows_to_delete; ii];
       end
       
    end
    
    % Removing rows
    subject_groupings(rows_to_delete,:) = [];
    
    %% Second - looping over analysis_type (activation, deactivation, etc)
    % Building large array with subject names and the factors
    all_data = num2cell(subject_groupings);
    
    % Read in whole brain file, get volumes, then get indices = 1 for brain
    wb = spm_vol('/Volumes/Seagate/DARPA/darpa_roi/wholeBrain.nii');
    wb_vol = spm_read_vols(wb);
    wb_location = find(wb_vol == 1);
    
    % Looping over subjects to get scan data   
    for jj = 1:length(all_data)
        
        % Getting subject
        s = cell2char(all_data(jj,1));
        
        % Getting contrast
        if strcmp(analysis_type,'activation') || strcmp(analysis_type,'activation_contrast')       
                contrast = 'con_0001.nii';
        else
                contrast = 'con_0002.nii';
        end
        
        % Zeroing out data
        tic
        zeroing_image([subject_files,'/',s,'/', contrast], wb_location);
        toc
        
        % Retrieving file
        file = [subject_files,'/',s,'/', contrast,',1'];
        
        % Placing into cell array
        all_data{jj,1} = file;
    end      
    
    %% Setting Up Flexible Factorial Design
       
    % Identifying correct directory
    analysis_dir = '';
    s_files = strsplit(subject_files,'/');
    for l = 2:length(s_files)-1
        analysis_dir = [analysis_dir,'/',cell2char(s_files(l))];
    end
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {[analysis_dir,'/',analysis_type]};
    
    % Placing Factors into array
    for fac = 1:length(factors)
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).name = cell2char(factors(fac)); 
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).dept = 0; 
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).variance = 1; 
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).gmsca = 0; 
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).ancova = 0; 
    end
    
    % Placing subjects into design
    for s = 1:length(all_data)
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = cellstr(cell2char(all_data(s,1))); 
        
        % Looping over grouping factors
        conds = zeros(1,length(factors));
        
        for fac = 1:length(factors)
            factor_col = fac + 1;
            conds(fac) = cell2mat(all_data(s,factor_col))+1;
        end

        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = conds; 
        
    end
    
    % Identifying Interaction
    inter = zeros(1,length(factors));
    for int = 1:length(inter)
        inter(int) = int;
    end
    
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = inter;
    
    % No covariate (for now)
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {}); % No covariate
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1; % Relative threshold masking with value of 0.8
    
    % No masking
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    
    % Becuase this is already in t-values, do not need to normalize
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
end
