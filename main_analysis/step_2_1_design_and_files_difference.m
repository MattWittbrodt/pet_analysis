% subjects = cell array with subject IDs (with scan data)
% subject groupings = array with subject IDs and groupings
% subject_files = location of raw PET data
% analysis_type = string- generally 'activation' or 'deactivation'
% covariates = double with indices of subject groupings
% factors = what are the factors. Equal to n columns - 1 from subject_groupings 
% scans_as_factors = habiation (time series) analysis? 1 = Yes, 0 = No
% subject_as_factor = are subjects treated as a factor (preferred)? 1 = Yes, 0 = No

function matlabbatch = step_2_1_design_and_files_difference(subjects,subject_groupings, subject_files, analysis_type, factors, subj_images, covariates, covariate_names, scans_as_factors, subject_as_factor)
    
    %% Getting list of subjects with groupings and scan data
    % Removing NaN's from data - first by median replace on covariates then
    % searching across entire dataframe for NaN's (these will be on main
    % factors)
    subject_groupings = median_replace(subject_groupings, covariates);
    
    % sometimes 
    if ~iscell(subject_groupings)

        subject_groupings(any(isnan(subject_groupings), 2), :) = [];
    end
    
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
    
    % Processing factors- if min = 0, SPM will have an error
    [~,ncol] = size(subject_groupings);
    for c = 1:ncol
        if min(subject_groupings(:,c)) == 0
           subject_groupings(:,c) = subject_groupings(:,c) + 1;
        end
    end
    
    %% Second - looping over analysis_type (activation, deactivation, etc)
    % Building large array with subject names and the factors
    all_data = num2cell(subject_groupings);

    % Building out array with number of scans in analysis. 
    [rows,cols] = size(all_data);
    all_data2 = cell(rows*length(subj_images),cols+2);
    
    % Get matrix with scan indices
    scan_index = repmat(subj_images,1,rows);
    
    row_count = 1;
    for nn = 1:length(all_data)
        
        for ll = 1:length(subj_images)
            
            for cc = 1:cols
                all_data2{row_count,cc} = all_data{nn,cc};
            end
            
            all_data2{row_count,cc+1} = ll;
                       
            row_count = row_count + 1;
            
        end
    end
                
    % Read in whole brain file, get volumes, then get indices = 1 for brain
    wb = spm_vol('C:/Users/mattw/Documents/Research/roi/wholeBrain.nii');
    wb_vol = spm_read_vols(wb);
    wb_location = find(wb_vol == 1);
    
    % Looping over subjects to get scan data
    empty_contrasts = [];
    [nrow, ncol] = size(all_data2);
    
    for jj = 1:nrow
        
        % Getting subject # and what subject image
        s = cell2char(all_data2(jj,1));
        n = cell2mat(all_data2(jj,ncol-1)); % what scan factor level
        contrast_number = subj_images(n); % what should the contrast be
        
        % Getting contrast
        contrast = ['con_000',num2str(contrast_number),'.nii'];
                
        % Checking if image exists. If not, remove from array
        if exist([subject_files,'/',s,'/', contrast],'file') == 2
            
            % Zeroing out data
            tic
            zeroing_image([subject_files,'/',s,'/', contrast], wb_location);
            toc
        
            % Retrieving file
            file = [subject_files,'/',s,'/', contrast,',1'];

            % Placing into cell array
            all_data2{jj,ncol} = file;
            
        else
             % If file does not exist, remove from large array
            empty_contrasts = [empty_contrasts, jj];
           
        end
    end
    
    % Clean up unused contrasts
    all_data2(empty_contrasts,:) = [];
    
    %% Setting Up Flexible Factorial Design
       
    % Identifying correct directory
    analysis_dir = '';
    s_files = strsplit(subject_files,'/');
    for l = 1:length(s_files)-1
        
        if l == 1
            analysis_dir = [analysis_dir,cell2char(s_files(l))];
        else
            analysis_dir = [analysis_dir,'/',cell2char(s_files(l))];
        end
    end
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {[analysis_dir,'/',analysis_type]};
    
    % Placing Factors into array
    
    % First, are subjects factors?
    if subject_as_factor == 1
        factors = [{'subject'},factors];
    end

    if scans_as_factors == 1
       
        % Get number of factors. ncol - 2 to remove subject # as factor and
        % string with subject scan data
        [~,ncol] = size(all_data2);
        nfactor = ncol - 2 - length(covariates);
        
        for fac = 1:nfactor
            
            % Name of factor - if name has been supplied, use that. If not,
            % it is 'scan'
            if fac <= length(factors)
               matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).name = cell2char(factors(fac));
               matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).dept = 0; 
            else
               matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).name = 'scan';
               matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).dept = 1; 
            end
            
            % Placing into array
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).variance = 1; 
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).gmsca = 0; 
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).ancova = 0;
        end
    else
    
        for fac = 1:length(factors)
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).name = cell2char(factors(fac)); 
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).dept = 0; 
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).variance = 1; 
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).gmsca = 0; 
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(fac).ancova = 0; 
        end
    end
    
    % Placing subjects into design
    for s = 1:length(all_data)
        
        % Subject ID
        subject = cell2char(all_data(s,1));
        
        % Isolating the subject and relevant scans
        subj_data_rows = find(~cellfun('isempty',strfind(all_data2(:,ncol),subject)));
        
        % Adding to subject scan data
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = all_data2(subj_data_rows,ncol);
        
        % Adding factor information
        if scans_as_factors == 0
            if subject_as_factor == 1
                subj_conds = s;
                subj_conds = [subj_conds, all_data2(subj_data_rows,2:(2+length(factors)-2))];
            else
                subj_conds = all_data2(subj_data_rows,2:(2+length(factors)-1));
            end
            
        else
            
            % Removing covariates from columns
            factor_cols = 2:ncol-1;
            if ~isempty(covariates)
                for cv = 1:length(covariates)
                    factor_cols = factor_cols(factor_cols ~= covariates(cv));
                end
            end
            
            subj_conds = all_data2(subj_data_rows,factor_cols);
        end
        
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = cell2mat(subj_conds); 

        % Looping over grouping factors
