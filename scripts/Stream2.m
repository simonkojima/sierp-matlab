clearvars


load './LowStream.mat'
Stream{1} = Average;

load './MidStream.mat'
Stream{2} = Average;

load './HighStream.mat'
Stream{3} = Average;

clear Average;

SimulatingFile = '20181127_B36_Stream_0001_Processed.mat';
TriggerSelect = [2 8 32];

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

%% Designing LDA

for Deviant=1:size(TrainingData.X,2)
    MdlLinear{Deviant} = fitcdiscr(TrainingData.X{Deviant},TrainingData.Y{Deviant},'DiscrimType','linear');
end

%% Simulating

load(SimulatingFile);
for l=1:size(Trigger,2)
    if Trigger(l) ~= 0
       FirstTrigger = l; 
    end
end

for l=FirstTrigger:10*Fs:size(Data,2)
    Interval = Devide(Data,l,[0 10],Fs);
    IntervalTrigger = Devide(Trigger,l,[0 10],Fs);
    for m=1:length(TriggerSelect)
        %EpochData{m} = [];
        %EpochData{m} = 
        %size(TriggerSelect(m))
        Epoch(Interval,IntervalTrigger,[-0.1 0.5],TriggerSelect(m),Fs)
    end
    return
end











