close all;
clearvars
%
%   Logistic Reguression Classifier
%   Version : alpha 16
%   Author : Simon Kojima
%
%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier

load ./TrainingDatasets.mat
load ./TestDatasets.mat

Threshold = 0.6;

%%
k = size(TrainingData.X,2);
for i=1:k
    InitialTheta{i} = zeros(size(TrainingData.X{i},2),1);
    [MinTheta{i},MinCost{i}] = fminunc(@(t)LogisticCost(TrainingData.X{i},TrainingData.Y{i},t,100),InitialTheta{i},optimset('GradObj', 'on', 'MaxIter', Inf,'Display','notify'));
    Result{i} = logsig(TestData.X{i}*MinTheta{i});
    for j=1:size(TestData.X{i},1)
        if Result{i}(j) >= Threshold
            Result{i}(j) = 1;
        else
            Result{i}(j) = 0;
        end
    end
end

%% Evaluation
for i=1:size(TrainingData.X,2)
    [MCC(i),F1(i)] = ClassifierEvaluation(Result{i},TestData.Y{i},1);
end

fprintf('\n');
fprintf('Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));