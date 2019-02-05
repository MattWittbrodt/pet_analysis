% Information on variables:
% dir = directory where data lives
% data_dir = '/Volumes/Seagate/subs' -- numeric
% data_dir = '/Volumes/Seagate/kasra/regression/waist/activation/regression_clusters'
% ouput = type of output. For now supports 2 types- 'numeric' and 'string'

function list = dir_to_list(data_dir, output)
    
    % Add path to some utilities
    addpath('~/Documents/pet_analysis/utilities/');
    
    % Read in data and remove dots
    d = dir(data_dir);
    d = remove_dots(d);
    
    if strcmp(output, "numeric")
        
        % Putting into a list
        list = zeros(length(d),1);

        for ii = 1:length(list)
            s = str2num(d(ii).name);
            list(ii) = s;
        end
        
    else %meaning strcmp(output, "string") == T
        
        % Putting into a list
        list = strings(5,1);
        
        for ii = 1:length(list)
            s = d(ii).name;
            list(ii) = s;
        end
        
    end
end
    