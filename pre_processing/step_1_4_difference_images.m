function matlabbatch = step_1_4_difference_images(subject, subj_files, scan_characteristics, measure_name)

    %% Pre-computing variables for input into batch file
    
    % Creating directory string
    subj_dir = [subj_files,subject,'/'];

    % Getting subjects scans - this routine loads scans, opens array, then
    % places into it
    scans = dir(fullfile(subj_dir,'sw*.img'));
    file_array = cell(length(scans),1); %Predifine cell array

    for i = 1:length(scans)
        file_array{i} = [scans(i).folder,'/',scans(i).name,',1'];
    end
    
    %% Creating condition array for scans
    
    % Creating condition array for scans
    condition_array = [];

    for yy = 1:length(file_array)
        scan_name = file_array{yy};
        scan_index = str2num(cell2mat(extractBetween(file_array(yy),"_w","_")));
        condition_array(yy,1) = scan_characteristics(scan_index,2);
    end
    
    
    %% Completing batch file
    
    % STEP 1: Factorial Design Specification
    matlabbatch{1}.spm.stats.factorial_design.dir = {subj_dir};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.name = measure_name;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.dept = 1; % dependence
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac.variance = 1; %Unequal
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
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep; % Using the depedency feature
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'Factorial design specification: SPM.mat File';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    %% Creating contrasts estimation
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep; % Again, using dependency feature for the model estimation .mat
    matlabbatch{3}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{3}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
    matlabbatch{3}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{3}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = [measure_name, '_activation']; % First contrast is the activation (stress > control)
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = [measure_name, '_deactivation']; % Second is the deactivation (control > stress)
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'overall'; % Third is a weight average of the two (suggested via SPM Wiki)
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [1 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
end