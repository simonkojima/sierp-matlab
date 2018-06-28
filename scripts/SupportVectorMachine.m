close all;
clearvars
%
%   Support Vector Machine Classifier
%   Version : alpha 11
%   Author : Simon Kojima
%
%% Preferences

%cd /home/simon/Documents/MATLAB/Classifier
cd C:\Users\Simon\Documents\MATLAB\Classifier

load ./TrainingDatasets.mat
load ./TestDataSets.mat

%% Training

for i=1:size(TrainingData.X,2)
    %Model = fitcsvm(X,Y,'Standardize',true,'KernelFunction','gaussian'); 
    Model{i} = fitcsvm(TrainingData.X{i},TrainingData.Y{i},'Standardize',true,'KernelFunction','linear');
    %Model{i} = fitcsvm(TrainingData.X{i},TrainingData.Y{i},'Standardize',true,'KernelFunction','gaussian');
    %Model = fitcsvm(X,Y,'KernelFunction','kernel'); 
    [Result{i},Score{i}] = predict(Model{i},TestData.X{i});
end

%% Evaluation
for i=1:size(TrainingData.X,2)
    FMScore{i} = ClassifierEvaluation(Result{i},TestData.Y{i},0);
end
