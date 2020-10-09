% subject | character of subject name - in my pipelines I extracted from data folders, so it reflected name of folder
% subject_files | path where individual subject data goes
% scan_characteristics | A double with size n x 2, where n = number of different HR-PET scans
% measure_name| a string with the name of stress intervention. For use in the contrast specification
% contrasts| detailed below; individual contrast specifications
% var | 0 or 1 - equal variance. Default runs with 1 in individual model specification; 0 will run otherwise
% contrast_sum| a double of length n where n = number of contrasts specified. In the double is the sum of the contrasts. For examples, a contrast testing if A is greater than B would be [-1 1] for a contrast sum of 0. A contrast just looking at activation of A would be [1 0] (B is disregarded) and therefore has a contrast sum of 0.

function matlabbatch = step_1_4_difference_images(subject, subj_files, scan_characteristics, measure_name, contrasts, var, contrast_sum)
    
    %% Creating Error Text File
    fileID = fopen([subj_files,'subject_errors.txt'],'a');
    
    %% Pre-computing variables for input into batch file
    
    % Creating directory string
    subj_dir = [subj_files,subject,'/'];

    % Getting subjects scans - this routine loads scans, opens array, then
    % places into it
    scans = dir(fullfile(subj_dir,'sw*.img'));
    file_array = cell(length(scans),1); %Predifine cell array
    scan_count = zeros(length(scans),1); % Getting length of zeros
    
    for i = 1:length(scans)
        file_array{i} = [scans(i).folder,'/',scans(i).name,',1'];
        
        % Using Regex to find scan numbers, then placing into zeros
        scan_numbers = regexp(scans(i).name,'[0-9]*','match');
        scan_count(i) = str2num(scan_numbers{1,2});
    end
    
    %% Creating condition array for scans
    condition_array = [];

    for yy = 1:length(file_array)
        scan_name = file_array{yy};
        scan_index = str2num(cell2mat(extractBetween(file_array(yy),"_w","_")));
        condition_array(yy,1) = scan_characteristics(scan_index,2);
    end
    
    %% Checking that all contrasts are there for each subject
    % Getting size of contrast matrix
    [~,ncol] = size(contrasts);
    contrast_matrix = cell2mat(contrasts(:,2:ncol));
    [nrow,ncol] = size(contrast_matrix);
    
    % Getting contrasts in subject data
    scan_available = unique(condition_array);
    
    % Looping through contrast matrix to see if contrast is there- if not,
    % chaing to zeroes. Then, making sure each contrast = 0. If not,
    % deleting
    for ii = 1:ncol
        test = scan_available == ii;
        if sum(test) < 1
            contrast_matrix(:,ii) = NaN;
            fprintf(fileID,'Subject %s has no scans for condition %d',subject,ii);
            fprintf(fileID,'\n');
        end
    end
    
    % Removing the columns with issues
    contrast_matrix(:,any(isnan(contrast_matrix))) = [];
    
    % Checking for incomplete contrasts or all 0's
    for ii = 1:nrow
        s = sum(contrast_matrix(ii,:));
        m = max(contrast_matrix(ii,:));
        
        if s ~= contrast_sum(ii) || m < 1
           contrast_matrix(ii,:) = NaN;
           fprintf(fileID,'Subject %s has no contrast %d',subject,ii);
           fprintf(fileID,'\n');
        end
    end
    
    % Removing the rows with issues
    contrast_matrix(any(isnan(contrast_matrix),2),:) = [];
           
    %% Completing batch file
    matlabbatch{1}.spm.stats.factorial_design.dir = {subj_dir};     
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.name = measure_name;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.dept = 1; % dependence
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.variance = var; %Unequal
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.gmsca = 1; %Include grand mean scaling
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.ancova = 0; %No ANCOVA
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject.scans = file_array;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject.conds = condition_array;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1; %For the main effect
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {}); % No covariance
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1; %No threshold masking
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1; %Yes for implicit mask
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''}; % No explicit mask
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_mean = 1; % Yes for grand mean scaling
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_yes.gmscv = 50; % using 50 as the value
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 2; % Using proportional normalization
    
    %% Model Estimation - this is pretty vanilla
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[subj_dir,'SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    %% Creating contrasts estimation
    matlabbatch{3}.spm.stats.con.spmmat = {[subj_dir,'SPM.mat']};

    % Get number of rows in contrast file
    [nrow,~] = size(contrast_matrix);

    % Iterate over all contrasts
    for ii = 1:nrow
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.name = char(contrasts(ii));
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.convec = contrast_matrix(ii,:);
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.sessrep = 'none';
    end
    
    % Do not delete after finishing
    matlabbatch{3}.spm.stats.con.delete = 0;
    
    % Closing Error File
    fclose(fileID);
    
end