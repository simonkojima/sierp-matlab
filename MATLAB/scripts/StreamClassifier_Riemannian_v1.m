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
    prototype{Deviant} = mean(Stream{Deviant}.Data{Deviant},3);
    MeanCov{Deviant} = Riemannian(Stream{Deviant}.Data{Deviant},prototype{Deviant},15);
%     temp{Deviant} = [];
%     for l = 1:size(Stream{Deviant}.Data{Deviant},3)
%         temp{Deviant}(:,:,l) = covariance_p300(Stream{Deviant}.Data{Deviant}(:,:,m),prototype{Deviant});
%     end
%     comp{Deviant} = riemann_mean(temp{Deviant});
%     MeanCov{Deviant} = comp{Deviant};
end

%% Simulating

load(SimulatingFile);

for l=1:size(Trigger,2)
    if Trigger(l) ~= 0
        FirstTrigger = l;
        break
    end
end

for l=size(Trigger,2):-1:1
    if Trigger(l) ~= 0
        LastTrigger = l;
        break;
    end
end

Count = 0;
for l=FirstTrigger:SimulatingRange(2)*Fs:(LastTrigger-SimulatingRange(2)*Fs)
    
    IntervalData = Devide(Data,l,[SimulatingRange(1)+EpochRange(1) SimulatingRange(2)+EpochRange(2)],Fs);
    IntervalTrigger = [zeros(1,Fs*abs(EpochRange(1))) Devide(Trigger,l,SimulatingRange,Fs) zeros(1,Fs*abs(EpochRange(2)))];
    
    for m=1:length(TriggerSelect)
        EpochData{m} = Epoch(IntervalData,IntervalTrigger,EpochRange,TriggerSelect(m),Fs);
        BaseLineEpoch{m} = BaseLine(Epoch(IntervalData,IntervalTrigger,BaseLineRange,TriggerSelect(m),Fs),EpochRange,Fs);
        EpochData{m} = EpochData{m} - BaseLineEpoch{m};
        EpochData{m} = mean(EpochData{m},3);
    end
    
    for m=1:size(Stream,2)
        Distance{m} = [];
        for n = 1:size(EpochData{m},3)
            tmp = covariance_p300(EpochData{m}(:,:,n),prototype{m});
            Distance{m} = [Distance{m}; RiemannianDistance(MeanCov{m},tmp)];
        end
    end
    
    Score = [];
    for m=1:size(Stream,2)
        Score(m,:) = mean(Distance{m});
    end
    
    Count = Count + 1; 
    [~,I(Count,:)] = min(Score);
        
end

FalseCount = 0;
for l=1:length(I)
    if I(l) ~= CorrectClass
        FalseCount = FalseCount + 1;
    end
end

I

fprintf('Accuracy : %f%%\n',(1-FalseCount/length(I))*100);