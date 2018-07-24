clearvars
% Linear Discriminant Analysis Classifier
% Version : alpha 1
% Author : Simon Kojima
%% Preferences

load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Training

for i=1:size(TrainingData.X,2)
    MdlLinear{i} = fitcdiscr(TrainingData.X{i},TrainingData.Y{i},'DiscrimType','pseudoLinear');
    Result{i} = predict(MdlLinear{i},TestData.X{i});
end

%% Evaluation
for i=1:size(TrainingData.X,2)
    [MCC(i),F1(i),Accurecy(i)] = ClassifierEvaluation(Result{i},TestData.Y{i},1);
end

fprintf('\n');
fprintf(' Mean Accurecy : %.0f%%\n',mean(Accurecy)*100);
fprintf(' Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));