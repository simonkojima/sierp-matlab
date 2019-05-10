clearvars
% Linear Discriminant Analysis Classifier
% Version : alpha 1
% Author : Simon Kojima
%% Preferences

load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Training

for l=1:size(TrainingData.X,2)
    MdlLinear{l} = fitcdiscr(TrainingData.X{l},TrainingData.Y{l},'DiscrimType','pseudoLinear');
    Result{l} = predict(MdlLinear{l},TestData.X{l});
end

%% Evaluation
for l=1:size(TrainingData.X,2)
    [MCC(l),F1(l),Accuracy(l)] = ClassifierEvaluation(Result{l},TestData.Y{l},1);
end

fprintf('\n');
fprintf(' Mean Accuracy : %.0f%%\n',mean(Accuracy)*100);
fprintf(' Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));