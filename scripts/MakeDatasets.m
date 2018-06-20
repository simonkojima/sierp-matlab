close all;
clearvars
%
%   Make Datasets for Classifier
%   Version : alpha 1
%   Author : Simon Kojima
%
%% Preferences

load ./EpochData.mat

NumTrainingData = [100 20];
NumTestData = [7 7];

RetainingVariance = 99;
NumSegmentation = 10;

PlotEnable = 0;
SegmentateEnable = 0;

Epoch.Data = Average.AveragedEpoch;

%% Making Data

if SegmentateEnable == 1
    TimeSegmentation = AdaptiveSegmentation(Epoch.Data,NumSegmentation);
    save('Segmentation.mat','TimeSegmentation');
end

load ./Segmentation.mat

Segmentation = Segmentate(Epoch.Data,TimeSegmentation);

[Ht,Hnt] = CSP(Segmentation{2},Segmentation{1});
H = [Ht Hnt];

if PlotEnable == 1
    subplot(2,1,1)
    topoplot(Ht,'P300_7ch.ced','electrodes','labelpoint');
    hold on
    title('CSP Filter for Target');
    subplot(2,1,2)
    topoplot(Hnt,'P300_7ch.ced','electrodes','labelpoint');
    title('CSP Filter for Non-Target');
    hold off
end

for i=1:size(Segmentation,2)
    RandomIndex{i} = randperm(size(Segmentation{i},3));
    for j=1:size(Segmentation{i},3)
        Temp{i}(:,:,j) = Segmentation{i}(:,:,RandomIndex{i}(j));
    end
end
Segmentation = Temp;
clear Temp;

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
ActualLabel = [zeros(NumTestData(1),1);ones(NumTestData(2),1)];

X = Standardization(X);

%% Applying PCA

[U,S] = PCA(X);

k = DetDimension(S,RetainingVariance);

X = X*U(:,1:k);

TestData = TestData*U(:,1:k);
RetainedVariance(S,k);

%% Initialize

X = [ones(size(X,1),1) X];
TestData = [ones(size(TestData,1),1) TestData];

save('Datasets.mat','X','Y','TestData','ActualLabel');