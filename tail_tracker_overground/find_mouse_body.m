function find_mouse_body(vidnobkg, split_line)
% finds mouse body on bideo with subtracted background
% 
% USAGE:
% b = find_mouse_body(vidnobkg, split_line)
% 
% INPUTS:
%   vidnobkg:   3D matrix of the mouse video after background subtraction
%   split_line: split line row. not really being used

% Diogo Duarte, 2018, Carey lab

[h, w, n_frames] = size(vidnobkg);
binvid = false(size(vidnobkg));

for ii = 1:n_frames
    
    thresh = 3/255; % excluding first N channels
    
    % very light threshold
    binvid(:,:,ii) = im2bw(vidnobkg(:,:,ii) ,thresh);
    
    
    % imclose
    disksize = 5;
%     binvid(:,:,ii) = imclose( binvid(:,:,ii), strel('disk',disksize));
%     binvid(:,:,ii) = bwmorph( binvid(:,:,ii), 'bothat', 1);
    binvid(:,:,ii) = bwmorph( binvid(:,:,ii), 'clean', Inf);
    binvid(:,:,ii) = imerode( binvid(:,:,ii), strel('disk',disksize));
    
    % fill holes in the mouse
    binvid(:,:,ii) = bwmorph( binvid(:,:,ii), 'fill', Inf);
    
    MN = [10 2];
    binvid(:,:,ii) = imerode( binvid(:,:,ii), strel('rectangle',MN));
    
    binvid(:,:,ii) = bwmorph( binvid(:,:,ii), 'majority', Inf);
    
    binvid(:,:,ii) = bwmorph( binvid(:,:,ii), 'thicken', 1);
    
    % start looking at side view and bottom view separately:
    % fit ellipse to objects in top view 
    
    % select 2 largest objects in image
    
    % 
    
end

lm_playVideo(binvid, 'loop', 1);
end