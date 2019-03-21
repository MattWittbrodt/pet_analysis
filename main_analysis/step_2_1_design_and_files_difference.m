% subjects = cell array with subject IDs (with scan data)
% subject groupings = array with subject IDs and groupings
% subject_files = location of raw PET data
% analysis_type = string- generally 'activation' or 'deactivation'
% factors = what are the factors. Equal to n columns - 1 from subject_groupings 

function matlabbatch = step_2_1_design_and_files_difference(subjects,subject_groupings, subject_files,analysis_type, factors)
    
    %% Getting list of subjects with groupings and scan data
    
    
    % Reading in data about subject groupings, then getting appropriate group
    group_data = xlsread([analysis_files,'subject_groupings.xlsx'],'Sheet1');
    
    % Routine to remove subjects in groupings file but no scans
    rows_to_delete = [];
    
    for ii = 1:length(group_data)
        s = num2str(group_data(ii));

            % Check if subject is in the analysis, if not, skip
            check_if_subject = find(strcmp(subjects, s), 1);
            if isempty(check_if_subject) == 1
                rows_to_delete = [rows_to_delete; ii];
            end
    end
    
    % Removing rows
    group_data(rows_to_delete,:) = [];
    
    % --------------------------------------------------------------------
    % Second, looping over the types of analyses (activation, 
    % deactivation, etc) & creating the designs
    % --------------------------------------------------------------------
    ptsd = cell(length(group_data(group_data(:,2) == 1)),1);
    non_ptsd = cell(length(group_data(group_data(:,2) == 2)),1);
           
    for jj = 1:2 %1 = PTSD, 2 = No_PTSD

        % Creating subset for each condition with subject IDs
        d = group_data(group_data(:,2) == jj);

        % Get files
        for kk = 1:length(d)
            s = num2str(d(kk)); % get subject #

            % Activation during trauma scripts deal with con_0001 (from first level),
            % deactivation is the con_0002 images
            if strcmp(analysis_type,'activation') || strcmp(analysis_type,'activation_contrast')       
                contrast = 'con_0001.img';
            else
                contrast = 'con_0002.img';
            end
           
            % Retrieving file
            file = [subject_dir,s,'\', contrast];
            if jj == 1
                ptsd{kk} = [file,',1'];
            else
                non_ptsd{kk} = [file,',1'];
            end
        end
    end

            
    %% Setting Up Flexible Factorial Design
       
    % Identifying correct directory
    matlabbatch{1}.spm.stats.factorial_design.dir = {[analysis_files,analysis_type]};
    
    % Need to change analysis - act/deactivation using Flexible Factorial, 
    % using 2 factors - PTSD and Sham / Active VNS
    all_scans = [ptsd; non_ptsd];
    % if strcmp(analysis_type,'activation') || strcmp(analysis_type,'deactivation')
    % matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = all_scans;
    
    %else % for now, ignoring the activation / deactive and working with contrast TODO: MAKE ACTIVATION CONTRAST -> CONTRAST  
        
        % Looping over all subjects to place into design
        for i = 1:length(subjects)
        
            subject = char(subjects(i));
    
            % Getting activation (0001) or deactivation (0002) contrast
            if strcmp(analysis_type,'activation')       
                contrast = 'con_0001.img';
            else
                contrast = 'con_0002.img';
            end
           
            % Retrieving file & placing into matlab cell array for analysis
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = ...
               cellstr([subject_dir,subject,'\', contrast, ',1']);
            
            % Secondly, need to get conditions
            matched_row = find(group_data == str2num(subject));
            conds = group_data(matched_row,2:3);
            matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = conds;     
            
        end
        
        % First factor is PTSD status
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'ptsd';
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
        
        % Second factor is VNS
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'VNS';
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
        
        % Identifying Interaction
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [1 2];
        
    %end
        
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
