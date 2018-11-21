clearvars

%% Appending and Folding

k = 10;

load('Stream1.mat')
Data{1} = KFold(Average.Data,k,0);

load('Stream2.mat')
Data{2} = KFold(Average.Data,k,0);

load('Stream3.mat')
Data{3} = KFold(Average.Data,k,0);



%% Transforming

for l=1:size(Data,2)
    for m=1:k
        for n=1:size(Data{l}{m},2)
            for z = 1:size(Data{l}{m}{n},3)
                for x = 1:size(Data{l}{m}{n},1)
                    temp{l}{m}{n}(z,:) = [Data{l}{m}{n}(x,:,z) Data{l}{m}{n}(x,:,z)];
                end
            end
        end
    end
end

Data = temp;

%% Generating Training Datasets

for l=1:size(Data,2)
   for m=1:k
      TrainingDataX{l}{m} = []; 
      TrainingDataY{l}{m} = []; 
   end
end

for l=1:size(Data,2)
    for m=1:k
        for n=1:size(Data{l}{m},2)
            for o=1:k
                if m~=o
                    TrainingDataX{n}{m} = [TrainingDataX{n}{m}; Data{l}{o}{n}];
                    TrainingDataY{n}{m} = [TrainingDataY{n}{m}; ones(size(Data{l}{o}{n},1),1)*l];
                end
            end
        end
    end
end

for l=1:size(TrainingDataY,2)
   for m=1:k
       for n=1:size(TrainingDataY{l}{m},1)
           if TrainingDataY{l}{m}(n) == l
               TrainingDataY{l}{m}(n) = 1;
           else
               TrainingDataY{l}{m}(n) = 0; 
           end
       end
   end
end

%% Generating Test Datasets

for l=1:size(Data,2)
   for m=1:k
      TestDataX{l}{m} = []; 
      TestDataY{l}{m} = []; 
   end
end

for l=1:size(Data,2)
    for m=1:k
        for n=1:size(Data{l}{m},2)
            for o=1:k
                if m==o
                    TestDataX{n}{m} = [TestDataX{n}{m}; Data{l}{o}{n}];
                    TestDataY{n}{m} = [TestDataY{n}{m}; ones(size(Data{l}{o}{n},1),1)*l];
                end
            end
        end
    end
end

for l=1:size(TestDataY,2)
   for m=1:k
       for n=1:size(TestDataY{l}{m},1)
           if TestDataY{l}{m}(n) == l
               TestDataY{l}{m}(n) = 1;
           else
               TestDataY{l}{m}(n) = 0; 
           end
       end
   end
end

%% 













