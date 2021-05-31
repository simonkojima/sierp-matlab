close all;
clearvars

% Linear Discriminant Analysis Classifier
% Version : alpha 2
% Author : Simon Kojima

%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
run MakeDatasets.m
load ./Datasets.mat

%%

layers = [sequenceInputLayer(29)
          lstmLayer(200)
          fullyConnectedLayer(2)
          softmaxLayer()
          classificationLayer()];

%X = categorical(X);
Y = categorical(Y);
%TestData = categorical(TestData);
      
options = trainingOptions('sgdm','MaxEpochs',1000,'InitialLearnRate',0.0001,'Plots','training-progress');
convnet = trainNetwork(X,Y,layers,options);

Result = classify(convnet,TestData);

%% Evaluation

ClassifierEvaluation(Result,ActualLabel);


%%

return

load ./EpochData.mat

NumTrainingData = [20 20];
NumTestData = [10 10];

Epoch.StdCategorical = Epoch.Standard;
Epoch.DevCategorical = Epoch.Deviant;

count = 0;
for i=1:NumTrainingData(1)
   count = count + 1;
   X{count,1} = Epoch.StdCategorical{i}';
end
for i=1:NumTrainingData(2)
    count = count + 1;
   X{count,1}  = Epoch.DevCategorical{i}';
end
clear count;

count = 0;
for i=NumTrainingData(1)+1:NumTrainingData(1)+NumTestData(1)
   count = count + 1;
   TestData{count,1} = Epoch.StdCategorical{i}';
end
for i=NumTrainingData(2)+1:NumTrainingData(2)+NumTestData(2)
    count = count + 1;
   TestData{count,1}  = Epoch.DevCategorical{i}';
end
clear count;
    
Y = [zeros(NumTrainingData(1),1);ones(NumTrainingData(2),1)];
Y = categorical(Y);

TestRes = [zeros(NumTestData(1),1);ones(NumTestData(2),1)];
TestRes = categorical(TestRes);

%% Applying PCA

% k = 18;
% 
% [U,S] = PCA(X);
% 
% X = X*U(:,1:k);
% 
% TestData = TestData*U(:,1:k);
% RetainedVariance(S,k);

%%

% [m,n] = size(X);
% InitialTheta = zeros(n+1,1);
% X = [ones(m,1) X];
% 
% [m n] = size(TestData);
% TestData = [ones(m,1) TestData];

%% 

layers = [sequenceInputLayer(7)
          lstmLayer(200,'OutputMode','last')
          fullyConnectedLayer(2)
          softmaxLayer()
          classificationLayer()];

options = trainingOptions('sgdm','MaxEpochs',1000,'InitialLearnRate',0.0001,'Plots','training-progress');
convnet = trainNetwork(X,Y,layers,options);

Result = classify(convnet,TestData);

%% Evaluation

FalsePos = 0;
FalseNeg = 0;
Correct = 0;
TruePos = 0;
TrueNeg = 0;

[m n] = size(TestData);
for i=1:m
    if Result(i) == TestRes(i)
        if Result(i) == categorical(1)
            TruePos = TruePos+1;
        elseif Result(i) == categorical(0)
            TrueNeg = TrueNeg+1;
        end
    else
       if Result(i) == categorical(1)
            FalsePos = FalsePos+1;
       elseif Result(i) == categorical(0)
            FalseNeg = FalseNeg +1;
       end
    end
end

fprintf('True Positive : %.0f\n',TruePos);
fprintf('True Negative : %.0f\n',TrueNeg);
fprintf('False Positive : %.0f\n',FalsePos);
fprintf('False Negative : %.0f\n',FalseNeg);
fprintf('Precision : %.2f%%\n',TruePos/(TruePos+FalsePos)*100);
fprintf('Recall : %.2f%%\n',TruePos/(TruePos+FalseNeg)*100);
fprintf('\nAccurency : %.2f%%\n',(TruePos+TrueNeg)/(TruePos+TrueNeg+FalsePos+FalseNeg)*100);