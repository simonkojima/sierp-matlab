close all;
clearvars
% Step Wise Linear Discriminant Analysis Classifier
% Version : alpha 1
% Author : Simon Kojima
%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier

load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Step Wise
for i=1:size(TrainingData.X,2)
    temp.train{i} = [];
    temp.test{i} = [];
    [~,~,~,inmodel{i},~,~,~] = stepwisefit(TrainingData.X{i},TrainingData.Y{i},'display','off');
    for j=1:size(inmodel{i},2)
        if inmodel{i}(j) == 1
            temp.train{i} = cat(2,temp.train{i},TrainingData.X{i}(:,j));
            temp.test{i} = cat(2,temp.test{i},TestData.X{i}(:,j));
        end
    end
end
TrainingData.X = temp.train;
TestData.X = temp.test;

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
fprintf(' Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));