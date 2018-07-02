close all;
clearvars
% Linear Discriminant Analysis Classifier
% Version : alpha 1
% Author : Simon Kojima
%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier

load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Training

for i=1:size(TrainingData.X,2)
    MdlLinear{i} = fitcdiscr(TrainingData.X{i},TrainingData.Y{i},'DiscrimType','pseudoLinear');
    Result{i} = predict(MdlLinear{i},TestData.X{i});
end

%% Evaluation
for i=1:size(TrainingData.X,2)
    [MCC(i),F1(i)] = ClassifierEvaluation(Result{i},TestData.Y{i},1);
end

fprintf('\n');
fprintf('Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));