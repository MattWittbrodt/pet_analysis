% file = string of the filename
% whole_brain = location of 1's in whole brain file.

function zeroing_image(file, whole_brain)

%% Read image file and getting voxel values, size, and creating output space
img = spm_vol(file);

% Get 3d array of voxels and activity (> 0)
img_vol = spm_read_vols(img);
[x,y,z] = size(img_vol);

% Finding areas <= 0 or NaN and making 0; making into 2d array
brain_activity = img_vol;
brain_activity(img_vol <= 0) = 0;
brain_activity(isnan(brain_activity)) = 0;
brain_activity = brain_activity(:);

% Making a logical vector with areas with activity - using t score of 
brain_acitivity_inds = brain_activity;
brain_acitivity_inds(brain_acitivity_inds > 5) = 1;

% Creating area with brain activity and adding 1's where whole brain is
brain_inds = zeros(length(brain_activity), 1);
brain_inds(whole_brain) = 1;

% Making a new activiation map- logical vector including activity and whole
% brain
new_activation_inds = logical(brain_inds) & logical(brain_acitivity_inds);

% Making areas without activity into 0's in vector and adding the activity
% values
new_activation = brain_activity;
new_activation(~new_activation_inds) = 0;
new_activation = reshape(new_activation, x, y, z);


% % Creating new output
% new_activation = zeros(x,y,z);
% 
% %% Loop over areas with activity to make sure in brain
% 
% for ii = 1:length(brain_activity)
%     
%     % Getting voxel #
%     voxel = brain_activity(ii);
%     
%     % see if in the brain- if it is, put into new activation
%     if ~isempty(find(whole_brain == voxel,1))
%         
%         % Non brain areas = 0
%         new_activation(voxel) = img_vol(voxel);
% 
%     end
%    
% end

%% write out image
spm_write_vol(img,new_activation);


end

% brain_acitivity_inds = brain_activity;
% brain_acitivity_inds(brain_acitivity_inds > 0) = 1;
% 
% brain_inds = zeros(length(brain_activity), 1);
% brain_inds(whole_brain) = 1;
% 
% new_activation_inds = logical(brain_inds) & logical(brain_acitivity_inds);
% new_activation = brain_activity;
% new_activation(~new_activation_inds) = 0;
% new_activation = reshape(new_activation, x, y, z);

