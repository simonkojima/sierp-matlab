clearvars;

%cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier

load ./EpochData.mat
Epoch.Data = Average.AveragedEpoch;

k = 10;

%% Shuffle
for i=1:size(Epoch.Data,2)
    RandomIndex{i} = randperm(size(Epoch.Data{i},3));
    for j=1:size(Epoch.Data{i},3)
        Temp{i}(:,:,j) = Epoch.Data{i}(:,:,RandomIndex{i}(j));
    end
end
Epoch.Data = Temp;
clear Temp;

%% Devide Datasets

for i=1:size(Epoch.Data,2)
   count{i} = 0; 
end

for i=1:k
    for j=1:size(Epoch.Data,2)
        for n=1:NumData(size(Epoch.Data{j},3),k,i)
            count{j} = count{j} + 1;
            K{i}{j}(:,:,n) = Epoch.Data{j}(:,:,count{j});
        end
    end
end

save('KFoldEpochData','K');

%% function part
function N = NumData(D,K,index)
    if index <= rem(D,K)
        N = floor(D./K) + 1;
    elseif index > rem(D,K)
        N = floor(D./K);
    end
end