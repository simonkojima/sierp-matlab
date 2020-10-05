clearvars
%% ---------------------------------------------------------------
%Stream Epoch Exporter
%Author : Simon Kojima

%Data : Number of Channel x Number of Sample
%Time : 1 x Number of Sample
%Trigger : Number of Sample x1

%%-------------------------------------------------------------------------

% FileStruct{1} = [1 4];
% FileStruct{2} = [2 5];
% FileStruct{3} = [3 6];

% FileStruct{1} = [1];
% FileStruct{2} = [2];
% FileStruct{3} = [3];

% FileStruct{1} = [4];
% FileStruct{2} = [5];
% FileStruct{3} = [6];　

FileStruct{1} = [1];
FileStruct{2} = [2];
FileStruct{3} = [3];
FileStruct{4} = [4];

SaveFileNameStruct{1} = './AttendedtoLL.mat';
SaveFileNameStruct{2} = './AttendedtoLH.mat';
SaveFileNameStruct{3} = './AttendedtoHL.mat';
SaveFileNameStruct{4} = './AttendedtoHH.mat';

% FileStruct{1} = [1 3 5];
% FileStruct{2} = [2 4 6];
% 
% SaveFileNameStruct{1} = 'Tone.mat';
% SaveFileNameStruct{2} = 'Piano.mat';

for Repeat=1:size(FileStruct,2)

TriggerSelect = [3 4 5 6]; 
% TriggerSelect = [4 8]; 

Files = FileStruct{Repeat};
SaveFileName = SaveFileNameStruct{Repeat};

%Files = [2 5];              %Suffix of Files
[~,FolderName] = fileparts(pwd);
%PreFileName = '20181206_B33_Stream_';
PreFileName = strcat(FolderName,"_");
%SaveFileName = './Stream2.mat';
Range = [-0.1 0.5];
BaseLineRange = [-0.05 0];
EEGThreshold = [-200 200];       %min max (uV uV)
EOGThreshold = [-500 500];       %min max (uV uV)
%BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [1 40]; %0.1 15
AlphaThreshold = 100;
FilterOrder = 2;
ICAEnable = 0;

NumChannel = 64;
EOGEnable = 1;

%ChannelSelection = [12 30 32 34 50 52 54 57 61 63]; % Fz C3 Cz C4 P3 Pz P4 PO7 PO8 Oz
%ChannelSelection = [12 30 32 34 52 57 61]; % Fz C3 Cz C4 Pz PO7 PO8

%ChannelSelection = [10 12 14 32 49 52 55]; % F3 Fz F4 Cz P5 Pz P6

%ChannelSelection = [32 49 52 55]; % Cz P5 Pz P6
%ChannelSelection = [10 12 14 32]; % F3 Fz F4 Cz
%ChannelSelection = [10 32];

ChannelSelection = 1:64;

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
        EEGAcception{l}(m,1) = Acceptor(Average.Data{l}(:,:,m),EEGThreshold);
        %AlphaAcception{l}(m,1) = AlphaAcceptor(Average.Data{l}(:,:,m),AlphaThreshold,FilterRange,Fs);
        if EOGEnable == 1
            EOGAcception{l}(m,1) = Acceptor(Average.EOGData{l}(:,:,m),EOGThreshold);
        end
    end

    if EOGEnable == 1
        %Acception{l} = and(and(EEGAcception{l},EOGAcception{l}),AlphaAcception{l});
        Acception{l} = and(EEGAcception{l},EOGAcception{l});
    else
        Acception{l} = EEGAccecption{l};
    end
end

for l=1:size(Average.Data,2)
    count = 0;
    Average.NumAllEpoch{l} = length(Acception{l});
    for m=1:Average.NumAllEpoch{l}
        if Acception{l}(m) == 1
            count = count+1;
            Average.Temporary{l}(:,:,count) = Average.Data{l}(:,:,m);
        end
    end
    Average.Accepted{l} = sum(Acception{l});
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

