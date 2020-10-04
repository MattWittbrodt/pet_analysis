% params:
% x = string of subject ID (generally, name of folder)
% y = string of folder path


function matlabbatch = step_1_1_realign_and_estimate(x,y)

%% First - create cell array with files
subject_search_string = ['*',x,'*.img'];
files = dir(fullfile(y,subject_search_string));

file_array = cell(length(files),1); %Predifine cell array

for i = 1:length(files)
    file_array{i} = [files(i).folder,'\',files(i).name,',1'];
end

%% Mean image export

% Load in raw files (not previously corrected)
matlabbatch{1}.spm.util.imcalc.input = file_array;
                        
% Name output file and directory (z argument)
matlabbatch{1}.spm.util.imcalc.output = [x,'_realign_summed.nii'];
matlabbatch{1}.spm.util.imcalc.outdir = {y};
 
% Create expression - mean of the n images
expression = '(';

for yy=1:length(files)
    str = ['i',num2str(yy)];
    
    if yy < 2
        expression = [expression,str];
    else
        expression = [expression,'+',str];
    end
end

expression = [expression,')/',num2str(length(files))];

%% Enter expression into cell array
matlabbatch{1}.spm.util.imcalc.expression = expression;
 
% Options are kept at default
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
  
end
