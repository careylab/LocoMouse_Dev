function tt_overwrite_tail_tracks(tracks_tail, tracks_tail_c, datafile)
% new tail tracker let's the old one run and then overwrites the trail
% tracks in the tracks files
% USAGE:
% tt_overwrite_tail_tracks(tracks_tail, tracks_tail_c, datafile)
% 
% INPUTS:
%   tracks_tail:    tracks
%   tracks_tail_c:  tracks in constrained view
%   datafile:       tracks file name, better if it's the full path.

% Diogo Duarte, 2018, Carey lab

b = load(datafile);

b.old_tracks_tail   = b.tracks_tail;
b.old_tracks_tail_c = b.tracks_tail_c;

b.tracks_tail   = tracks_tail;
b.tracks_tail_c = tracks_tail_c;

save(datafile, '-struct', 'b');
end