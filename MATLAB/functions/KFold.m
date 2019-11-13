function K = KFold(Data,k,ShuffleEnable)

%load ./EpochData.mat
%Data = Average.AveragedEpoch;

%k = 10;

%% Shuffle
if ShuffleEnable == 1
    for l=1:size(Data,2)
        RandomIndex{l} = randperm(size(Data{l},3));
        for m=1:size(Data{l},3)
            Temp{l}(:,:,m) = Data{l}(:,:,RandomIndex{l}(m));
        end
    end
    Data = Temp;
    clear Temp;
end

%% Devide Datasets

for l=1:size(Data,2)
    count{l} = 0;
end

for l=1:k
    for m=1:size(Data,2)
        for n=1:NumData(size(Data{m},3),k,l)
            count{m} = count{m} + 1;
            K{l}{m}(:,:,n) = Data{m}(:,:,count{m});
        end
    end
end

%save('KFoldEpochData','K');

end


%% function part
function N = NumData(D,K,index)
if index <= rem(D,K)
    N = floor(D./K) + 1;
elseif index > rem(D,K)
    N = floor(D./K);
end
end