close all;
clearvars
% Linear Discriminant Analysis Classifier
% Version : alpha 1
% Author : Simon Kojima

%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
run MakeDatasets.m
load ./Datasets.mat

%%

MdlLinear = fitcdiscr(X,Y,'DiscrimType','pseudoLinear');
Result = predict(MdlLinear,TestData);

%% Evaluation

ClassifierEvaluation(Result,ActualLabel);