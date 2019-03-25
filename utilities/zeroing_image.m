% file = string of the filename
% whole_brain = location of 1's in whole brain file.

function zeroing_image(file, whole_brain)

%% Read image file and getting voxel values, size, and creating output space
img = spm_vol(file);

% Get 3d array of voxels and activity (> 0)
img_vol = spm_read_vols(img);
[x,y,z] = size(img_vol);
brain_activity = find(img_vol > 0);

% Creating new output
new_activation = zeros(x,y,z);

%% Loop over areas with activity to make sure in brain

for ii = 1:length(brain_activity)
    
    % Getting voxel #
    voxel = brain_activity(ii);
    
    % see if in the brain- if it is, put into new activation
    if ~isempty(find(whole_brain == voxel,1))
        
        % Non brain areas = 0
        new_activation(voxel) = img_vol(voxel);

    end
   
end

%% write out image
spm_write_vol(img,new_activation);


end
