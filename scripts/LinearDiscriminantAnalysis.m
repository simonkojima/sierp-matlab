clear all;

% Linear Discriminant Analysis Classifier
% Version : alpha 1
% Author : Simon Kojima

load ./EpochData.mat

NumTrainingData = [70 70];
NumTestData = [15 15];

%% Making Data

for i=1:NumTrainingData(1)
    TrainingData(:,:,i) = Epoch.Data{1}(:,:,i);
end
index = i;
for i=1:NumTrainingData(2)
    TrainingData(:,:,i+index) = Epoch.Data{2}(:,:,i);
end

count = 1;
for i=NumTrainingData(1)+1:NumTrainingData(1)+NumTestData(1)
    TestData(:,:,count) = Epoch.Data{1}(:,:,i);
    count = count+1;
end
%for i=NumTrainingData(2)+1:size(Epoch.Data{2},3)
for i=NumTrainingData(2)+1:NumTrainingData(2)+NumTestData(2)
    TestData(:,:,count) = Epoch.Data{2}(:,:,i);
    count = count+1;
end

X=[];
for i=1:size(TrainingData,3)
    X = [X; TrainingData(:,4,i)'];
end

temp=[];
for i=1:size(TestData,3)
   temp = [temp; TestData(:,4,i)'] ;
end
TestData = temp;
clear temp;

Y = [zeros(NumTrainingData(1),1);ones(NumTrainingData(2),1)];

TestRes = [zeros(NumTestData(1),1);ones(NumTestData(2),1)];

%% Applying PCA

k = 18;

[U,S] = PCA(X);

X = X*U(:,1:k);

TestData = TestData*U(:,1:k);
RetainedVariance(S,k);

%%

[m,n] = size(X);
InitialTheta = zeros(n+1,1);
X = [ones(m,1) X];

[m n] = size(TestData);
TestData = [ones(m,1) TestData];

%% 

MdlLinear = fitcdiscr(X,Y,'DiscrimType','pseudoLinear');
Result = predict(MdlLinear,TestData);

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
fprintf('\nAccurency : %.2f%%\n',(TruePos+TrueNeg)/(TruePos+TrueNeg+FalsePos+FalseNeg)*100);