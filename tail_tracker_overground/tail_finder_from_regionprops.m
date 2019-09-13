function [tail_idx, obj_num] = tail_finder_from_regionprops( stats,h,w,...
                                                                    view)
% simplistic version to find the tail form stats, the output of regionprops
% USAGE:
% [tail_idx, obj_num] = tail_finder_from_regionprops( stats,h,w,view)
% 
% INPUTS:
%   stats:      the outputs of the regionprops
%   h:          height of the video (not being used)
%   w:          weight of the video (not being used)
%   view:       specify top or bottom view
% OUTPUTS:
%   tail_idx:   index of candidate points where the tail may be found
%   obj_num:    objects found after binarization

% Diogo Duarte, 2018, Carey lab

                                                                
                                                                
% simplest version
% select longest object
weights = [2 1 1];

malength    = zeros(numel(stats), 1);
xcentroid   = zeros(numel(stats), 1);
ycentroid   = zeros(numel(stats), 1);

zs = cell(numel(stats), 1);
xs = cell(numel(stats), 1);

for jj = 1:numel(stats)
     % ugly programming is ugly
     malength(jj)   = stats(jj).MajorAxisLength;
     xcentroid(jj)  = stats(jj).Centroid(1);
     ycentroid(jj)  = stats(jj).Centroid(2);
%      [zs{jj},xs{jj}] = ind2sub([h w],malength(jj));
end
%  [~,obj_num] = max(malength);

% [malength, I] = sort(malength, 'descend');
% % tail should be among the first 
% zs = zs(I);
% xs = xs(I);

malength   = zscore( malength  );
xcentroid  = zscore( xcentroid );
ycentroid  = zscore( ycentroid );

malength   = malength + abs(min(malength));
xcentroid  = xcentroid + abs(min(xcentroid));
ycentroid  = ycentroid + abs(min(ycentroid));

% going really basic and not optimized on this:

switch view
    case 'side'
        score = [malength, -xcentroid, -ycentroid]*weights';
        [~,obj_num] = max(score);
        tail_idx = stats(obj_num).PixelIdxList;
        
    case 'bottom'
        score = malength - xcentroid;
        [~,obj_num] = max(score);
        tail_idx = stats(obj_num).PixelIdxList;
end
 
end