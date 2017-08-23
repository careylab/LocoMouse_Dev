%% Script to analyse strides from treadmill data.
load('C:\Users\Dennis\Documents\LocoMouse_Output_DUMP\data\IR Tracking\C++\data\Lights_25_100_1_training_0,300_0,300_1_2.mat','final_tracks_c')

%
[StrideData, StrideParameters, exclusion_strides, exclusion_frames] = StrideDetection_TM(final_tracks_c);
% This part does not apply to split belt, yet! Only tied belt!
[Xcorrect, treadmill_speed] = CorrectX4TMspeed(StrideData,final_tracks_c,exclusion_strides); % extract treadmill speed
[final_tracks_TM_c,StrideData, StrideParameters] = ApplyXCorrections(final_tracks_c,StrideData,StrideParameters,Xcorrect);

%




