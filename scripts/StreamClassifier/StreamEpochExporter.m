clearvars
%% ------------------------------------------------------------------------
%Epoch Exporter
%Author : Simon Kojima
%Version : 12

%All data must have the following format!!
%Data : Number of Channel x Number of Sample
%Time : 1 x Number of Sample
%Trigger : Number of Sample x1

%%------------------------------------------------------------------------

RepNum = 3;

FileStruct{1} = [1 4];
FileStruct{2} = [2 5];
FileStruct{3} = [3 6];

SaveFileNameStruct{1} = './Stream1.mat';
SaveFileNameStruct{2} = './Stream2.mat';
SaveFileNameStruct{3} = './Stream3.mat';

for Repeat=1:RepNum

TriggerSelect = [2 8 32];
PlotColor = {'b','r'};

Files = FileStruct{Repeat};
SaveFileName = SaveFileNameStruct{Repeat};

%Files = [2 5];              %Suffix of Files
PreFileName = '20181113_B35_Stream_';
%SaveFileName = './Stream2.mat';
Range = [-0.1 0.5];         %(s s)
EEGThreshold = [-50 50];       %min max (uV uV)
EOGThreshold = [-Inf Inf];       %min max (uV uV)
BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [1 40]; %0.1 15
AlphaThreshold = 20;        %(%)
FilterOrder = 2;
ICAEnable = 0;

NumChannel = 64;
EOGEnable = 1;

%ChannelSelection = [12 30 32 34 50 52 54 57 61 63]; % Fz C3 Cz C4 P3 Pz P4 PO7 PO8 Oz
%ChannelSelection = [12 30 32 34 52 57 61]; % Fz C3 Cz C4 Pz PO7 PO8
%ChannelSelection = [10 12 14 32 49 52 55]; % F3 Fz F4 Cz P5 Pz P6
%ChannelSelection = [10 12 14 32]; % F3 Fz F4 Cz
ChannelSelection = [10 32];

%ChannelSelection = 8:64;
%ChannelSelection = 1:2:64;
%ChannelSelection = 2:2:64;
%ChannelSelection = 1:7;

DownsampleRate = 1;
AveragingNum = 1;

