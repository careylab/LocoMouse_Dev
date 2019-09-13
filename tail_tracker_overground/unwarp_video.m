function vAlign = unwarp_video(v, ind_warp_mapping)
% function fo unwarp video (must be a 3d)
% USAGE:
% str = tt_findbkg(vid)
% 
% INPUTS:
%   vAlign:     3D matrix of video after camera distortion correction
%   t:          as input, it takes a tail cell t tracked on the side view
%               and projects to the bottom view, adding those fields to t
%   split_line: where, in pixel space, the split line between bootom and
%               side views are
% OUTPUTS: 
%   t:          tail tracks

% Diogo Duarte, 2017, Carey lab

nFrames = size(v,3);
expected_im_size = size(ind_warp_mapping);
Img_size = [size(v,1) size(v,2)];

vAlign = zeros([size(ind_warp_mapping) nFrames], 'uint8');

for ii = 1:nFrames
    
    if all(Img_size <= expected_im_size)
        if ~all(Img_size == expected_im_size)
            % If the map is larger than the image, the image is padded with
            % zeros.
            padd_amount = floor((expected_im_size-Img_size)/2);
            Img = padarray(Img, padd_amount, 0,'both');
            Img = padarray(Img, expected_im_size-Img_size-2*padd_amount,...
                0,'post');
        else
            Img = v(:,:,ii);
        end
    else
        % If the map is smaller than the image, the image is cropped to
        % the size of the map.
        error('Image is larger than expected!');
    end
    
    ImgAux = uint8(zeros(size(ind_warp_mapping)));
    ImgAux(:) = Img(ind_warp_mapping(:));
    
    vAlign(:,:,ii) = ImgAux;
    
end

end

%
% if all(Img_size <= expected_im_size)
%     if ~all(Img_size == expected_im_size)
%         % If the map is larger than the image, the image is padded with
%         % zeros.
%         padd_amount = floor((expected_im_size-Img_size)/2);
%         Img = padarray(Img, padd_amount, 0,'both');
%         Img = padarray(Img, expected_im_size-Img_size-2*padd_amount,0,'post');
%     end
% else
%     % If the map is smaller than the image, the image is cropped to
%     % the size of the map.
%     error('Image is larger than expected!');
% end
% 
% ImgAux = uint8(zeros(size(ind_warp_mapping)));
% ImgAux(:) = Img(ind_warp_mapping(:));




% code which failed
% nFrames = size(v,3);
% 
% % sample image
% Img = v(:,:,1);
% 
% vPadded = cell(nFrames, 1);
% 
% expected_im_size = size(ind_warp_mapping);
% Img_size = [size(v,1) size(v,2)];
% if all(Img_size <= expected_im_size)
%     if ~all(Img_size == expected_im_size)
%         for ii = 1:nFrames
%             % If the map is larger than the image, the image is padded with
%             % zeros.
%             padd_amount = floor((expected_im_size-Img_size)/2);
%             vPadded{ii} = padarray(padarray(v(:,:,ii), padd_amount, ...
%                 0,'both'), expected_im_size-Img_size-2*padd_amount,0,...
%                 'post');
%         end
%     else
%         for ii = 1:nFrames
%             vPadded{ii} = zeros(size(Img), 'uint8');
%         end
%     end
% else
%     % If the map is smaller than the image, the image is cropped to
%     % the size of the map.
%     error('Image is larger than expected!');
% end
% 
% % now that Img might have been padded
% 
% vAlign = zeros([size(Img,1) size(Img,2) nFrames], 'uint8');
% 
% for ii = 1:nFrames
%         vAlign(:,:,ii) = reshape(vPadded{ii}(ind_warp_mapping(:)), ...
%                                 [size(Img)]);
% end
