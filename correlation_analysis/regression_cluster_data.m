% Information on variables:
% subjects_data = directory where subject data lives
% subject_data = '/Volumes/Seagate/subs'
% mask_data = '/Volumes/Seagate/kasra/regression/waist/activation/regression_clusters'
% contrast_name = name of images for the individual; 'con_0001.img' /'con_0001_zeroed.img' is
% activation, 'con_0002.img' is deactivation.

function regression_data = regression_cluster_data(subject_data, mask_data, contrast_name)
    
    % Add path to some utilities
    addpath('~/Documents/pet_analysis/utilities/');
    
    % Read in subject data
    sub = dir_to_list(subject_data, 'numeric');
    
    % Masks into cell array
    m = dir_to_list(mask_data, 'string'); 

    % Loop through masks to get data
    regression_data = zeros(length(sub),(1+length(m)));
    
    % Initiate Loop over masks
    for ii = 1:length(m)
        
        % Read in mask, get header, then the 3D matrix with 0 & 1, then
        % index of 1's
        mask = [mask_data,'/',str2mat(m(ii))];
        mask = spm_vol(mask);
        mask_img = spm_read_vols(mask);
        mask_voxels = find(mask_img);
        
        % Using index, read over subjects to get mean activation
        for jj = 1:length(sub)
            
            % Addind subject number to array
            regression_data(jj,1) = sub(jj);
            
            % Getting file name, reading in, reading voxels
            sub_data = [subject_data,'/',num2str(sub(jj)),'/',contrast_name];
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
            regression_data(jj,1+ii) = activation_mean;
        end
        
    end
    
end