%         conds = zeros(1,length(factors));
        
%         for fac = 1:length(factors)
%             factor_col = fac + 1;
%             conds(fac) = cell2mat(all_data(s,factor_col));
%         end

        %matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = conds; 
        
    end
    
    % Identifying Interaction or Main Effect
    if (length(factors)+scans_as_factors-subject_as_factor) > 1
        
        % Getting size of data to calculate factor #
        nfactor = length(factors)+scans_as_factors;
        
        % Interaction array; adding variables to it
        inter = zeros(1,nfactor);
        for int = 1:length(inter)
            inter(int) = int;
        end
        
        % Can only do 2 in an interaction, so looping over
        if length(inter) > 2
            
            % Get all combinations of 2 (max for inter) for the factors
            combos = nchoosek(inter, 2);
            
            for c = 1:length(combos)
                matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{c}.inter.fnums = combos(c,:);
            end
            
        else
            
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = inter;
        
        end
        
    else
        
        % If only one factor, use main effects
        if subject_as_factor == 1
             matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
             %matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 2; 
        else
             matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
        end
    end
    
    % Covariate
    if ~isempty(covariates)
        for cov = 1:length(covariates)
            cov_col = 1 + length(factors) - subject_as_factor + cov;
            matlabbatch{1}.spm.stats.factorial_design.cov(cov).c = cell2mat(all_data2(:,cov_col));
            matlabbatch{1}.spm.stats.factorial_design.cov(cov).cname = cell2char(covariate_names(cov));
            matlabbatch{1}.spm.stats.factorial_design.cov(cov).iCFI = 1;
            matlabbatch{1}.spm.stats.factorial_design.cov(cov).iCC = 1;
        end
    else
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {}); % No covariate
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1; % Relative threshold masking with value of 0.8
    end

    % No masking
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    
    % Becuase this is already in t-values, do not need to normalize
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
end
