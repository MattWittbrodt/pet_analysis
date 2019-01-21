% All subjects = file (dataset) with all subjects and conditions to
% subset
% '~/DARPA/script_files/subject_groupings.xlsx'
% subset_col = which column(s) are to be subsetted; 
% subset_value = what the subset is equal to

function filtered_data = filter_data(all_subjects, subset_col, subset_value)
    
    % read file
    d = xlsread(all_subjects);
    
    % use the subset columns to get max
    col_maxes = zeros(length(subset_col),1);
    for ii=1:length(col_maxes)
        col = subset_col(ii);
        m = max(d(:,col));
        col_maxes(ii) = m;
    end
    
    % Get number of combinations & add 1 for all subjects
    % For now, not doing more than 3 
    combinations = [];
    if length(subset_col) == 1
        combinations = col_maxes+1;
    elseif length(subset_col) == 2
        combinations = col_maxes(1)*col_maxes(2) + 1;
    elseif length(subset_col) == 3
        combinations = col_maxes(1)*col_maxes(2)*col_maxes(3) + 1;
    else
        combinations = [];
    end
    
    % 
        
    
    
    
    
        
    
    % Making a local copy of data
    d = all_subjects;
    
    % Using indexing, completing the subset
    filtered_data = d(d(:,subset_col) == subset_value,:);
    
    %return(filtered_data);

end
