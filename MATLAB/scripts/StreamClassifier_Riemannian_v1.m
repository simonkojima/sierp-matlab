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
%SimulatingFile = '20181206_B33_Stream_0004_Processed.mat';

SimulatingFileNumber = 4;
CorrectClass = 1;

FileNumberString = num2str(SimulatingFileNumber);
for m=1:4-strlength(FileNumberString)
    FileNumberString = strcat(num2str(0),FileNumberString);
end

SimulatingFile = strcat(PreFileName,FileNumberString,FileSuffix)

TriggerSelect = [2 8 32];

EpochRange = [-0.1 0.5];
BaseLineRange = [-0.05 0];

SimulatingRange = [0 10];

%% Calculate Mean Covariance Matrix

for Deviant=1:size(Stream,2)
    [MeanCov{Deviant},prototype{Deviant}] = Riemannian(Stream{Deviant}.Data,Deviant,50);
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
for l=(FirstTrigger-Fs):SimulatingRange(2)*Fs:size(Data,2)
    
    IntervalData = Devide(Data,l,[SimulatingRange(1)-EpochRange(1) SimulatingRange(2)+EpochRange(2)],Fs);
    IntervalTrigger = [zeros(1,Fs) Devide(Trigger,l,SimulatingRange,Fs) zeros(1,Fs)];
    
    for m=1:length(TriggerSelect)
        EpochData{m} = Epoch(IntervalData,IntervalTrigger,EpochRange,TriggerSelect(m),Fs);
        BaseLineEpoch{m} = BaseLine(Epoch(IntervalData,IntervalTrigger,BaseLineRange,TriggerSelect(m),Fs),EpochRange,Fs);
        EpochData{m} = EpochData{m} - BaseLineEpoch{m};
    end
    
    for m=1:size(Stream,2)
        Distance{m} = [];
        for n = 1:size(EpochData{m},3)
            tmp = covariance_p300(EpochData{m}(:,:,n),prototype{m});
            Distance{m} = [Distance{m}; RiemannianDistance(MeanCov{1}{m},tmp) RiemannianDistance(MeanCov{2}{m},tmp) RiemannianDistance(MeanCov{3}{m},tmp)];
        end
    end
    
    for m=1:size(Stream,2)
        Distance{m} = mean(Distance{m},1);
    end
    return
    if sum(mean(Score,1)) == 0
        I(Count,:) = 0;
    else
        [M(Count,:),I(Count,:)] = max(mean(Score,1));
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



