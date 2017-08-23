function [final_tracks_TM_c,StrideData, StrideParameters] = ApplyXCorrections(final_tracks_c,StrideData,StrideParameters,Xcorrect)

    % correct X coordinates for treadmill speed
    X = final_tracks_c(1,:,:);
    for p = 1:size(X,2)
        X(1,p,:) = squeeze(X(1,p,:)) + Xcorrect';
    end
    final_tracks_TM_c = [X; final_tracks_c(2:3,:,:)];

    % correct swing length parameter accordingly:

    preX = squeeze(final_tracks_TM_c(1,:,:))'; % X-values for all paws and snout
    preY = squeeze(final_tracks_TM_c(2,:,:))'; % Y-values for all paws and snout
    preZ = squeeze(final_tracks_TM_c(3,:,:))'; % Z-values for all paws and snout

    %Initialize Variables
    X = NaN(size(preX,1),4);
    Y = NaN(size(preX,1),4);
    Z = NaN(size(preX,1),4);

    for j=1:4
        X(:,j)=inpaint_nans(preX(:,j));
        Y(:,j)=inpaint_nans(preY(:,j));
        Z(:,j)=inpaint_nans(preZ(:,j));    

        StrideData.rawdata(j,:,:) = [[1:length(preX)]',X(:,j),Y(:,j),Z(:,j)];
        for x=1:size(StrideData.pts.st_strides{j},1)
            StrideParameters.swing_length{j}(x,1)    = StrideData.rawdata(j,StrideData.pts.st_strides{j}(x,2,1),2)-StrideData.rawdata(j,StrideData.pts.sw_pts{j}(x,1,1),2);
        end

        StrideParameters.swing_velocity{j}=StrideParameters.swing_length{j}./StrideParameters.swing_duration{j};
    end
end