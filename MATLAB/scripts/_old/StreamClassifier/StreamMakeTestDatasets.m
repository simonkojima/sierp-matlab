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
    for m=1:2
        X{m}{l} = [];
        Y{m}{l} = [];
    end
end

if isempty(TrainedParams.H) == 1
    for l=1:k
        for m=1:size(Data{l}{1},3)
            X{1}{l} = [X{1}{l}; reshape(Data{l}{1}(:,:,m),1,size(Data{l}{1},2)*size(Data{l}{1},1))];
            Y{1}{l} = [Y{1}{l};0];
        end
    end
    
    for l=1:k
        for m=1:size(Data{l}{2},3)
            X{2}{l} = [X{2}{l}; reshape(Data{l}{2}(:,:,m),1,size(Data{l}{2},2)*size(Data{l}{2},1))];
            Y{2}{l} = [Y{2}{l};1];
        end
    end
    
else
    
    for l=1:k
        for m=1:size(Data{l}{1},3)
            X{1}{l} = [X{1}{l}; reshape(TrainedParams.H{l}'*Data{l}{1}(:,:,m),1,size(Data{l}{1},2)*size(TrainedParams.H{l},2))];
            Y{1}{l} = [Y{1}{l};0];
        end
    end
    
    for l=1:k
        for m=1:size(Data{l}{2},3)
            X{2}{l} = [X{2}{l}; reshape(TrainedParams.H{l}'*Data{l}{2}(:,:,m),1,size(Data{l}{2},2)*size(TrainedParams.H{l},2))];
            Y{2}{l} = [Y{2}{l};1];
        end
    end
    
end

for l=1:k
    for m=1:2
        X{m}{l} = (X{m}{l} - TrainedParams.Standardize{l}.meanvec)./TrainedParams.Standardize{l}.stdvec;
    end
end

%% Applying PCA

for l=1:k
    for m=1:2
%         X{m}{l} = X{m}{l}*TrainedParams.PCA{l}.U(:,1:TrainedParams.PCA{l}.k);
    end
end

%% Add an intercept term

% for l=1:k
%     X{l} = [ones(size(X{l},1),1) X{l}];
% end

%% Save Data

TestData.X = X;
TestData.Y = Y;

save('TestDatasets.mat','TestData');