function t = tt_project_to_bottom(vAlign, t, split_line)
% looks for bottom view vertical match of side view tail
%
% USAGE:
% str = tt_findbkg(vid)
%
% INPUTS:
%   vAlign:     3D matrix of video after camera distortion correction
%   t:          as input, it takes a tail cell t tracked on the side view
%               and projects to the bottom view, adding those fields to t
%   split_line: where, in pixel space, the split line between bootom and
%               side views are
% OUTPUTS:
%   t:          tail tracks

% Diogo Duarte, 2018, Carey lab

% global variables, parameters
gw = 15;   % groin width   %13
tw = 6;
tail_length_max_overest = 0.50;
fw = [1 1]; % feature weights; [inetnsity distance_to_previous_point 1 0.3
slp= 3; %split_line_penalty]

otsu_tol = 1.25; % can tolerate values if tail is 30% below otsu's
% threshold. purely empirical. this happens, I think, because the distal
% part of the tail is very thin and the convolution with a with of 6 is
% too wide

convw_gw = hamming(gw)/sum(hamming(gw));
convw_tw = hamming(tw)/sum(hamming(tw));
convw_tw_h = hamming(round(tw/2))/sum(hamming(tw/2));

% is all the tail in the FOV?
% percentage of the x length where the mouse center of gravity should be
cog_thresh = 0.14;  % this seems about right. more will give you tail later
                    % in the video only


% find match for the first tail  point

% go to the second point, find match. if more than one, choose the one
% closest to the first point


%

nFrames = numel(t);

% where to start?
mouse_area = tt_estimate_mouse_area(vAlign);
% find frame to start getting tail
start_frame = find(mouse_area>mean(mouse_area), 1, 'first');




for ii = 1:nFrames                % loop 1: over all frames
    
    % find first tail point
    x_i = t{ii}.xs; % first tail point in x (length)

    % store prior bottom view tail tracks
    t{ii}.xb_p = t{ii}.xb;
    t{ii}.yb_p = t{ii}.yb;

    % pre allocate xb and yb
    t{ii}.xb = t{ii}.xs;
    t{ii}.yb = NaN( size( t{ii}.xb ) );

    % subset of the frame to serve several functions
    roi_bv = vAlign(split_line:end, :, ii);
    otsu_thresh = graythresh(roi_bv)*max(roi_bv(:));
    % .....................................................................
    % function call to find tail match on the bottom view
    find_tail_match_bottom();

    t{ii}.yb = t{ii}.yb + split_line;
    % .....................................................................



    % .....................................................................
    % function call to determine where the tail ends
    crop_tail();
    % .....................................................................


    % .....................................................................
    % detect if tail has split segments and redo the search from proximal
    % to distal, constraining next points to the closest to the previous
    % one
    t{ii}.yb = t{ii}.yb - split_line;
    stitch_tail();
    t{ii}.yb = t{ii}.yb + split_line;

end
% .....................................................................

% excluding initial segments where tail is not visible
for ii=1:nFrames
    cog=tt_estimate_mouse_cog(vAlign(split_line:end, :, ii));
    if cog < cog_thresh*size(vAlign,2)
        t{ii}.xs = NaN;
        t{ii}.zs = NaN;
        t{ii}.xb = NaN;
        t{ii}.yb = NaN;
    else
        break;
    end
end



% -------------------------------------------------------------------------
%
%                       END OF MAIN FUNCTION
%
% -------------------------------------------------------------------------

    function find_tail_match_bottom()
        % this is called inside a for loop at each frame


        w = 7; % tail convolution window size in pixels
        otsu_multiplier = 0.3; % bringing down the threshold


        bincanvas = zeros(size(roi_bv));



        % ....... criterion for looking for tail ..........................
        % sometimes there is no tail in bottom view yet - maybe due to
        % innacurate distortion correction

        % method 1:

