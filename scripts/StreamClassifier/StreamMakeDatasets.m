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
    open StreamEpochExporter.m
    %open KFold.m
    %open StreamMakeTrainingDatasets.m
    %open StreamMakeTestDatasets.m
    open Stream.m
    return
end

run StreamEpochExporter.m
fprintf('EpochData was exported!\n');
run KFold.m
fprintf('KFold Completed!\n');
run StreamMakeTrainingDatasets.m
fprintf('TrainingDatasets was created!\n');
run StreamMakeTestDatasets.m
fprintf('TestDatasets was created!\n');
clearvars
fprintf('Completed!!\n');