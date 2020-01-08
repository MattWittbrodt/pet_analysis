% Information on variables:
% subject_data = location of subject data - '/Volumes/Seagate/subs'
% area_mask = location and name of .nii mask for area
% '/Volumes/Seagate/kasra/regression/waist/activation/regression_clusters'
% contrast_name = name of images for the individual - e.g., 'con_0001.img' 
% regressor_dir = location of .xlsx file with regressor information -
% regressor_col - what column holds data (assumes col #1 is subject ID)
% output_dir = output directory for .xlsx
% name for what the variable is called - name of text output

function regression_data = regression_cluster_data_from_area_mask(...
                                                   subject_data,...
                                                   area_mask, ...
                                                   contrast_name,...
                                                   regressor_file,...
                                                   regressor_col,...
                                                   output_dir,...
                                                   name)
    
    % Add path to some utilities
    addpath('C:/Users/mattw/Documents/pet_analysis/utilities/');
    
    % Read in subject data
    sub = dir_to_list(subject_data, 'numeric');
    
    % Masks into cell array
    m = dir_to_list(area_mask, 'string'); 

    % Loop through masks to get data
    regression_data = zeros(length(sub),(2+length(m)));
    
    % Load regressor file
    r = xlsread(regressor_file);
    
    % Initiate Loop over masks
    for ii = 1:length(m)
        
        % Read in mask, get header, then the 3D matrix with 0 & 1, then
        % index of 1's
        mask = [area_mask,'/',str2mat(m(ii))];
        mask = spm_vol(mask);
        mask_img = spm_read_vols(mask);
        mask_voxels = find(mask_img);
        
        % Using index, read over subjects to get mean activation
        for jj = 1:length(sub)
            
            s = sub(jj);
            
            % Addind subject number to array
            regression_data(jj,1) = s;
            
            % Getting file name, reading in, reading voxels
            sub_data = [subject_data,'/',num2str(s),'/',contrast_name];
            
            if exist(sub_data,'file')
                sub_vol = spm_vol(sub_data);
                sub_vol_img = spm_read_vols(sub_vol);
                        
                % Loop through the masked areas
                activation = zeros(length(mask_voxels),1);

                for kk = 1:length(mask_voxels)

                    % Get index number for mask
                    index = mask_voxels(kk);

                    % Place activation from subject into 'activation'
                    activation(kk) = sub_vol_img(index);
                end
            
                % Find mean of activation
                activation_mean = mean(activation);

                % Place into array
                regression_data(jj,2+ii) = activation_mean;

                % Finding regressor
                row = find(r(:,1) == s);

                if ~isempty(row)
                    regression_data(jj,2) = r(row,regressor_col);
                else
                    regression_data(jj,2) = NaN;
                end
            end
        end
        
    end
    
    % writing getting column header into a cell array
    col_header = transpose(["subject"; string(name); m]);
    col_header = convertStringsToChars(col_header);
    
    combined_df = [col_header; num2cell(regression_data)];
    
    %csvwrite([output_dir,'/',name,'.csv'], combined_df);
    % Opening text file
    fid = fopen([output_dir,'/',name,'.txt'], 'w');
    
    [nrows,ncols] = size(combined_df);
    
    for row = 1:nrows
        if row == 1
           for col = 1:ncols
                fprintf(fid,'%s,',combined_df{row,col});
           end
        else
            for col = 1:ncols
                fprintf(fid,'%d,',combined_df{row,col});
            end
        end
        fprintf(fid,'\n');
    end
    
    
end
