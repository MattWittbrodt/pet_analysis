% file = string of the filename

function zeroing_image(file, whole_brain)

% Read image file
img = spm_vol(file);

% Get 3d array of voxels
img_vol = spm_read_vols(img);
[x,y,z] = size(img_vol);

% Read in Whole Brain File and get location of brain
wb = spm_vol(whole_brain);
wb_vol = spm_read_vols(wb);
wb_location = find(wb_vol == 1);

% Remove negative values and values outside of brain
for ii = 1:(x*y*z)
    
    % see if in the brain- if so, make sure positive
    in_brain = find(wb_location == ii);
    
    if ~isempty(in_brain)
        
        % Making negative values 0
        if img_vol(ii) < 0
           img_vol(ii) = 0;
        end
    else
        % Removing non-brain areas
        img_vol(ii) = 0;
    end
   
end

% write out image
spm_write_vol(file,img_vol);


end
