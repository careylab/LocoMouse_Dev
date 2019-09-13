function im = wipe_out_branchpoints(im)
% function for removing branch points from a skeletonized image im
% USAGE:
% im = wipe_out_branchpoints(im)
% 
% INPUTS:
%   im:     binarized / skeletonized image
% OUTPUTS: 
%   im:     same image after removing the branch points

% Diogo Duarte, 2018, Carey lab
branched = 1;

while branched
    branch_s = bwmorph(im, 'branchpoints');
    if sum(branch_s(:))>0
        im(branch_s)=false(1);
    else
        branched = 0;
    end
end


% dilate branch points by one pixel or run branch find again(?)



end