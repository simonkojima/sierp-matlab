close all;
clearvars
%
%   Logistic Reguression Classifier
%   Version : alpha 16
%   Author : Simon Kojima
%
%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
run EpochExporter.m
run MakeDatasets.m
load ./Datasets.mat

Threshold = 0.9;
InitialTheta = zeros(size(X,2),1);

%%

[MinTheta,MinCost] = fminunc(@(t)LogisticCost(X,Y,t,100),InitialTheta,optimset('GradObj', 'on', 'MaxIter', 50000));
Result = logsig(TestData*MinTheta);

for i=1:size(TestData,1)
   if Result(i) >= Threshold
      Result(i) = 1;
   else
      Result(i) = 0;
   end
end

%% Evaluation

ClassifierEvaluation(Result,ActualLabel);
