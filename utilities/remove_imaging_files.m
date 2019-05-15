% x = structure after a 'files' call

function removed = remove_imaging_files(x)

    % Empty dataframe to put dotted folders in
    to_remove = [];

    for ii = 1:length(x)
        % find if the there is a .nii file
        if sum(strfind(x(ii).name,".nii")) >= 1
           to_remove = [to_remove, ii];
        end
        
        % find if there is a .mat file
        if sum(strfind(x(ii).name,".mat")) >= 1
           to_remove = [to_remove, ii];
        end
        
        % find if there is a .img file
        if sum(strfind(x(ii).name,".img")) >= 1
           to_remove = [to_remove, ii];
        end
        
        % find if there is a header (.hdr) file
        if sum(strfind(x(ii).name,".hdr")) >= 1
           to_remove = [to_remove, ii];
        end
        
        % find if there is a text (.txt) file
        if sum(strfind(x(ii).name,".txt")) >= 1
           to_remove = [to_remove, ii];
        end
        
    end
    
    % Removing index variables in matlab
    x(to_remove) = [];
    
    removed = x;
    
end