clearvars

%cd /home/simon/Documents/MATLAB/Classifier
%cd C:\Users\Simon\Documents\MATLAB\Classifier

load ./EpochData.mat
Epoch.Data = Average.AveragedEpoch;

k = 10;

%% Shuffle
for l=1:size(Epoch.Data,2)
    RandomIndex{l} = randperm(size(Epoch.Data{l},3));
    for m=1:size(Epoch.Data{l},3)
        Temp{l}(:,:,m) = Epoch.Data{l}(:,:,RandomIndex{l}(m));
    end
end
Epoch.Data = Temp;
clear Temp;

%% Devide Datasets

for l=1:size(Epoch.Data,2)
   count{l} = 0; 
end

for l=1:k
    for m=1:size(Epoch.Data,2)
        for n=1:NumData(size(Epoch.Data{m},3),k,l)
            count{m} = count{m} + 1;
            K{l}{m}(:,:,n) = Epoch.Data{m}(:,:,count{m});
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