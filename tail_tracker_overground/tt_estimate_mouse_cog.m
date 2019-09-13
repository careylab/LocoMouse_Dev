function cog = tt_estimate_mouse_cog(roi)
% estimates mouse center of gravity / mass in a certain roi
% USAGE:
% cog = tt_estimate_mouse_cog(roi)
% 
%   
% INPUTS:
%   roi:    This is a frame  from the video. 
% OUTPUTS: 
%   cog:    the centre of mass. currently using only the x coordinate
% 
% TODO: 
%   threshold the image to get a rought estimate of the pixels where the
%   mouse is based on a flexible threshold, or a ratio of the one given by
%   otsu's method for better generalization.  
%

% Diogo Duarte, 2017, Carey lab

roi = double(roi>25);

[grid_points_x, grid_points_y] = meshgrid(1:size(roi,2),1:size(roi,1));

cog(1,1) = sum(sum(grid_points_x.*roi))./sum(roi(:));
% cog(2,1) = sum(sum(grid_points_y.*roi))./sum(roi(:));



end