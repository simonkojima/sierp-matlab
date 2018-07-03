close all;
clearvars
%
%   Make Datasets for Classifier
%   Version : alpha 1
%   Author : Simon Kojima
%
%% Preferences

% edit EpochExporter.m
% edit KFoldCrossValidation.m
% edit MakeTrainingDatasets.m
% edit MakeTestDatasets.m

run EpochExporter.m
run KFoldCrossValidation.m
run MakeTrainingDatasets.m
run MakeTestDatasets.m

return