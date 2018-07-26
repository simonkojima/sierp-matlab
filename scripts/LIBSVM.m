clearvars
%
%   Support Vector Machine Classifier
%   Require libsvm from 
%   Author : Simon Kojima
%
%% Preferences


load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Training

for i=1:size(TrainingData.X,2)
    Model{i} = svmtrain(TrainingData.Y{i},TrainingData.X{i},'-s 0 -t 0 -q');
    [Result{i},~,~] = svmpredict(zeros(size(TestData.Y{i})),TestData.X{i},Model{i},'-q');
end

%% Evaluation
for i=1:size(TrainingData.X,2)
    [MCC(i),F1(i),Accuracy(i)] = ClassifierEvaluation(Result{i},TestData.Y{i},1);
end

fprintf('\n');
fprintf(' Mean Accuracy : %.0f%%\n',mean(Accuracy)*100);
fprintf(' Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));