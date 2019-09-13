function m_area = tt_estimate_mouse_area( vAlign )
% get mouse area in pixels for each frame
% INPUTS:
%   vAlign:     unwarped video stored in 3D matrix
% OUTPUTS:
%   m_area:     mouse area in pixels

% Diogo Duarte, 2018, Carey lab

nFrames = size(vAlign, 3);
m_area = zeros(nFrames, 1);

gray_thresh = 0.05;

for ii = 1:nFrames
    m_area(ii) = sum(sum(im2bw(vAlign(:,:,ii), gray_thresh)));
%     m_area(ii) = sum(sum(imdilate(im2bw(vAlign(:,:,ii), gray_thresh), ...
%                             strel('disk', 2))));
end

end

