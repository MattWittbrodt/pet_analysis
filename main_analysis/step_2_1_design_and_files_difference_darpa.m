function matlabbatch = step_2_1_design_and_files_difference_darpa(subjects,subject_groupings,subject_dir, analysis_type, factors)
    
    %% First, filtering out data to match subject and groupings
    errors = []; % to place errors in
    
    % Getting Dimensions of subject groupings file
    [nrow, ~ ] = size(subject_groupings);
    
    % Routine to remove subjects in groupings file but no scans
    rows_to_delete = [];
    
    for ii = 1:nrow
        s = num2str(subject_groupings(ii));

            % Check if subject is in the analysis, if not, skip
            check_if_subject = find(strcmp(subjects,s),1);
            if isempty(check_if_subject) == 1
                rows_to_delete = [rows_to_delete; ii];
            end
    end
    
    % Removing rows
    subject_groupings(rows_to_delete,:) = [];
    [~,n_contrasts] = size(subject_groupings);
    
    %% Second, getting scans for each subject 
    subject_scans = cell(length(subject_groupings),1);
           
    % Get files
    for kk = 1:length(subject_scans)
        
        s = num2str(subject_groupings(kk,1)); % get subject #

        % Activation during trauma scripts deal with con_0001 (from first level),
        % deactivation is the con_0002 images
        if strcmp(analysis_type,'activation') || strcmp(analysis_type,'activation_contrast')       
            contrast = 'con_0001.img';
        else
            contrast = 'con_0002.img';
        end
           
        % Retrieving file
        file = [subject_dir,'/',s,'/', contrast];
        subject_scans{kk} = [file,',1'];
    end

            
    %% Setting Up Flexible Factorial Design - directory and factors
       
    % Identifying correct directory
    parts = strsplit(subject_dir, '/');
    path = strjoin(parts(1:length(parts)-1), '/');
    matlabbatch{1}.spm.stats.factorial_design.dir = {[path,'/',analysis_type]};
    
    % Factors
    for factor = 1:length(factors) 
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(factor).name = cell2char(factors(factor));
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(factor).dept = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(factor).variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(factor).gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(factor).ancova = 0;
    end
    
    %% Adding subjects to design
    to_remove = [];
    for sub = 1:length(subject_scans)
        
        % Adding conditions
        conds = subject_groupings(sub,2:n_contrasts) + 1;
                
        % Checking if there are 0's
        if sum(isnan(conds) == 0)
            
            % Adding scans and conditions
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(sub).scans = ...
                subject_scans(sub);
       
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(sub).conds = conds;
        else
            to_remove = [to_remove,sub];
        end
                 
    end
    
    % Removing subjects without factor information
    matlabbatch{1, 1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(to_remove) = [];
    
    %% Finishing out design
    
    % Identifying Interaction
    inter_size = zeros(1,length(factors));
    for inter = 1:length(inter_size)
        inter_size(inter) = inter;
    end
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = inter_size;
          
    % No covariate (for now)
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {}); % No covariate
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1; % Relative threshold masking with value of 0.8

    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1; % No omplicit mask
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''}; % No for explicit

    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1; % Use global mean
    %matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_yes.gmscv = 50; % global mean scaling @ 50
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;

    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1; % no normalization
    
end
