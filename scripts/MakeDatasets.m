close all;
clearvars
%
%   Make Datasets for Classifier
%   Version : alpha 1
%   Author : Simon Kojima
%
%% Preferences

EditEnable = 0;

if EditEnable == 1
    edit EpochExporter.m
    edit KFold.m
    edit MakeTrainingDatasets.m
    edit MakeTestDatasets.m
end

run EpochExporter.m
run KFold.m
run MakeTrainingDatasets.m
run MakeTestDatasets.m