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
    
%     % Reading in data about subject groupings, then getting appropriate group
%     group_data = xlsread([analysis_files,'subject_groupings.xlsx'],'Sheet1');
    
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
    
    % Looping over subjects to get scan data   
    for jj = 1:length(all_data)
        
        % Getting subject
        s = cell2char(subjects(jj));
        
        % Getting contrast
        if strcmp(analysis_type,'activation') || strcmp(analysis_type,'activation_contrast')       
                contrast = 'con_0001.img';
        else
                contrast = 'con_0002.img';
        end
        
        % Retrieving file
        file = [subject_files,'/',s,'/', contrast,',1'];
        
        % Placing into cell array
        all_data{jj,1} = file;
    end      
        % Placing file in cell array
        
%         if jj == 1
%            ptsd{kk} = [file,',1'];
%         else
%            non_ptsd{kk} = [file,',1'];
%         end
    
    
%     ptsd = cell(length(group_data(group_data(:,2) == 1)),1);
%     non_ptsd = cell(length(group_data(group_data(:,2) == 2)),1);
           
%     for jj = 1:2 %1 = PTSD, 2 = No_PTSD
% 
%         % Creating subset for each condition with subject IDs
%         d = group_data(group_data(:,2) == jj);
% 
%         % Get files
%         for kk = 1:length(d)
%             s = num2str(d(kk)); % get subject #
% 
%             % Activation during trauma scripts deal with con_0001 (from first level),
%             % deactivation is the con_0002 images
% %             if strcmp(analysis_type,'activation') || strcmp(analysis_type,'activation_contrast')       
% %                 contrast = 'con_0001.img';
% %             else
% %                 contrast = 'con_0002.img';
% %             end
%            
%             % Retrieving file
%             file = [subject_dir,s,'\', contrast,',1'];
%             if jj == 1
%                 ptsd{kk} = [file,',1'];
%             else
%                 non_ptsd{kk} = [file,',1'];
%             end
%         end
%     end

            
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
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = cell2char(all_data(s,1)); 
        
        % Looping over grouping factors
        conds = zeros(1,length(factors));
        
        for fac = 1:length(factors)
            factor_col = fac + 1;
            conds(fac) = cell2mat(all_data(s,factor_col));
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
        

    
end
