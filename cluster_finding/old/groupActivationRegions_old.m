function [] = groupActivationRegions(contrast, avg_mat, sigma, min_t, min_t_filt, isPlot)

%% Save the original mat function

contrast_orig = contrast;
%contrast_orig(contrast_orig < 2) = 0;
contrast = contrast_orig;

%% Zero the values in invalid regions

% Zero the voxels that are invalid activation regions
avg_mat(avg_mat < 1.3) = 0; %was 0
avg_mat = imgaussfilt3(avg_mat, 4.5);
%contrast(avg_mat == 0) = 0; % Removes areas not included in the average activation

%% Threshold the contrast image with the average image

% for ii=1:(79*95*68)
%      if avg_mat(ii) > 0
%          if contrast(ii) >= 2.3
%             contrast(ii) = contrast(ii);
%          else
%              contrast(ii) = 0;
%          end
%      else
%          contrast(ii) = 0;
%      end
% end

%% Threshold for minimum t-values

% imag_mat(imag_mat<min_t) = 0;

%% Apply Gaussian LPF

%contrast = imgaussfilt3(contrast, sigma);

%% Threshold the image again and create binary

imag_mat_bin = contrast;
imag_mat_bin(imag_mat_bin<min_t_filt) = 0;
imag_mat_bin(imag_mat_bin>0) = 1;

%% Find connected blobs
% https://www.mathworks.com/help/images/ref/bwconncomp.html#bu2vpxm-1-CC
% CC = bwconncomp(BW)
% S = regionprops(CC,'Centroid');
% Step 1- make image binary for function
avg_img_test = avg_img;
avg_img_test(avg_img_test > 0) = 1;


%% Plot the original vs new image

% if(isPlot)
%     [x, y, z] = size(imag_mat);
%     [xx, yy, zz] = meshgrid(1:x, 1:y, 1:z);
%     
%     
%     
%     figure;
%         plot_activation_helper(imag_mat_orig(:), xx(:), yy(:), zz(:));
%         title('Original Image');
%     figure;
%         plot_activation_helper(imag_mat(:), xx(:), yy(:), zz(:));
%         title('Filtered Image');
%     figure;
%         plot_activation_helper(imag_mat_bin(:), xx(:), yy(:), zz(:));
%         title('Filtered Binary Image');
% end

if(isPlot)
    [x, y, z] = size(contrast);
    [xx, yy, ~] = meshgrid(1:x, 1:y, 1:z);
    xx = xx(:, :, 1)';
    yy = yy(:, :, 1)';

    
    clims = [min([contrast_orig(:); contrast(:); imag_mat_bin(:)]),...
             max([contrast_orig(:); contrast(:); imag_mat_bin(:)])];
    
    for ii=1:z
        figure(99);
            imagesc(contrast_orig(:, :, ii), clims);
            title(['Original n=' num2str(ii)]);
%         figure(100);
%             imagesc(imag_mat(:, :, ii), clims);
%             title(['Filtered n=' num2str(ii)]);
%         figure(101);
%             imagesc(imag_mat_bin(:, :, ii), clims);
%             title(['Binary n=' num2str(ii)]);
        figure(102);
            hold on;
            imagesc(contrast(:, :, ii), clims);
            ind = imag_mat_bin(:, :, ii);
            plot(yy(logical(ind)), xx(logical(ind)), 'r.', 'MarkerSize', 10);
            title(['Binary n=' num2str(ii)]);
            hold off;
        pause(0.2);
    end
end

end



function [] = plot_activation_helper(data, x_cord, y_cord, z_cord)

num_colors = 64;

data_norm = (data-min(data))/(max(data)-min(data));

ran = range(data_norm);
ran = range(data_norm); 
min_val = min(data_norm);
max_val = max(data_norm);

color_ind = floor(((data_norm-min_val)/ran)*(num_colors-1)) + 1; 
all_colors = jet(num_colors);

color_vals = all_colors(color_ind, :);


scatter3(x_cord, y_cord, z_cord, [], color_vals, '.');
colormap jet;
colorbar;


end