for l = 1:length(ChannelSelection)
    temp(l) = Label(ChannelSelection(l));
end

Label = temp;
clear temp;

%return
save(SaveFileName,'Average','EpochTime','Fs','Label');
clear Average BaseLineEpoch EEGAcception EOGAcception AlphaAcception Acception

end


load('AttendedtoLL');
epochs.att{1}.dev{1} = Average.Data{1};
epochs.att{1}.dev{2} = Average.Data{2};
epochs.att{1}.dev{3} = Average.Data{3};
epochs.att{1}.dev{4} = Average.Data{4};

av.att{1}.dev{1} = Average.AllAveraged{1};
av.att{1}.dev{2} = Average.AllAveraged{2};
av.att{1}.dev{3} = Average.AllAveraged{3};
av.att{1}.dev{4} = Average.AllAveraged{4};

load('AttendedtoLH');
epochs.att{2}.dev{1} = Average.Data{1};
epochs.att{2}.dev{2} = Average.Data{2};
epochs.att{2}.dev{3} = Average.Data{3};
epochs.att{2}.dev{4} = Average.Data{4};

av.att{2}.dev{1} = Average.AllAveraged{1};
av.att{2}.dev{2} = Average.AllAveraged{2};
av.att{2}.dev{3} = Average.AllAveraged{3};
av.att{2}.dev{4} = Average.AllAveraged{4};

load('AttendedtoHL');
epochs.att{3}.dev{1} = Average.Data{1};
epochs.att{3}.dev{2} = Average.Data{2};
epochs.att{3}.dev{3} = Average.Data{3};
epochs.att{3}.dev{4} = Average.Data{4};

av.att{3}.dev{1} = Average.AllAveraged{1};
av.att{3}.dev{2} = Average.AllAveraged{2};
av.att{3}.dev{3} = Average.AllAveraged{3};
av.att{3}.dev{4} = Average.AllAveraged{4};

load('AttendedtoHH');
epochs.att{4}.dev{1} = Average.Data{1};
epochs.att{4}.dev{2} = Average.Data{2};
epochs.att{4}.dev{3} = Average.Data{3};
epochs.att{4}.dev{4} = Average.Data{4};

av.att{4}.dev{1} = Average.AllAveraged{1};
av.att{4}.dev{2} = Average.AllAveraged{2};
av.att{4}.dev{3} = Average.AllAveraged{3};
av.att{4}.dev{4} = Average.AllAveraged{4};

% 
% load('AttendedtoLow.mat')
% epochs.att{1}.dev{1} = Average.Data{1};
% epochs.att{1}.dev{2} = Average.Data{2};
% epochs.att{1}.dev{3} = Average.Data{3};
% 
% av.att{1}.dev{1} = Average.AllAveraged{1};
% av.att{1}.dev{2} = Average.AllAveraged{2};
% av.att{1}.dev{3} = Average.AllAveraged{3};
% 
% load('AttendedtoMid.mat')
% epochs.att{2}.dev{1} = Average.Data{1};
% epochs.att{2}.dev{2} = Average.Data{2};
% epochs.att{2}.dev{3} = Average.Data{3};
% 
% av.att{2}.dev{1} = Average.AllAveraged{1};
% av.att{2}.dev{2} = Average.AllAveraged{2};
% av.att{2}.dev{3} = Average.AllAveraged{3};
% 
% load('AttendedtoHigh.mat')
% epochs.att{3}.dev{1} = Average.Data{1};
% epochs.att{3}.dev{2} = Average.Data{2};
% epochs.att{3}.dev{3} = Average.Data{3};
% 
% av.att{3}.dev{1} = Average.AllAveraged{1};
% av.att{3}.dev{2} = Average.AllAveraged{2};
% av.att{3}.dev{3} = Average.AllAveraged{3};
% 
save(FolderName,'epochs','av','EpochTime','Fs','Label','FileStruct');
% 
% %Done();