%         mismatch_bs = t{ii}.xb_p(1) - t{ii}.xs(1);
%         % calc first iteration
%         if mismatch_bs > 0
%             start_x = abs(mismatch_bs)+1;
%         else
%             start_x = 1;
%         end
        % TODO: find a better criterion, like a threshold change in the
        % intensity profile. starting on the bottom track results biases
        % too much, causes distal portion of the tail not to be tracked.
        % start with otsu's threshold

        % method 2:

        start_x = t{ii}.xs+20;
        %find_tailstart_bv(); % start_x is in pixels

        % .................................................................
        % find jj position start_x is in
        start_x_jj = find(t{ii}.xs==start_x, 1, 'last');
        if isempty(start_x_jj)
            start_x_jj = 1;
        end

        prior_x_jj = find(t{ii}.xs==t{ii}.xb_p(1),1,'first');
        if isempty(prior_x_jj)
            prior_x_jj = 1;
        end

        for jj = prior_x_jj:1:numel(t{ii}.xs)  % loop 2: over all tail points

            % x must be the same

            % get candidate points
            % 1 smooth image


            % to store the


            % 2 get vertical profile
            vert_profile = conv(double(roi_bv(:,t{ii}.xb(jj))), ...
                convw_tw, 'same');
            % TODO: replace hamming(w) with the properly normalized hamming
            % window. this will cause all hell to break loose...
            % 3 find most likely point on the verticla profile, closest to
            %   the previous point
            % function start_x = find_tailstart_bv()

            %             [~, t{ii+}.yb(jj)] = max(vert_profile);
            [intensities, candidates] = findpeaks(vert_profile);
            % filter out candidates with low intensity
            [hi.Values,hi.BinLimits] = histcounts(intensities, 10);
            ot = otsuthresh(hi.Values)*hi.BinLimits(2);

            candidates_subset = candidates(intensities>ot);
            intensities_subset = intensities(intensities>ot);

            bincanvas(candidates_subset, jj) = intensities_subset;


            % get region properties to figure out if points belong to the
            % tail
