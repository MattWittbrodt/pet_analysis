%%%
%%% Converting into table and exporting to comma deliminted .txt
%%% Results = structure from SPM; jar_path = path to .jar file

function tali_table = spm_results_to_tali(results, jar_path)
    
    %% Getting data and adding X,Y, and Z columns
    data = results.dat;
    [nrow, ncol] = size(data);
    
    % Open matrix of 3 * nrow
    coord = zeros(nrow, 3);
    
    for ii = 1:nrow
        
        % Getting cordinates
        c = cell2mat(data(ii,ncol));
        c = transpose(c);
        
        % Placing into the empty array
        coord(ii,:) = c;
    end
    
    %% Replacing Empty cells into NaN, then converting to matrix
    %  and adding coordinates
    
    data(cellfun('isempty',data)) = {NaN};
    
    % Converting to matrix
    data2 = cell2mat(data(:,1:(ncol-1)));
    
    % Adding coordinates
    data2 = [data2, coord];
    [nrow, ncol] = size(data2);
    
    %% Converting the XYZ to Taliarach
    tal_cols = [15,16,17];
    data2(:,tal_cols) = 0;
    
    for col = 1:length(tal_cols)
        
        % row in the matrix
        c = tal_cols(col);
        
        % looping through rows
        for row = 1:nrow
            
            % X
            if col == 1
                data2(row,c) = data2(row,(c-3)) * 0.99;
            % Y
            elseif col == 2
                data2(row,c) = (0.9688*data2(row,(c-3))) + (0.042 * data2(row,(c-2)));
            % Z
            else
                data2(row,c) = (-0.0485*data2(row,(c-1))) + (0.839*data2(row,(c-3)));
            end
            
            % round to whole number
            data2(row,c) = round(data2(row,c),0);
        end
        
    end
    
    %% Getting column names from data
    % names without xyz
    names = results.hdr(1:2,1:length(results.hdr)-1);
    names(1,length(names)+1:length(names)+6) = {NaN};
    names(2,length(names)-5) = {'x'};
    names(2,length(names)-4) = {'y'};
    names(2,length(names)-3) = {'z'};
    names(2,length(names)-2) = {'X_Tal'};
    names(2,length(names)-1) = {'Y_Tal'};
    names(2,length(names)) = {'Z_Tal'};
    
    %% Get Taliarach Names from coordinates
    % Open empty cell array
    area = cell(nrow,1);
    
    % Get XYZ coordinates
    for row = 1:nrow
        
        x = num2str(data2(row, 15));
        y = num2str(data2(row, 16));
        z = num2str(data2(row, 17));
        
        search_coords = [x,', ',y, ', ',z];
        cmd = ['java -classpath ',jar_path, ' org.talairach.PointToTD 4, ',search_coords]; 
        [s,w] = unix(cmd);
    
        % Cleaning up result to only return structure
        ind = findstr(w, 'Returned:');
        w1 = w(ind:end);
        ind = findstr(w1, ':');
        final_str = w1(ind+2:end-1);
        
        % Place into cell array
        area(row) = {final_str};
    end
        
    
    %% Opening file and writing data to it
    spm_results = fopen('~/Desktop/spm_tali.txt','w');
    
    for ii = 1:(nrow+2)
        
        for jj = 1:length(names)
            
            if ii <= 2
                value = cell2char(names(ii,jj));
                if strcmp(value, 'NaN')
                    value = []; 
                end
                fprintf(spm_results, '%s,', value);
            else
                value = data2(ii-2,jj);
                value(isnan(value)) = [];
                fprintf(spm_results, '%d,', value);
            end
        end
        
        if ii <= 2
            fprintf(spm_results, '\n');
        
        else
            % add taliarach description
            fprintf(spm_results, '%s', cell2char(area(ii-2)));
            fprintf(spm_results, '\n');
        end
        
    
    end
    
    %% Writing out a .txt file with only Talirach coordinates
    tali_coords = fopen('~/Desktop/tali_coords.txt','w');
    
    for ii = 1:(nrow+1)
        
        for jj = 1:3
            
            if ii == 1
                value = cell2char(names(2,jj+14));
                fprintf(tali_coords, '%s,', value);
            else
                value = data2(ii-1, jj+14);
                fprintf(tali_coords, '%d,', value);
            end
        end
        
        fprintf(tali_coords, '\n');  
    end
end

