clearvars
%
%   Support Vector Machine Classifier
%   Version : alpha 11
%   Author : Simon Kojima
%
%% Preferences

load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Training

for i=1:size(TrainingData.X,2)
    Model{i} = fitcsvm(TrainingData.X{i},TrainingData.Y{i},'KernelFunction','linear');
    [Result{i},Score{i}] = predict(Model{i},TestData.X{i});
end

%% Evaluation

for i=1:size(TrainingData.X,2)
    [MCC(i),F1(i),Accuracy(i)] = ClassifierEvaluation(Result{i},TestData.Y{i},1);
end

fprintf('\n');
fprintf(' Mean Accuracy : %.0f%%\n',mean(Accuracy)*100);
fprintf(' Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));