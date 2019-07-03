% x = structure after a 'files' call

function removed = remove_dots(x)

    % Empty dataframe to put dotted folders in
    to_remove = [];

    for ii = 1:length(x)
        % find if the name starts with a period
        if sum(strfind(x(ii).name(1),'.')) == 1
           to_remove = [to_remove, ii];
        end
        
        if sum(strfind(x(ii).name,'~$')) == 1
           to_remove = [to_remove, ii];
        end
    end
    
    % Removing index variables in matlab
    x(to_remove) = [];
    
    removed = x;
    
end