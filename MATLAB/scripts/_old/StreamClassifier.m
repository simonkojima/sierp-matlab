clearvars

%% Appending and Folding

k = 10;

load('LowStream.mat')
Data{1} = KFold(Average.Data,k,0);

load('MidStream.mat')
Data{2} = KFold(Average.Data,k,0);

load('HighStream.mat')
Data{3} = KFold(Average.Data,k,0);

%% Transforming

for l=1:size(Data,2)
    for m=1:k
        for n=1:size(Data{l}{m},2)
            temp{l}{m}{n} = Vectorizer(Data{l}{m}{n});
%             for z = 1:size(Data{l}{m}{n},3)
%                 for x = 1:size(Data{l}{m}{n},1)
%                     temp{l}{m}{n}(z,:) = [Data{l}{m}{n}(x,:,z) Data{l}{m}{n}(x,:,z)];
%                 end
%             end
        end
    end
end

Data = temp;

%% Generating Training Datasets

for l=1:size(Data,2)
   for m=1:k
      TrainingData.X{l}{m} = []; 
      TrainingData.Y{l}{m} = []; 
   end
end

for l=1:size(Data,2)
    for m=1:k
        for n=1:size(Data{l}{m},2)
            for o=1:k
                if m~=o
                    TrainingData.X{n}{m} = [TrainingData.X{n}{m}; Data{l}{o}{n}];
                    TrainingData.Y{n}{m} = [TrainingData.Y{n}{m}; ones(size(Data{l}{o}{n},1),1)*l];
                end
            end
        end
    end
end

for l=1:size(TrainingData.Y,2)
   for m=1:k
       for n=1:size(TrainingData.Y{l}{m},1)
           if TrainingData.Y{l}{m}(n) == l
               TrainingData.Y{l}{m}(n) = 1;
           else
               TrainingData.Y{l}{m}(n) = 0; 
           end
       end
   end
end

%% Generating Test Datasets

for l=1:size(Data,2)
   for m=1:k
      TestData.X{l}{m} = []; 
      TestData.Y{l}{m} = []; 
   end
end

for l=1:size(Data,2)
    for m=1:k
        for n=1:size(Data{l}{m},2)
            for o=1:k
                if m==o
                    TestData.X{n}{m} = [TestData.X{n}{m}; Data{l}{o}{n}];
                    TestData.Y{n}{m} = [TestData.Y{n}{m}; ones(size(Data{l}{o}{n},1),1)*l];
                end
            end
        end
    end
end

for l=1:size(TestData.Y,2)
   for m=1:k
       for n=1:size(TestData.Y{l}{m},1)
           if TestData.Y{l}{m}(n) == l
               TestData.Y{l}{m}(n) = 1;
           else
               TestData.Y{l}{m}(n) = 0; 
           end
       end
   end
end

%% Designing LDA

for l=1:size(TrainingData.X,2)
    for m=1:k
        MdlLinear{l}{m} = fitcdiscr(TrainingData.X{l}{m},TrainingData.Y{l}{m},'DiscrimType','linear');
        Result{l}{m} = predict(MdlLinear{l}{m},TestData.X{l}{m});
    end
end

%% Evaluation 

for l=1:size(TrainingData.X,2)
   for m=1:k
       [MCC{l}(m),F1{l}(m),Accuracy{l}(m)] = ClassifierEvaluation(Result{l}{m},TestData.Y{l}{m},0);
   end
end

for l=1:size(Accuracy,2)
    MeanAccuracy(l) = mean(Accuracy{l});
end

MeanAccuracy
mean(MeanAccuracy)

