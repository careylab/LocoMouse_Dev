% [Xcorrect, treadmill_speed] = CorrectX4TMspeed(StrideData,final_tracks_c,exclusion_frames)
%
% Measures treadmill speed based on X displacement during identified stance
% Returns a matrix to correct X values, and the treadmill speed.
%
% Receives 
% StrideData
% final_tracks_c

function [Xcorrect, treadmill_speed] = CorrectX4TMspeed(StrideData,final_tracks_c,exclusion_strides)

    c=0;
    for p = 1:4 % for each paw ...
        for st_c = 1:length(StrideData.pts.stance{p}(:,1)) % ... and each stride of this paw ...
            if ~ismember(st_c,exclusion_strides{p})
                StanceFrames = StrideData.pts.stance{p}(st_c,1) : min(StrideData.pts.swing{p}(StrideData.pts.swing{p}(:,1) > StrideData.pts.stance{p}(st_c,1),1)); % we find the stance frames ...       
                c=c+1;
                VelocityDuringStance(c) = median(squeeze(diff(final_tracks_c(1,p,StanceFrames))) ./ diff(StanceFrames)'); % and calculate the drift in X as (diff(pixel) / diff(frame_index))
            end
        end
    end
    treadmill_speed = abs(nanmedian(VelocityDuringStance)); % overall estimated treadmill speed in pixel/frame
    Xcorrect = ([0:size(final_tracks_c,3)-1] * treadmill_speed); % matrix to add to your X values where necessary


    %% for plotting purposes:
    % correct paws
    X = squeeze(final_tracks_c(1,:,:));
    for p = 1:size(X,1)
        X(p,:) = X(p,:) + Xcorrect;
    end
    figure()
    plot(squeeze(X)')
    axis square
end
