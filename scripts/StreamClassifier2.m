clearvars

load './LowStream.mat'
Stream{1} = Average;

load './MidStream.mat'
Stream{2} = Average;

load './HighStream.mat'
Stream{3} = Average;

clear Average

SimulatingFile = '20181127_B36_Stream_0003_Processed.mat';
TriggerSelect = [2 8 32];

EpochRange = [-0.1 0.5];

CorrectClass = 3;

StandardizeEnable = 1;
PCAEnable = 1;
RetainingVariance = 99;

%% Making Training Data

for Deviant=1:size(Stream,2)
    TrainingData.X{Deviant} = [];
    TrainingData.Y{Deviant} = [];
    for Attended=1:size(Stream,2)
        TrainingData.X{Deviant} = vertcat(TrainingData.X{Deviant},Vectorizer(Stream{Attended}.Data{Deviant}));
        if Deviant == Attended
            TrainingData.Y{Deviant} = [TrainingData.Y{Deviant}; ones(size(Vectorizer(Stream{Attended}.Data{Deviant}),1),1)];
        else
            TrainingData.Y{Deviant} = [TrainingData.Y{Deviant}; zeros(size(Vectorizer(Stream{Attended}.Data{Deviant}),1),1)];
        end
    end
end

%% Standardize
if Standardize == 1
    for l=1:size(TrainingData.X,2)
        [TrainingData.X{l},Standardize{l}.meanvec,Standardize{l}.stdvec] = Standardization(TrainingData.X{l});
    end
end

%% Applying PCA

if PCAEnable == 1
    for l=1:size(TrainingData.X,2)
        [pca{l}.U,pca{l}.S,pca{l}.V] = PCA(TrainingData.X{l});
        pca{l}.k = DetDimension(pca{l}.S,RetainingVariance);
        TrainingData.X{l} = TrainingData.X{l}*pca{l}.U(:,1:pca{l}.k);
    end
end

%% Designing LDA

for Deviant=1:size(TrainingData.X,2)
    MdlLinear{Deviant} = fitcdiscr(TrainingData.X{Deviant},TrainingData.Y{Deviant},'DiscrimType','pseudolinear');
end

%% Simulating

load(SimulatingFile);
SimulatingRange = [0 10];

for l=1:size(Trigger,2)
    if Trigger(l) ~= 0
        FirstTrigger = l;
        break
    end
end

Count = 0;
for l=(FirstTrigger-Fs):SimulatingRange(2)*Fs:size(Data,2)
    
    IntervalData = Devide(Data,l,SimulatingRange,Fs);
    IntervalTrigger = Devide(Trigger,l,SimulatingRange,Fs);
    
    for m=1:length(TriggerSelect)
        EpochData{m} = Epoch(IntervalData,IntervalTrigger,EpochRange,TriggerSelect(m),Fs);
    end
    
    for m=1:size(MdlLinear,2)
        if EpochData{m} ~= 0
            
            FeatureVector = Vectorizer(EpochData{m});
            
            if Standardize == 1
                FeatureVector = (FeatureVector - Standardize{m}.meanvec)./Standardize{m}.stdvec;
            end
            
            if PCAEnable == 1
                FeatureVector = FeatureVector*pca{m}.U(:,1:pca{m}.k);
            end
            
            Result{m} = predict(MdlLinear{m},FeatureVector);
        else
            Result{m} = 0;
        end
    end
    
    Count = Count + 1;
    %     fprintf('\n');
    %     fprintf('-%dth Section-\n',Count);
    %     fprintf('\n');
    for m=1:size(Result,2)
        P{m} = mean(Result{m});
        %         fprintf('Class %d : %f\n',m,P{m});
    end
    %     fprintf('\n');
    
    %for m=1:size(P,2)
    Score(Count,:) = [P{1} P{2} P{3}];
    
    %end
    
    %break
end

[M,I] = max(Score,[],2);

temp = sum(Score,2);
for l=1:length(I)
    if temp(l) == 0
        I(l) = 0;
    end
end

FalseCount = 0;
for l=1:length(I)
    if I(l) ~= CorrectClass
        FalseCount = FalseCount + 1;
    end
end

I

fprintf('Accuracy : %f%%\n',(1-FalseCount/length(I))*100);

% for l=1:size(MdlLinear,2)
%     mean(Result{l})
% end



