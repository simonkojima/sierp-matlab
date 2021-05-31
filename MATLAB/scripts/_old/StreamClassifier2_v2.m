clearvars

load './LowStream.mat'
Stream{1} = Average;

load './MidStream.mat'
Stream{2} = Average;

load './HighStream.mat'
Stream{3} = Average;

clear Average

[~,FolderName] = fileparts(pwd);
PreFileName = strcat(FolderName,"_");
FileSuffix = '_Processed.mat';

SimulatingFileNumber = 6;
CorrectClass = 3;

FileNumberString = num2str(SimulatingFileNumber);
for m=1:4-strlength(FileNumberString)
    FileNumberString = strcat(num2str(0),FileNumberString);
end

SimulatingFile = strcat(PreFileName,FileNumberString,FileSuffix)

TriggerSelect = [2 8 32];

EpochRange = [-0.1 0.5];
BaseLineRange = [-0.05 0];

SimulatingRange = [0 10];

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
if StandardizeEnable == 1
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
    InitialTheta{Deviant} = zeros(size(TrainingData.X{Deviant},2),1);
    [MinTheta{Deviant},MinCost{Deviant}] = fminunc(@(t)LogisticCost(TrainingData.X{Deviant},TrainingData.Y{Deviant},t,100),InitialTheta{Deviant},optimset('GradObj', 'on', 'MaxIter', Inf,'Display','notify'));
end

%% Simulating

load(SimulatingFile);

for l=1:size(Trigger,2)
    if Trigger(l) ~= 0
        FirstTrigger = l;
        break
    end
end

Count = 0;
for l=FirstTrigger:SimulatingRange(2)*Fs:size(Data,2)
    
    IntervalData = Devide(Data,l,[SimulatingRange(1)-1 SimulatingRange(2)+1],Fs);
    IntervalTrigger = [zeros(1,Fs) Devide(Trigger,l,SimulatingRange,Fs) zeros(1,Fs)];
    
    for m=1:length(TriggerSelect)
        EpochData{m} = Epoch(IntervalData,IntervalTrigger,EpochRange,TriggerSelect(m),Fs);
        BaseLineEpoch{m} = BaseLine(Epoch(IntervalData,IntervalTrigger,BaseLineRange,TriggerSelect(m),Fs),EpochRange,Fs);
        EpochData{m} = EpochData{m} - BaseLineEpoch{m};
    end

    for m=1:size(Stream,2)
        if EpochData{m} ~= 0
            

            FeatureVector = Vectorizer(EpochData{m});

            if StandardizeEnable == 1
                FeatureVector = (FeatureVector - Standardize{m}.meanvec)./Standardize{m}.stdvec;
            end
            
            if PCAEnable == 1
                FeatureVector = FeatureVector*pca{m}.U(:,1:pca{m}.k);
            end
            
            S{m} = logsig(FeatureVector*MinTheta{m});
        else
            S{m} = 0;
        end
    end

    
    Count = Count + 1;

    
    Score = [mean(S{1},1) mean(S{2},1) mean(S{3},1)];
    [M(Count,:),I(Count,:)] = max(Score);
    
    if Count == Inf
       
        break
        
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

