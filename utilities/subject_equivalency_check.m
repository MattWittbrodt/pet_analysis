% Function for removing subjects from groupings where there is no data
% groupings = subject groupings (double) from script. Subject number should
% be first column
% files = cell array with subject names (takem from raw PET file directory)

function [subj,file] = subject_equivalency_check(groupings, files)
    
    if length(groupings) < length(files)
        % First, checking for subjects with files that we have grouping information for 
        to_remove = [];
        for ii = 1:length(groupings)

            % Getting subject from grouping object
            sub = groupings(ii,1);

            % Looping through subjects cell array to see if subject data is
            % available. If so, do nothing. If not, add subject to remove
            in_files = 0;
            for jj=1:length(files)
                if strcmp(files{jj},num2str(sub)) == 1
                    in_files = 1;
                end
            end

            % Look at in_files, if = 0, add to matrix to remove
            if in_files == 0
                to_remove = [to_remove, ii];
            end

        end

        % Remove subjects who have grouping data but no PET data
        new_subject_groupings = groupings;
        new_subject_groupings(to_remove,:) = [];
        
        % Remove subjects from files as well
        to_remove = [];
        for jj = 1:length(files)
            
            sub = str2num(files{jj});
            
            if isempty(find(new_subject_groupings(:,1) == sub))
                to_remove = [to_remove, jj];
            end
            
        end
        
        % Remove
        new_files = files;
        new_files(to_remove) = [];
    
    subj = new_subject_groupings;
    file = new_files;
end
