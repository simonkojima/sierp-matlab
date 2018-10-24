close all
clearvars
%
%   Make Datasets for Classifier
%   Version : alpha 1
%   Author : Simon Kojima
%
%% Preferences

OpenEnable = 0;

if OpenEnable == 1
    open EpochExporter.m
    open KFold.m
    open MakeTrainingDatasets.m
    open MakeTestDatasets.m
end

run EpochExporter.m
run KFold.m
run MakeTrainingDatasets.m
run MakeTestDatasets.m