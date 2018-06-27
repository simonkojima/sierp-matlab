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
%run EpochExporter.m
run MakeDatasets.m
load ./Datasets.mat


%%

%Model = fitcsvm(X,Y,'Standardize',true,'KernelFunction','gaussian'); 
Model = fitcsvm(X,Y,'Standardize',true,'KernelFunction','linear');
%Model = fitcsvm(X,Y,'KernelFunction','kernel'); 

[Result,Score] = predict(Model,TestData);

%% Evaluation

ClassifierEvaluation(Result,ActualLabel);
