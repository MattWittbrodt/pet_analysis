% All subjects = dataset (double) with all subjects/conditions
% subset_col = which column is to be subsetted
% subset_value = what the subset is equal to

function filtered_data = filter_data(all_subjects, subset_col, subset_value)
    
    % Making a local copy of data
    d = all_subjects;
    
    % Using indexing, completing the subset
    filtered_data = d(d(:,subset_col) == subset_value,:);
    
    %return(filtered_data);

end
