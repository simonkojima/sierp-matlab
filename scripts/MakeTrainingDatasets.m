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

ChannnelLocationFile = 'P300_7ch.ced';

RetainingVariance = 99;
NumSegmentation = 10;

PlotEnable = 1;
SegmentateEnable = 1;

TopoPlotRange = [-5 5];

%% Making Data

k = size(K,2);
for i=1:k
    for n=1:size(K{i},2)
        temp{i}{n} = [];
    end
    for j=1:k
       if i ~= j
          for n=1:size(K{j},2)
            temp{i}{n} = cat(3,temp{i}{n},K{j}{n});
          end
       end
    end
end
Merged = temp;
clear temp;

if SegmentateEnable == 1
    for i=1:k
        fprintf('< %02.0f of %02.0f > ',i,k);
        TimeSegmentation{i} = AdaptiveSegmentation(Merged{i},NumSegmentation);
        save('Segmentation.mat','TimeSegmentation');
    end
end

load ./Segmentation.mat

for i=1:k
    Segmentation{i} = Segmentate(Merged{i},TimeSegmentation{i});
    [Ht,Hnt] = CSP(Segmentation{i}{2},Segmentation{i}{1});
    H{i} = [Ht Hnt];

end

if PlotEnable == 1
   for i=1:k
       figure('Name',['CSP Filter No.' num2str(i)]);
       subplot(1,2,1);
       title('\fontsize{15}CSP Filter for Target');
       topoplot(H{i}(:,1),ChannnelLocationFile,'maplimits',TopoPlotRange,'whitebk','on');
       subplot(1,2,2);
       title('\fontsize{15}CSP Filter for Non-Target');
       topoplot(H{i}(:,2),ChannnelLocationFile,'maplimits',TopoPlotRange,'whitebk','on');
       colorbar('fontsize',15);
   end
end

for i=1:k
   X{i} = []; 
   Y{i} = [];
end

for i=1:k
    for j=1:size(Segmentation{i}{1},3)
        X{i} = [X{i}; reshape(H{i}'*Segmentation{i}{1}(:,:,j),1,size(Segmentation{i}{1},2)*size(H{i},2)) FilteredVariance(H{i},Segmentation{i}{1}(:,:,j))];
        Y{i} = [Y{i};0];
    end
end

for i=1:k
    for j=1:size(Segmentation{i}{2},3)
        X{i} = [X{i}; reshape(H{i}'*Segmentation{i}{2}(:,:,j),1,size(Segmentation{i}{2},2)*size(H{i},2)) FilteredVariance(H{i},Segmentation{i}{2}(:,:,j))];
        Y{i} = [Y{i};1];
    end
end

for i=1:k
    [X{i},Standardize{i}.meanvec,Standardize{i}.stdvec] = Standardization(X{i});
end

%% Applying PCA

for i=1:k
    [pca{i}.U,pca{i}.S,pca{i}.V] = PCA(X{i});
    pca{i}.k = DetDimension(pca{i}.S,RetainingVariance);
    X{i} = X{i}*pca{i}.U(:,1:pca{i}.k);
end

%% Add an intercept term

for i=1:k
    X{i} = [ones(size(X{i},1),1) X{i}];
end

%% Save Data

TrainingData.X = X;
TrainingData.Y = Y;

TrainedParams.PCA = pca;
TrainedParams.TimeSegmentation = TimeSegmentation;
TrainedParams.Standardize = Standardize;
TrainedParams.H = H;

save('TrainingDatasets.mat','TrainingData');
save('TrainedParams.mat','TrainedParams');