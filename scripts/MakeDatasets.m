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
    return
end

run EpochExporter.m
fprintf('EpochData was exported!\n');
run KFold.m
fprintf('KFold Completed!\n');
run MakeTrainingDatasets.m
fprintf('TrainingDatasets was created!\n');
run MakeTestDatasets.m
fprintf('TestDatasets was created!\n');
clearvars
fprintf('Completed!!\n');