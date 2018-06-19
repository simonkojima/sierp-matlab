clear all;
%
%   Logistic Reguression Classifier
%   Version : alpha 15
%   Author : Simon Kojima
%
%% Preferences

load ./EpochData.mat;

PlotOn = 0;

NumTrainingData = [100 100];
NumTestData = [36 36];

Threshold = 0.5;
RetainingVariance = 99;
NumSegmentation = 10;

Epoch.Data = Average.Data;

%% Making Data

% PlotDivision = [3 3];
% PlotPosition = [1 2 3 5 7 8 9];
% 
% Num = 6;
% 
% for i=1:7
%     subplot(PlotDivision(1),PlotDivision(2),PlotPosition(i));
%     plot(EpochTime,Epoch.Data{1}(:,i,Num),'b');
%     hold on
%     plot(EpochTime,Epoch.Data{2}(:,i,Num),'r');
%     plot(xlim(),[0 0],'k');
%     plot([0 0],ylim(),'k');
%     axis ij;
% end

%[Segmentation,TimeSegmentation] = AdaptiveSegmentation(Epoch.Data,NumSegmentation);
%save('Segmentation.mat','Segmentation','TimeSegmentation');
load ./Segmentation.mat
%Segmentation = Epoch.Data;

[Ht,Hnt] = CSP(Segmentation{2},Segmentation{1});
H = [Ht Hnt];

subplot(2,1,1)
topoplot(Ht,'P300_7ch.ced','electrodes','labelpoint');
hold on
title('CSP Filter for Target');
subplot(2,1,2)
topoplot(Hnt,'P300_7ch.ced','electrodes','labelpoint');
title('CSP Filter for Non-Target');
hold off

X = [];
for i=1:NumTrainingData(1)
    X = [X; reshape(H'*Segmentation{1}(:,:,i),1,size(Segmentation{1},2)*size(H,2)) FilteredVariance(H,Segmentation{1}(:,:,i))];
end

for i=1:NumTrainingData(2)
    X = [X; reshape(H'*Segmentation{2}(:,:,i),1,size(Segmentation{2},2)*size(H,2)) FilteredVariance(H,Segmentation{2}(:,:,i))];
end

TestData = [];
for i=NumTrainingData(1)+1:NumTrainingData(1)+NumTestData(1)
    TestData = [TestData; reshape(H'*Segmentation{1}(:,:,i),1,size(Segmentation{1},2)*size(H,2)) FilteredVariance(H,Segmentation{1}(:,:,i))];
end

for i=NumTrainingData(2)+1:NumTrainingData(2)+NumTestData(2)
    TestData = [TestData; reshape(H'*Segmentation{2}(:,:,i),1,size(Segmentation{2},2)*size(H,2)) FilteredVariance(H,Segmentation{2}(:,:,i))];
end

Y = [zeros(NumTrainingData(1),1);ones(NumTrainingData(2),1)];
TestRes = [zeros(NumTestData(1),1);ones(NumTestData(2),1)];

%% Applying PCA

[U,S] = PCA(X);

k = DetDimension(U,S,RetainingVariance);

X = X*U(:,1:k);

TestData = TestData*U(:,1:k);
RetainedVariance(S,k);

%%

[m,n] = size(X);
InitialTheta = zeros(n+1,1);
X = [ones(m,1) X];

[m n] = size(TestData);
TestData = [ones(m,1) TestData];

% figure();
% hold on;
% plot(0:k-1,X(1:10,:));
% axis ij;

%%
% load cancer_dataset.mat;
% 
% cancerInputs = cancerInputs';
% cancerTargets = cancerTargets';
% 
% devide = 100;
% 
% X = cancerInputs(devide+1:end,:);
% Y = cancerTargets(devide+1:end,1);
% 
% 
% [m,n] = size(X);
% InitialTheta = zeros(n+1,1);
% X = [ones(m,1) X];
% 
% TestData = cancerInputs(1:devide,:);
% TestRes = cancerTargets(1:devide,1);
% 
% TestData = [ones(length(TestData),1) TestData];
% 
% k = 2;
% 
% [U,S] = PCA(X);
% 
% X = X*U(:,1:k);
% 
% RetainedVariance(S,k);
% 
% TestData = TestData*U(:,1:k);
%% 

% Model = fitcsvm(X,Y,'Standardize',true,'KernelFunction','gaussian'); 
% Model = fitcsvm(X,Y,'KernelFunction','kernel'); 
% 
% Result = predict(Model,TestData);

[MinTheta MinCost] = fminunc(@(t)ComputeCost(X,Y,t,100),InitialTheta,optimset('GradObj', 'on', 'MaxIter', 50000));
Result = logsig(TestData*MinTheta);

[m n] = size(TestData);

for i=1:m
   if Result(i) >= Threshold
      Result(i) = 1;
   else
      Result(i) = 0;
   end
end

%% Evaluation

FalsePos = 0;
FalseNeg = 0;
Correct = 0;
TruePos = 0;
TrueNeg = 0;

[m n] = size(TestData);
for i=1:m
    if Result(i) == TestRes(i)
        if Result(i) == 1
            TruePos = TruePos+1;
        elseif Result(i) == 0
            TrueNeg = TrueNeg+1;
        end
    else
       if Result(i) == 1
            FalsePos = FalsePos+1;
       elseif Result(i) == 0
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
fprintf('\nAccurecy : %.2f%%\n',(TruePos+TrueNeg)/(TruePos+TrueNeg+FalsePos+FalseNeg)*100);