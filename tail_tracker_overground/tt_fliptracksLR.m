function tt_fliptracksLR(filename, varargin)
% flips the tail tracks from R to L (the code itself is agnostic to
% direction)
% BEWARE! using this function will overwrite your tracks  file
% 
% USAGE:
% tt_fliptracksLR(filename, varargin)
% 
% INPUTS:
%   filename: tracks file. 
%   (optional)
%   h = varargin{1};
%   w = varargin{2};

% Diogo Duarte, 2018, Carey lab

a = load(filename);

if nargin<2
    h = size(a.data.ind_warp_mapping, 1);   % video height
    w = size(a.data.ind_warp_mapping, 2);   % video width
else
    h = varargin{1};
    w = varargin{2};
end
nFrames = size(a.tracks_tail, 3);

a.tracks_tail_old = a.tracks_tail;
a.tracks_tail_c_old = a.tracks_tail_c;

b = a;

% sv_canvas = zeros(h,w, 'logical');
% bv_canvas = zeros(h,w, 'logical');
% sv_canvas_c = zeros(h,w, 'logical');
% bv_canvas_c = zeros(h,w, 'logical');

% side view flip
for ii = 791:size(a.tracks_tail, 3)
    
    sv_canvas = zeros(h,w, 'logical');
    bv_canvas = zeros(h,w, 'logical');
    sv_canvas_c = zeros(h,w, 'logical');
    bv_canvas_c = zeros(h,w, 'logical');
    
    if sum(sum(~isnan(a.tracks_tail(:,:,ii))))
        for jj = 1:size(a.tracks_tail,2) % should be the 15 points
            
            sv_canvas = zeros(h,w, 'logical');
            bv_canvas = zeros(h,w, 'logical');
            sv_canvas_c = zeros(h,w, 'logical');
            bv_canvas_c = zeros(h,w, 'logical');
            
            if ~isnan(a.tracks_tail(3,jj,ii))
                bv_canvas(a.tracks_tail(2,jj,ii), ...
                    a.tracks_tail(1,jj,ii)) = 1;
                sv_canvas(a.tracks_tail(4,jj,ii), ...
                    a.tracks_tail(3,jj,ii)) = 1;
                
                bv_canvas_c(a.tracks_tail_c(2,jj,ii), ...
                    a.tracks_tail_c(1,jj,ii)) = 1;
                sv_canvas_c(a.tracks_tail_c(3,jj,ii), ...
                    a.tracks_tail_c(1,jj,ii)) = 1;
                
                sv_canvas   = fliplr(sv_canvas);
                bv_canvas   = fliplr(bv_canvas);
                sv_canvas_c = fliplr(sv_canvas_c);
                bv_canvas_c = fliplr(bv_canvas_c);
                
                % side view unconstrained
                [a.tracks_tail(4,jj,ii), a.tracks_tail(3,jj,ii)] = ...
                    find(sv_canvas);
                % bottom view unconstrained
                [a.tracks_tail(2,jj,ii), a.tracks_tail(1,jj,ii)] = ...
                    find(bv_canvas);
                % side view constrained
                [a.tracks_tail_c(3,jj,ii), a.tracks_tail_c(1,jj,ii)] = ...
                    find(sv_canvas_c);
                % bottom view constrained
                [a.tracks_tail_c(2,jj,ii), ~] = find(bv_canvas_c);


            end
        end        
    end    
end

save(filename, '-struct', 'a');

end