Temp.Data = [];
Temp.Trigger = [];
for l=1:length(Files)
    Temp.DownsampleData = [];
    FileNumberString = num2str(Files(l));
    for m=1:4-strlength(FileNumberString)
        FileNumberString = strcat(num2str(0),FileNumberString);
    end
    FileName = sprintf(strcat(strcat(PreFileName,FileNumberString),'.mat'))
    load(FileName);
    [B, A] = butter(FilterOrder, FilterRange/(Fs/2), 'bandpass');
    Data = filtfilt(B, A, Data')';
    if DownsampleRate ~= 1
        for m=1:size(Data,1)
            Temp.DownsampleData(m,:) = decimate(Data(m,:),DownsampleRate);
        end
        Data = Temp.DownsampleData;
        Trigger = TriggerDownsample(Trigger,DownsampleRate,0);
        Fs = Fs/DownsampleRate;
    end
    
    Temp.Data = [Temp.Data Data];
    Temp.Trigger = [Temp.Trigger Trigger];
end
Data = Temp.Data;
Trigger = Temp.Trigger;

if EOGEnable == 1
    EOGData = Data(end-1:end,:);
    Data = Data(1:end-2,:);
end

if size(Data,1) ~= NumChannel
    fprintf('Error : NumChannel Does Not Match\n');
    return
end

clear Temp

%% Slicing Epoch Data
fprintf('Epoching Data.....\n');
for l=1:length(TriggerSelect)
    Average.Data{l} = Epoch(Data,Trigger,Range,TriggerSelect(l),Fs);
    BaseLineEpoch{l} = BaseLine(Epoch(Data,Trigger,BaseLineRange,TriggerSelect(l),Fs),Range,Fs);
    Average.Data{l} = Average.Data{l} - BaseLineEpoch{l};
    if EOGEnable == 1
        Average.EOGData{l} = Epoch(EOGData,Trigger,Range,TriggerSelect(l),Fs);
    end
    
end

%% Evaluate Each Epoch Data

fprintf('Evaluating.....\n');
for l=1:length(TriggerSelect)
    for m=1:size(Average.Data{l},3)
        temp = squeeze(Average.Data{l}(:,:,m));
        AllRangeBandPower = bandpower(mean(temp,1)',Fs,FilterRange);
        AlphaRangeBandPower = bandpower(mean(temp,1)',Fs,[8 13]);
        PerPower = 100*(AlphaRangeBandPower/AllRangeBandPower);
        if (min(temp(:)) < EEGThreshold(1)) || (max(temp(:)) > EEGThreshold(2))
            Average.Data{l}(:,:,m) = zeros(size(Average.Data{l},1),size(Average.Data{l},2));
            Average.Accepted{l}(m) = 0;
        else
            if PerPower > AlphaThreshold
                Average.Data{l}(:,:,m) = zeros(size(Average.Data{l},1),size(Average.Data{l},2));
                Average.Accepted{l}(m) = 0;
            else
                Average.Accepted{l}(m) = 1;
            end
        end
    end
    
    if EOGEnable == 1
        temp = squeeze(Average.EOGData{l}(:,:,m));
        if (min(temp(:)) < EOGThreshold(1)) || (max(temp(:)) > EOGThreshold(2))
            Average.Data{l}(:,:,m) = zeros(size(Average.Data{l},1),size(Average.Data{l},2));
            Average.Accepted{l}(m) = 0;
        end
    end
    
    
end
clear temp

for l=1:size(Average.Data,2)
    count = 0;
    Average.NumAllEpoch{l} = size(Average.Data{l},3);
    for m=1:size(Average.Data{l},3)
        if Average.Accepted{l}(m) == 1
            count = count+1;
            Average.Temporary{l}(:,:,count) = Average.Data{l}(:,:,m);
        end
    end
    Average.Accepted{l} = sum(Average.Accepted{l});
end
clear count;

Average.Data = Average.Temporary;
Average = rmfield(Average,'Temporary');

for l=1:length(TriggerSelect)
    fprintf('Trigger No.%.0f, Accepted Epoch Data : %.0f of %.0f\n',TriggerSelect(l),Average.Accepted{l},Average.NumAllEpoch{l});
end

%% Averaging

fprintf('Averaging.....\n');
EpochTime = Range(1):1/Fs:Range(2);
EpochTime = EpochTime';

for l=1:length(TriggerSelect)
   for m=1:size(Average.Data{l},3)
       if AveragingNum*(m+1) > size(Average.Data{l},3)
           Average.AveragedEpoch{l}(:,:,m) = mean(Average.Data{l}(:,:,AveragingNum*(m-1)+1:end),3);
           break;
       else
           Average.AveragedEpoch{l}(:,:,m) = mean(Average.Data{l}(:,:,AveragingNum*(m-1)+1:AveragingNum*m),3);
       end
   end
end

for l=1:length(TriggerSelect)
   for m=1:size(Average.Data{l},3)
       Average.AllAveraged{l} = mean(Average.Data{l},3);
   end
end

if EOGEnable == 1
    for l=1:length(TriggerSelect)
        for m=1:size(Average.Data{l},3)
            temp.Data{l} = Average.Data{l}(1:end-2,:,:);
            temp.AveragedEpoch{l} = Average.AveragedEpoch{l}(1:end-2,:,:);
            temp.AllAveraged{l} = Average.AllAveraged{l}(1:end-2,:);            
        end
    end
    Average = temp;
    clear temp;
end

for l = 1:length(ChannelSelection)
    temp(l) = Label(ChannelSelection(l));
end

Label = temp;
clear temp;

save(SaveFileName,'Average','EpochTime','Fs','Label');
clear BaseLine Average BaseLineEpoch
end