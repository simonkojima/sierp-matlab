clearvars

Files = 1;
PreFileName = '20181127_B36_Stream_';
SaveFileName = '20181127_B36_Stream_0001_Processed.mat';

FilterRange = [1 40]; %0.1 15
FilterOrder = 2;

NumChannel = 64;
EOGEnable = 1;

%ChannelSelection = [12 30 32 34 50 52 54 57 61 63]; % Fz C3 Cz C4 P3 Pz P4 PO7 PO8 Oz
%ChannelSelection = [12 30 32 34 52 57 61]; % Fz C3 Cz C4 Pz PO7 PO8
%ChannelSelection = [10 12 14 32 49 52 55]; % F3 Fz F4 Cz P5 Pz P6
%ChannelSelection = [10 12 14 32]; % F3 Fz F4 Cz
ChannelSelection = [10 32];

%ChannelSelection = 1:64;

%ChannelSelection = 8:64;
%ChannelSelection = 1:2:64;
%ChannelSelection = 2:2:64;
%ChannelSelection = 1:7;

DownsampleRate = 1;

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
clear Temp


if EOGEnable == 1
    EOGData = Data(end-1:end,:);
    Data = Data(1:end-2,:);
end

if size(Data,1) ~= NumChannel
    fprintf('Error : NumChannel Does Not Match\n');
    return
end

Temp.Data = [];
for l=1:length(ChannelSelection)
    Temp.Data = [Temp.Data; Data(ChannelSelection(l),:)];
end

Data = Temp.Data;

clear Temp

save(SaveFileName,'Data','Fs','Label','Time','Trigger');