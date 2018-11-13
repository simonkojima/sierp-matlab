clearvars
%
%   Make Datasets for Classifier
%   Version : alpha 1
%   Author : Simon Kojima
%
%% Preferences

%cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier
load ./KFoldEpochData.mat
load ./TrainedParams.mat
load ./Segmentation.mat

%% Making Data

k = size(K,2);

if isempty(TimeSegmentation) == 0
    for l=1:k
        Data{l} = Segmentate(K{l},TrainedParams.TimeSegmentation{l});
    end
else
    Data = K;
end

for l=1:k
   X{l} = []; 
   Y{l} = [];
end

for l=1:k
    for j=1:size(Data{l}{1},3)
        X{l} = [X{l}; reshape(TrainedParams.H{l}'*Data{l}{1}(:,:,j),1,size(Data{l}{1},2)*size(TrainedParams.H{l},2)) FilteredVariance(TrainedParams.H{l},Data{l}{1}(:,:,j))];
        Y{l} = [Y{l};0];
    end
end

for l=1:k
    for j=1:size(Data{l}{2},3)
        X{l} = [X{l}; reshape(TrainedParams.H{l}'*Data{l}{2}(:,:,j),1,size(Data{l}{2},2)*size(TrainedParams.H{l},2)) FilteredVariance(TrainedParams.H{l},Data{l}{2}(:,:,j))];
        Y{l} = [Y{l};1];
    end
end

for l=1:k
    X{l} = (X{l} - TrainedParams.Standardize{l}.meanvec)./TrainedParams.Standardize{l}.stdvec;
end

%% Applying PCA

for l=1:k
    X{l} = X{l}*TrainedParams.PCA{l}.U(:,1:TrainedParams.PCA{l}.k);
end

%% Add an intercept term

for l=1:k
    X{l} = [ones(size(X{l},1),1) X{l}];
end

%% Save Data

TestData.X = X;
TestData.Y = Y;

save('TestDatasets.mat','TestData');