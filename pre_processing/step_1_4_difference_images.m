% Contrasts = matrix with the excel file contrasts

function matlabbatch = step_1_4_difference_images(subject, subj_files, scan_characteristics, measure_name, contrasts, var)
    
    %%
    
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
            contrast_matrix(:,ii) = 0;
        end
    end
    
    for ii = 1:nrow
        s = sum(contrast_matrix(ii,:));
        if s ~= 0
           contrast_matrix(ii,:) = 0;
        end
    end
           
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
    [nrow,ncol] = size(contrasts);

    % Iterate over all contrasts
    for ii = 1:nrow
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.name = char(contrasts(ii));
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.convec = cell2mat(contrasts(ii,2:ncol));
        matlabbatch{3}.spm.stats.con.consess{ii}.tcon.sessrep = 'none';
    end
    
    % Do not delete after finishing
    matlabbatch{3}.spm.stats.con.delete = 0;
    
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = [measure_name, '_activation']; % First contrast is the activation (stress > control)
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [-1 1];
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = [measure_name, '_deactivation']; % Second is the deactivation (control > stress)
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [1 -1];
%     matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'overall'; % Third is a weight average of the two (suggested via SPM Wiki)
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [1 1];
%     matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
%     matlabbatch{3}.spm.stats.con.delete = 0;
    
end