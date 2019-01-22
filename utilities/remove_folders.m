% x = structure after a 'files' call

function removed = remove_folders(x)

    % Empty dataframe to put dotted folders in
    to_remove = [];

    for ii = 1:length(x)
        % find if the there is a .nii file
        if x(ii).isdir == 1
           to_remove = [to_remove, ii];
        end
    end
    
    % Removing index variables in matlab
    x(to_remove) = [];
    
    removed = x;
    
end