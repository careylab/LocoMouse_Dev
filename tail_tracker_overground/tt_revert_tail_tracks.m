function tt_revert_tail_tracks(datafile)
% in case you mess up overwriting new tail tracks, this reverts the change
% USAGE:
% tt_revert_tail_tracks(datafile)
% 
% INPUTS:
%   datafile:   files with tracks

% Diogo Duarte, 2018, Carey lab
b = load(datafile);

b.tracks_tail   = b.old_tracks_tail;
b.tracks_tail_c = b.old_tracks_tail_c;

b = rmfield(b, 'old_tracks_tail');
b = rmfield(b, 'old_tracks_tail_c');

save(datafile, '-struct', 'b');
end