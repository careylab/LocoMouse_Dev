function LR = tt_get_mouse_dir(vid, bkg)
% gets the direction in which the mouse ran on the overground setup: to the
% left (L), or the to the right (R) 
%
% USAGE:
% LR = tt_get_mouse_dir(vid, bkg)
% 
% INPUTS:
%   vid:    video file name, better if it's the full path
%   bkg:    background file name

% Diogo Duarte, 2018, Carey lab

v = VideoReader(vid);

b = imread(bkg);
ii = 1;
while hasFrame(v) && ii<=10
    video = readFrame(v);
    switch ndims(video)
        case 2
            vm(:,:,ii) = uint8(video)-b;
        case 3
            vm(:,:,ii) = uint8(squeeze(video(:,:,1)))-b;
    end
    cog(ii) = tt_estimate_mouse_cog(vm(:,:,ii));
    ii = ii+1;
end

if(mean(cog))<size(vm,2)*0.2 
    LR = 'L';
else
    LR = 'R';
end

end