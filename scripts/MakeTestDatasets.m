close all;
clearvars
%
%   Make Datasets for Classifier
%   Version : alpha 1
%   Author : Simon Kojima
%
%% Preferences

cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier
load ./KFoldEpochData.mat
load ./TrainedParams.mat

%% Making Data

k = size(K,2);

for i=1:k
    Segmentation{i} = Segmentate(K{i},TrainedParams.TimeSegmentation{i});
end

for i=1:k
   X{i} = []; 
   Y{i} = [];
end

for i=1:k
    for j=1:size(Segmentation{i}{1},3)
        X{i} = [X{i}; reshape(TrainedParams.H{i}'*Segmentation{i}{1}(:,:,j),1,size(Segmentation{i}{1},2)*size(TrainedParams.H{i},2)) FilteredVariance(TrainedParams.H{i},Segmentation{i}{1}(:,:,j))];
        Y{i} = [Y{i};0];
    end
end

for i=1:k
    for j=1:size(Segmentation{i}{2},3)
        X{i} = [X{i}; reshape(TrainedParams.H{i}'*Segmentation{i}{2}(:,:,j),1,size(Segmentation{i}{2},2)*size(TrainedParams.H{i},2)) FilteredVariance(TrainedParams.H{i},Segmentation{i}{2}(:,:,j))];
        Y{i} = [Y{i};1];
    end
end

for i=1:k
    X{i} = (X{i} - TrainedParams.Standardize{i}.meanvec)./TrainedParams.Standardize{i}.stdvec;
end

%% Applying PCA

for i=1:k
    X{i} = X{i}*TrainedParams.PCA{i}.U(:,1:TrainedParams.PCA{i}.k);
end

%% Add an intercept term

for i=1:k
    X{i} = [ones(size(X{i},1),1) X{i}];
end

%% Save Data

TestData.X = X;
TestData.Y = Y;

save('TestDatasets.mat','TestData');