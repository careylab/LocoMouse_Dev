function t = tail_track_2views(vidnobkg, split_line, ind_warp_mapping)
% function for tracking tail on the side view. video matrix should be
% passed to this function with background subtraction done already
% INPUTS:
%   vidnobkg:           3D matrix of video after background subtraction
%   split_line:         split line row
%   ind_warp_mapping:   tranformation between views. not being used
% OUTPUTS:
%   t:                  tail tracks

% Diogo Duarte, 2017, Carey lab

verbose = 0;

[h, w, n_frames] = size(vidnobkg);

tracks_tail_c   = zeros(3,15,n_frames);
tracks_tail     = zeros(4,15,n_frames);
regs_bottom     = cell(n_frames, 1);
regs_side       = cell(n_frames, 1);
t               = cell(n_frames, 1);
skel_side       = false(size(vidnobkg));
skel_bottom     = false(size(vidnobkg));
tail_idx_side   = cell(n_frames,1);
tail_idx_bottom = cell(n_frames,1);

% ..............  split the 2 views ...................................

% side view
vidnobkg_side = vidnobkg;
vidnobkg_side(split_line:end,:,:) = zeros(size(vidnobkg_side(...
                                    split_line:end,:,:)), class(vidnobkg));

% bottom view
vidnobkg_bottom = vidnobkg;
vidnobkg_bottom(1:split_line,:,:) = zeros(size(vidnobkg_side(...
                                    1:split_line,:,:)), class(vidnobkg));
                                
vidnobkg_side_b = false(size(vidnobkg_side));
vidnobkg_bottom_b = false(size(vidnobkg_bottom));

for ii = 1:n_frames
    
%     if ii==837
%         keyboard;
%     end
    

    % cut frame to view of interest
%     vidnobkg(split_line:end,:,ii) = zeros(1, class(vidnobkg));
    
    % smooth frame
    sigma = 2; % width of gaussian filter in pixels
%     vidnobkg_side(:,:,ii)   = imgaussfilt(vidnobkg_side(:,:,ii), sigma);
%     vidnobkg_bottom(:,:,ii) = imgaussfilt(vidnobkg_bottom(:,:,ii), sigma);
%     
% %     sharpen video?
%     vidnobkg_side(:,:,ii) = imsharpen(vidnobkg_side(:,:,ii), 'amount', ...
%                             2, 'radius', 1, 'threshold', 0);
%     vidnobkg_bottom(:,:,ii) = imsharpen(vidnobkg_bottom(:,:,ii),...
%                                 'amount', 2, 'radius', 1, 'threshold', 0);
    
    % binarize it (threshold)
    vidnobkg_side_b(:,:,ii)   = im2bw(vidnobkg_side(:,:,ii), ...
                                    graythresh(vidnobkg_side(:,:,ii)));
    vidnobkg_bottom_b(:,:,ii) = im2bw(vidnobkg_bottom(:,:,ii), ...
                                    graythresh(vidnobkg_bottom(:,:,ii)));
    % thin?
%     vidnobkg(:,:,ii) = bwmorph(vidnobkg(:,:,ii),'thin',Inf);

    
    
    % skeletonize / thin
    skel_side(:,:,ii)   = bwmorph(vidnobkg_side_b(:,:,ii),'thin',Inf);
%     skel_bottom(:,:,ii) = bwmorph(vidnobkg_bottom_b(:,:,ii),'thin',Inf);
%     skel_side(:,:,ii)   = bwmorph(skel_side(:,:,ii),'skel',Inf);
    skel_bottom(:,:,ii) = bwmorph(vidnobkg_bottom_b(:,:,ii),'skel',Inf);
    
%     if ii==234 % 117
%         keyboard;
%     end
    
    % wipe out branch points on side and bottom view 
    skel_side(:,:,ii)       = wipe_out_branchpoints(skel_side(:,:,ii));
    skel_bottom(:,:,ii)     = wipe_out_branchpoints(skel_bottom(:,:,ii));
    
    % get binary region properties 
    regs_side{ii} = regionprops(skel_side(:,:,ii), 'MajorAxisLength', ...
                                         'PixelIdxList', ...
                                         'Centroid', ...
                                         'PixelList');
    regs_bottom{ii} = regionprops(skel_bottom(:,:,ii),'MajorAxisLength',...
                                         'PixelIdxList', ...
                                         'Centroid', ...
                                         'PixelList');
                                     
    % find object(s) most likely to be a tail
    [tail_idx_side{ii},tobj_s]      = tail_finder_from_regionprops( ...
                                        regs_side{ii}, h, w, 'side');
    [tail_idx_bottom{ii},tobj_b]    = tail_finder_from_regionprops( ...
                                        regs_bottom{ii}, h, w, 'bottom');
%     restrict_to_smoothest_line( regs_side{ii},  regs_bottom{ii}, ...
%                                     tobj_s,         tobj_b , h, w);               
    
    % get x and z (side view) indices for that object
%     [t{ii}.zs,t{ii}.xs] = ind2sub([h w],tail_idx_side{ii});
%     [t{ii}.yb,t{ii}.xb] = ind2sub([h w],tail_idx_bottom{ii});
    [t{ii}.zs,t{ii}.xs] = ind2sub([h w],tail_idx_side{ii});
    [t{ii}.yb,t{ii}.xb] = ind2sub([h w],tail_idx_bottom{ii});
    
    if verbose
        fprintf('Frame: %g / %g\n', ii, n_frames);
    end
    
    
    % .....  exclude what is not a tail (body)  ...........................
    % look for blurred, smoothed body line and use it as a boundary from
    % which tail is excluded
    
end
   
% ...........  clean tail line  .......................................
% go from the tip and if there is a branch, go with the one with the
% least gradient
% t = restrict_to_smoothest_line( t );

end