%             CC = bwconncomp(im2bw(bincanvas));
%             stats = regionprops(CC,'area', 'perimeter');
%
%             tail_per = zeros(numel(stats),1);
%             for kk = 1:numel(stats)
%                 tail_per(kk) = stats(kk).Perimeter;
%             end

            % validate tail points
            % for each tail candidate, accept it if it belongs to the
            % object with the largest perimeter (use this info to
            % desambiguate)

            % I'm missing the statement for assigning bottom view points

            % two features: how close the candidate is to the bottom
            % tracked one, and how close to the previous point

            % calc euclidean distance to previous point. actually we only
            % need y because x is the adjacent pixel

            if jj>1 && ~isnan(t{ii}.yb(jj-1))
                ydist = abs(candidates_subset-t{ii}.yb(jj-1));
            else
                ydist = ones(size(candidates_subset));
            end

            % split line proximity penalty
            split_line_penalty = exp(-1./candidates_subset);

            % score weighted by distance to the previous point., sometimes
            % this causes wall reflectinsto be captured as the tail,
            % instead of the tail itself.
            % TODO: We should add an overground-specific probability
            % modulator along y of where the tail is most likely to be, so
            % that we can decrease the probability of the algorithm
            % capturing the tail reflection
            score = (fw * [intensities_subset/max(intensities_subset) ...
                            (1./ydist)]') .* split_line_penalty';

            [~,idx] = max(score);
            t{ii}.yb(jj) = candidates_subset(idx);

        end

        for jj = prior_x_jj-1:-1:start_x_jj  % loop 3: complementary to the previous one

            vert_profile = conv(double(roi_bv(:,t{ii}.xb(jj))), ...
                convw_tw, 'same');
            % 3 find most likely point on the verticla profile, closest to
            [intensities, candidates] = findpeaks(vert_profile);
            % filter out candidates with low intensity
            [hi.Values,hi.BinLimits] = histcounts(intensities, 10);
            ot = otsuthresh(hi.Values)*hi.BinLimits(2);

            candidates_subset = candidates(intensities>ot);
            intensities_subset = intensities(intensities>ot);

            bincanvas(candidates_subset, jj) = intensities_subset;

            if ~isnan(t{ii}.yb(jj+1))
                ydist = abs(candidates_subset-t{ii}.yb(jj+1));
            else
                ydist = ones(size(candidates_subset));
            end

            % split line proximity penalty
            split_line_penalty = exp(-1./candidates_subset);

            score = (fw * [intensities_subset/max(intensities_subset) ...
                            (1./ydist)]') .* split_line_penalty';

            [~,idx] = max(score);
            t{ii}.yb(jj) = candidates_subset(idx);
        end

        % clean NaNs
        nanidx = isnan(t{ii}.yb);
        t{ii}.yb(nanidx) = [];
        t{ii}.xb(nanidx) = [];
        t{ii}.xs(nanidx) = [];
        t{ii}.zs(nanidx) = [];

        % add split line back
%         t{ii}.yb = t{ii}.yb + split_line;

        function start_x = find_tailstart_bv()
            % finds where the tail starts in the bottom view
%             otsu_thresh = graythresh(roi_bv)*max(roi_bv(:));
            column_i = t{ii}.xs(1); % where to start the search
            column_f = t{ii}.xb_p(1); % where to end the search
            tail_y_center_old=t{ii}.yb_p(1)-split_line; % where the tail
            % centre should
            % be at.  we'll use this info to prevent big shifts in tail
            % position, e.g., tail reflections which might be captured in
            % intensity around the true tail tip
            start_x = column_f;

            for ll = column_f:-1:column_i % ll is just the counter. others
                % were already taken, the alphabet does not have enough
                % letters
                vert_profile =conv(double(roi_bv(:,ll)),convw_tw_h,'same');
                % update y position
                [~,tail_y_center_new] = max(vert_profile);
                d_ty = abs(tail_y_center_new-tail_y_center_old);

                % check if intensity dropped or tail center shifted
                if any(vert_profile > otsu_thresh/otsu_tol) && d_ty<tw
                    start_x = ll+1;
                end
                % update previous tail centre
                tail_y_center_old = tail_y_center_new;

            end
            if start_x < 1
                start_x = 1;
            end
        end

    end
    function crop_tail()
        % determine where the tail ends based on how wide a groin should be
        % in the bottom view

        % step 1 - guestimate how long the tail should be . let's say the
        % true tail length is never less than 3/4 of the tracked tail
        % length
        % where is 3/4? tail length in pixels
        first_point = find(t{ii}.xb, 1, 'first');
        tail_length_pix = t{ii}.xb(end) - t{ii}.xb(first_point);
        start_pixel = round(tail_length_max_overest * tail_length_pix)+...
            t{ii}.xb(first_point);
        % start_pixel is in pixels, not indices!!
        end_pixel = t{ii}.xb(end);
        for jj = start_pixel:t{ii}.xb(end)
            % this loop goes over pixels, not tail indices!!!!!!!!!
            vert_profile = conv(double(roi_bv(:,jj)), convw_tw,'same');

%             tail_line = getTailExpectedLine();
%             if sum(roi_bv(:,jj)>otsu_thresh) >= gw
%                 end_pixel = jj;
%                 break;
%             end

            % we need to provide the tail pixel
            tailpix = t{ii}.yb(find(t{ii}.xb==jj, 1, 'first'))-split_line;

            tw_crop = lm_fwhm(vert_profile', tailpix); % tail width?
            if tw_crop < gw % if tail width is higher than expected groin
                % width, end of the tail is here
                end_pixel = jj;
            else
                break;
            end
        end

        % crop xs and xb in a very crude way
        end_pixel_idx = find(t{ii}.xb==end_pixel, 1, 'first');

        t{ii}.xb(end_pixel_idx:end) = [];
        t{ii}.xs(end_pixel_idx:end) = [];
        t{ii}.yb(end_pixel_idx:end) = [];
        t{ii}.zs(end_pixel_idx:end) = [];
    end
    function stitch_tail()
        % 1 - determine if tail needs stitching, i.e., if the difference
        % between any two adjacent points was ever greater than 1 pixel
        array_of_continuity = abs(diff(t{ii}.yb)); % sounds like an epic
        % weapon in an mmorpg which gives the user impossible powers, kinda
        % like detecting a tail in a reeler mouse
        tail_needs_stitching = max(array_of_continuity) > 1;
        if tail_needs_stitching
            % find largest continuous tail segment
            segment = nan(5,2); % if tail has more than 5 separate
            % segments there's no stitching that can help...
            disconts = find(array_of_continuity>1);
            for dd = 1:numel(disconts)
                if dd==1
                    segment(dd,1) = 1;
                else
                    segment(dd,1) = disconts(dd-1)-1;
                end
                segment(dd,2) = disconts(dd);
            end
            segment(dd+1,1) = disconts(dd)+1;
            segment(dd+1,2) = numel(t{ii}.yb);
            segment = reshape(segment(~isnan(segment)),[],size(segment,2));

            segment_lengths = diff(segment, 1, 2);

            % if the rightmos segment takes at least 30% of the tail length
            % choose the rightmost one, as reflections happen near the tip
            if segment_lengths(end) > 0.3*numel(t{ii}.yb)
                use_segment = numel(segment_lengths);
            else
                [~, use_segment] = max(segment_lengths);
            end

            % from here, branch into two for loops
            % loop 1: towards the tip
            for jj = segment(use_segment,1)-1:-1:1
                vert_profile = conv(double(roi_bv(:,t{ii}.xb(jj))), ...
                    convw_tw, 'same');
                [intensities, candidates] = findpeaks(vert_profile);
                % filter out candidates with low intensity and high
                % distance
                ydist = abs(candidates-(t{ii}.yb(jj+1)));

                candidates_subset = ...
                    candidates( intensities>otsu_thresh/otsu_tol & ...
                                ydist<(tw/2));
                intensities_subset = ...
                    intensities(intensities>otsu_thresh/otsu_tol & ...
                                ydist<(tw/2));

                if ~isempty(candidates_subset)
                    [~,idx] = max(intensities_subset);
                    t{ii}.yb(jj) = candidates_subset(idx);
                else
                    % tail search is over...
                    t{ii}.yb(jj:-1:1) = [];
                    t{ii}.xb(jj:-1:1) = [];
                    t{ii}.xs(jj:-1:1) = [];
                    t{ii}.zs(jj:-1:1) = [];
                    break;
                end

            end
            % loop 2: towards the groin
            for jj = segment(use_segment,2):numel(t{ii}.yb)
                vert_profile = conv(double(roi_bv(:,t{ii}.xb(jj))), ...
                    convw_tw, 'same');
                [intensities, candidates] = findpeaks(vert_profile);
                % filter out candidates with low intensity and high
                % distance
                ydist = abs(candidates-(t{ii}.yb(jj-1)));

                candidates_subset = ...
                    candidates( intensities>otsu_thresh/otsu_tol & ...
                                ydist<(tw/2));
                intensities_subset = ...
                    intensities(intensities>otsu_thresh/otsu_tol & ...
                                ydist<(tw/2));

                if ~isempty(candidates_subset)
                    [~,idx] = max(intensities_subset);
                    t{ii}.yb(jj) = candidates_subset(idx);
                else
                    % tail search is over...
                    t{ii}.yb(jj:end) = [];
                    t{ii}.xb(jj:end) = [];
                    t{ii}.xs(jj:end) = [];
                    t{ii}.zs(jj:end) = [];
                    break;
                end
            end
        end
        % add split line back
%         t{ii}.yb = t{ii}.yb + split_line;
    end
    function tail_line = getTailExpectedLine
        % gets pixels where, given an expected maximum tail line, tail is
        % expected to be found

    end

end
