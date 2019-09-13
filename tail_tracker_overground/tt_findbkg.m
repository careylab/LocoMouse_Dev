function str = tt_findbkg(vid)
% finds bkg in the same folder as vid
% USAGE:
% str = tt_findbkg(vid)
% 
% INPUTS:
%   vid:    video file name, better if it's the full path
% OUTPUTS: 
%   str:    background name assuming one background image per trial

% Diogo Duarte, 2017, Carey lab

% 1: get folder
[basedir, vidname, ~] = fileparts(vid);

% 2: list all backgrounds
bkgs = dir(fullfile(basedir, '*.png'));

% isolate bkgs names and video name
for ii = 1:numel(bkgs)
    % isolate bkgs names and video name
    [~, bkgname, ~] = fileparts(bkgs(ii).name);
    k = strfind(vidname,bkgname);
    if ~isempty(k)
        str = fullfile(basedir, strcat(bkgname, '.png'));
        break;
    end
end

end