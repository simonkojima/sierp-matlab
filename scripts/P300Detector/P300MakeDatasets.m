close all
clearvars
%
%   Make Datasets for Classifier
%   Version : alpha 1
%   Author : Simon Kojima
%

%% Preferences

OpenEnable = 1;

if OpenEnable == 1
    open P300EpochExporter.m
    open KFold.m
    open P300MakeTrainingDatasets.m
    open P300MakeTestDatasets.m
    return
end

run P300EpochExporter.m
fprintf('EpochData was exported!\n');
run KFold.m
fprintf('KFold Completed!\n');
run P300MakeTrainingDatasets.m
fprintf('TrainingDatasets was created!\n');
run P300MakeTestDatasets.m
fprintf('TestDatasets was created!\n');
clearvars
fprintf('Completed!!\n');