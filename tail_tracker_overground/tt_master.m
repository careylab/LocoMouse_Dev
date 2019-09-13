function [t, vAlign] = tt_master(vid, bkg, calib_file, varargin)
% function for the tail tracker. should take as input the video, background
% and calibration file.
% 
% USAGE:
% [t, vAlign] = tt_master(vid, bkg, calib_file, varargin)
% INPUTS:
%   vid:    video file name, better if it's the full path
%   bkg:    background file name
%   calib:  calibration file to account for camera/lens distortions
%   varargin: to change the default mouse direction

% OUTPUTS: 
%   t:      tail tracks in their own space (as in, not in the conventioned 
%           15-point space)
%   vAlign: unwarped video. useful for plotting

% Diogo Duarte, 2018, Carey lab

if nargin>3
    LR = varargin{1};
else
    LR = 'L';
end


% read video
v = lm_getVideoFrames(vid);
% read background
b = imread(bkg);

% flip if necessary
if LR=='R'
    % flip video
    b = fliplr(b);
    for ii=1:n_frames
        v(:,:,ii) = fliplr(v);
    end
end


% for each frame, subtract background
vnb = v;
n_frames = size(v,3);
for ii = 1:n_frames
   vnb(:,:,ii) = v(:,:,ii) - b; 
end

% load calibration file to get camera distortion map and correct video
c = load(calib_file);
ind_warp_mapping = c.ind_warp_mapping;
vAlign = unwarp_video(vnb, ind_warp_mapping);

% start by tracking both views
t = tail_track_2views(vAlign, c.split_line);

% project tail from side view to bottom view taking as a first proxy the
% tail tracked on both views
t = tt_project_to_bottom(vAlign, t, c.split_line);


end