function [tracks_tail_c, tracks_tail] = tt_convert_to_locomouse(t, vid, ...
                                                    calib_file)
% convert the format of my tracks to the 15 point format locomouse uses
% INPUTS:
%   t:                  tail tracks
%   vid:                video filename
%   calib_file:         calib file with info about camera/lens distortions
% OUTPUTS:
%   tracks_tail:        tail tracks
%   tracks_tail_c:      tail tracks in constrained view

% Diogo Duarte, 2018, Carey lab

step_3d = 16; % pixels
nframes = numel(t);
% tracks_tail     = nan(4, 15, nframes);
tracks_tail_c   = nan(3, 15, nframes);

% init value
idx = 1;

% frame by frame
for ii = 1:nframes
    % estimate 3d length
    if ~isnan(t{ii}.xs)
        estimate = 1;
        len = estimate_3d_length();
%         step_3d = len/15;
        
        % number of tail points for this iteration
        numTailPts = numel(t{ii}.xs);
        
        % derivatives (steps)
        dx = diff(t{ii}.xs);
        dy = diff(t{ii}.yb);
        dz = diff(t{ii}.zs);
        
        % calculate the length by integrating the steps
        steps_squared = diag([dx dy dz]*[dx dy dz]');
        dlen = sqrt(steps_squared);
        sum_dlen = cumsum(dlen);
        for kk = 1:15 % 15 point system has 15 points
            % find current index
            idx = find_t_idx(idx);
            tracks_tail_c(1, kk, ii) = t{ii}.xs(idx);
            tracks_tail_c(2, kk, ii) = t{ii}.yb(idx);
            tracks_tail_c(3, kk, ii) = t{ii}.zs(idx);
            if idx > numTailPts-step_3d
                break;
            end
        end
        
        
    else
        % nothing to do here, let's go home
        estimate=0;
        len = 0;
    end
    % determine the index for point 1 to 15
end


% convert tracks to unconstrained view
tracks_tail = convertTracks();

    function [len, lenvec] = estimate_3d_length()
        npoints = length(t{ii}.xs);
        x = t{ii}.xs;
        y = t{ii}.yb;
        z = t{ii}.zs;
        dx = diff(x);
        dy = diff(y);
        dz = diff(z);
        len = 0;
        lenvec = zeros(npoints,1);
        for jj = 1:npoints-1
            len = len + norm([dx(jj) dy(jj) dz(jj)]); 
            lenvec(jj+1) = len;
        end
    end
    function idx = find_t_idx(old_idx)
        if kk == 1
            idx = 1;
        else
%             old_idx = idx;
            [~, idx] = min(abs((sum_dlen-sum_dlen(old_idx))-step_3d));
        end
    end
    function tracks_tail = convertTracks()
        
        vidread         = VideoReader(vid);
        image_size(1)   = vidread.Height;
        image_size(2)   = vidread.Width;
        calib           = load(calib_file);
        IDX             = calib.ind_warp_mapping;
        flip            = 0;
        scale           = 1;
        dummytracks     = nan(4,5,nframes);
        
        [~,tracks_tail]=convertTracksToUnconstrainedView(dummytracks,...
                                                        tracks_tail_c,...
                                                        image_size,...
                                                        IDX,...
                                                        flip,...
                                                        scale);
    end
end

