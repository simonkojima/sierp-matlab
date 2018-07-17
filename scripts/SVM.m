close all;
clearvars
%
%   Support Vector Machine Classifier
%   Version : alpha 11
%   Author : Simon Kojima
%
%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier

load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Training

for i=1:size(TrainingData.X,2)
    %Model = fitcsvm(X,Y,'Standardize',true,'KernelFunction','gaussian'); 
    Model{i} = fitcsvm(TrainingData.X{i},TrainingData.Y{i},'KernelFunction','linear');
    %Model{i} = fitcsvm(TrainingData.X{i},TrainingData.Y{i},'Standardize',true,'KernelFunction','gaussian');
    %Model = fitcsvm(X,Y,'KernelFunction','kernel'); 
    [Result{i},Score{i}] = predict(Model{i},TestData.X{i});
end

%% Evaluation
for i=1:size(TrainingData.X,2)
    [MCC(i),F1(i)] = ClassifierEvaluation(Result{i},TestData.Y{i},1);
end

fprintf('\n');
fprintf(' Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));