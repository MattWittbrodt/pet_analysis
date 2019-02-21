% function to get voxel data - 2/20
%Identify study and subjects directories
%subj_files = '/Volumes/Seagate/angina/data/pet_data';
%roi_files = '/Volumes/Seagate/ROIs';
%clusters = '/Volumes/Seagate/angina/data/analysis/activation/angina_activation.img';
%activity = string- activation

function roi_values = roi_angina(roi_files, subj_files, clusters, activity)

% Getting list of subjects
subjects = dir(subj_files);
subjects = remove_dots(subjects);
subjects = {subjects.name}.'; % Isolating into a cell array

% Loading Atlas Files and getting the volume counts
masks = dir(fullfile(roi_files,'*.nii'));

% Reading in and getting locations of significant voxels from contrast
cluster_data = spm_vol(clusters);
cluster_data_img = spm_read_vols(cluster_data);

% Putting togeather large dataframe (subjects as rows, areas by colums)
roi_values = zeros(length(subjects),length(masks)+1); % +1 for subject

% Placing Volume counts into the structure
for ii=1:length(masks)
    
    % Load ROI (from AAL atlas)
    roi = spm_vol([masks(ii).folder,'\',masks(ii).name]);
    roi_img = spm_read_vols(roi);
    
    % Enter into the masks structure
    masks(ii).vols = roi_img;
    
    % Mask locations
    mask_location = zeros(1,sum(roi_img(:) == 1));
    mask_count = 1;
    
    % Seeing if the area contains any significantly active clusters
    for jj=1:(79*95*68)
        if roi_img(jj) == 1
            mask_location(mask_count) = jj;
            mask_count = mask_count + 1;
        end
    end
    
    % Place into structure
    masks(ii).vol_location = mask_location;
    
    % Looping over mask locations to see if there is anything in cluster
    for jj=1:length(mask_location)
        if cluster_data_img(mask_location(jj)) == 0
            mask_location(jj) = 0;
        end
    end
    
    % Placing revised ROI/cluster information into structure
    if mean(mask_location) == 0
        masks(ii).vols_in_cluster = [];
    else
        non_zero_mask_location = reshape(nonzeros(mask_location),1,length(nonzeros(mask_location)));
        if length(non_zero_mask_location) >= 6
            masks(ii).vols_in_cluster = non_zero_mask_location;
        else masks(ii).vols_in_cluster = [];
        end
    end   
end

% Looping over subjects to get activation
for ii=1:length(subjects)
    
    % Getting subject into a string
    subj = str2num(cell2mat(subjects(ii)));
    
    % Putting subject data in array
    roi_values(ii,1) = subj;
    
    % Read in activation file
    if activity == "activation"
        contrast = 'con_0001.img';
    else
        contrast = 'con_0002.img';
    end
    
    s = spm_vol([subj_files,'/',num2str(subj),'/',contrast]);
    s_img = spm_read_vols(s);
    
    % Creating empy array for subject
    subject_data = zeros(1,length(masks));
    
    % Next for loop to cycle through masks and get mean areas
    for jj=1:length(masks)
        
        % Mean activation
        mean_activation = 0;
        
        % Looping through ROI/cluster
        if ~isempty(masks(jj).vols_in_cluster)
            
            % Empty mask data
            mask_data = zeros(1,length(masks(jj).vols_in_cluster));
        
            for kk=1:length(masks(jj).vols_in_cluster)
                if s_img(masks(jj).vols_in_cluster(kk)) >= 0
                   mask_data(kk) = s_img(masks(jj).vols_in_cluster(kk));
                end
            end
            
            %Mean of mask data
            mean_activation = mean(mask_data);
        end
        
        % Placing into subject data
        subject_data(jj) = mean_activation;
    end
    
    % Placing subject data in our data
    roi_values(ii,2:size(roi_values,2)) = subject_data;
end

% Writing data out
names = {'subject',masks.name};
data_cell = num2cell(roi_values);
roi_values = [names; data_cell];     %Join cell arrays

end
