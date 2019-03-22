% file = string of the filename

function zeroing_image(file)

% Read image file
img = spm_vol(file);

% Get 3d array of voxels
img_vol = spm_read_vols(img);

% Remove negative values
for ii = 1:(img.dim(1)*img.dim(2)*img.dim(3))
    
    if img_vol(ii) < 0
       img_vol(ii) = 0;
    end
end

% write out image
spm_write_vol(file,img_vol);


end
