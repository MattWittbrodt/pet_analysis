% All subjects = file (dataset) with all subjects and conditions to
% subset
% test = '~/DARPA/script_files/subject_groupings.xlsx';
% subset_col = which column(s) are to be subsetted; 
% names = cell array of the names of the subset columns ex: {'ptsd','sham'}

function filtered_data = filter_data(all_subjects, subset_col, names)
    
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
    
    % Creating a structure and filling it with dataframes
    % Column 1 = names, 2 = data
    s = cell(combinations,2);
    
    % Loop once for overall data, twice for other data
    for ii = 1:2
        
        %Empty dataframe
        subset_data = [];
        
        % all data
        if ii == 1
            s{1,2} = d;
            s{1,1} = 'all';
        
        else
        
            % Doing the first column first
            for jj=1:length(subset_col)

                % Finding what column & getting max of that column
                c = subset_col(jj);
                mx = max(d(:,c));
                mn = min(d(:,c));
                levels = [mn:mx];

                % Lopping through all options from max-min
                for kk=1:length(levels)
                    subset_value = levels(kk);

                    % Subset dataframe and placing name into structure
                    index = jj+kk;
                    
                    % Finding where to put the data - there may be some
                    % overlap the way its coded (could improve)
                    if ~isempty(s{index,2})
                        index = index + 1;
                    end
                    
                    subset_data = d(d(:,c) == subset_value,:);
                    s{index,2} = subset_data;
                    s{index,1} = [names{jj},'_',num2str(subset_value)];
                end
            end
        end
    end
    
    % Returning filtered_data
    filtered_data = s;
    
end
