function t = tail_track_sideview(vidnobkg, split_line, ind_warp_mapping)
% function for tracking tail on the side view. video matrix should be
% passed to this function with background subtraction done already
% INPUTS:
%   vidnobkg:           3D matrix of video after background subtraction
%   split_line:         split line row
%   ind_warp_mapping:   tranformation between views. not being used
% OUTPUTS:
%   t:                  tail tracks

% Diogo Duarte, 2017, Carey lab

[h, w, n_frames] = size(vidnobkg);

tracks_tail_c   = zeros(3,15,n_frames);
tracks_tail     = zeros(4,15,n_frames);
regs            = cell(n_frames, 1);
t               = cell(n_frames, 1);
skel            = false(size(vidnobkg));

for ii = 1:n_frames
    
%     if ii==100
%         keyboard;
%     end
    
    % cut frame to view of interest
    vidnobkg(split_line:end,:,ii) = zeros(1, class(vidnobkg));
    
    % smooth frame
    sigma = 2; % width of gaussian filter in pixels
    vidnobkg(:,:,ii) = imgaussfilt(vidnobkg(:,:,ii), sigma);
    
%     sharpen video?
    vidnobkg(:,:,ii) = imsharpen(vidnobkg(:,:,ii), 'amount', 2, ...
                                 'radius', 1, 'threshold', 0);
    
    % binarize it (threshold)
    vidnobkg(:,:,ii) = im2bw(vidnobkg(:,:,ii), ...
                            graythresh(vidnobkg(:,:,ii)));
    
    % thin?
%     vidnobkg(:,:,ii) = bwmorph(vidnobkg(:,:,ii),'thin',Inf);
    skel(:,:,ii) = bwmorph(vidnobkg(:,:,ii),'thin',Inf);
    
    % get binary region properties
    regs{ii} = regionprops(skel(:,:,ii), 'MajorAxisLength', ...
                                         'PixelIdxList', ...
                                         'Centroid');
    
    % find object(s) most likely to be a tail
    tail_idx = tail_finder_from_regionprops( regs{ii},h,w , 'side');
    
    % get x and z (side view) indices for that object
%     [t{ii}.xs,t{ii}.zs] = ind2sub([h w],tail_idx);
    [t{ii}.zs,t{ii}.xs] = ind2sub([h w],tail_idx);
end
   

% overlay them

    
%     malength = [];
%     this_frame = vidnobkg(:,:,ii);
%     
%     % for now hidding the bottom view
%     this_frame(1:split_line,:) = zeros(1, class(this_frame));
%     
%     tobin = imsharpen(this_frame, 'amount', 2, 'radius', 1, ...
%                                   'threshold', 0);
%     samplebin = im2bw(tobin, graythresh(tobin));
%     thinned = bwmorph(samplebin,'thin',Inf);
%     CC = bwconncomp(thinned);
%     % get properties of objects inside the figure
%     stats = regionprops(CC,'MajorAxisLength', 'PixelIdxList');
%     % select longest object
%     for jj = 1:numel(stats)
%         % ugly programming is ugly
%         malength = [malength stats(jj).MajorAxisLength];
%     end
%     [~,obj_num] = max(malength);
%     tail_idx = stats(obj_num).PixelIdxList;
%     [x,y] = ind2sub([size(v,1) size(v,2)],tail_idx);
%     x15 = linspace(min(x), max(x), 15);
%     y15 = y(find(x15));
%     tracks_tail_c(1,:,ii) = x15;
%     tracks_tail_c(2,:,ii) = y15;
%     tracks_tail(1,:,ii) = x15;
%     tracks_tail(2,:,ii) = y15;
%     
end




