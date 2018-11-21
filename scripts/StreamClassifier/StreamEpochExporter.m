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

TriggerSelect = [2 8 32];
PlotColor = {'b','r'};

Files = [3 6];              %Suffix of Files
PreFileName = '20181121_B35_Stream_';
SaveFileName = './Stream3.mat';
Range = [-0.1 0.5];         %(s s)
EEGThreshold = [-1000 1000];       %min max (uV uV)
EOGThreshold = [-1000 1000];       %min max (uV uV)
BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [1 40]; %0.1 15
AlphaThreshold = 100;        %(%)
FilterOrder = 2;
ICAEnable = 0;

NumChannel = 64;
EOGEnable = 2;

%ChannelSelection = [12 30 32 34 50 52 54 57 61 63]; % Fz C3 Cz C4 P3 Pz P4 PO7 PO8 Oz
%ChannelSelection = [12 30 32 34 52 57 61]; % Fz C3 Cz C4 Pz PO7 PO8s
%ChannelSelection = [10 12 14 32 49 52 55]; % F3 Fz F4 Cz P5 Pz P6
ChannelSelection = [10 32];

%ChannelSelection = 1:64;
%ChannelSelection = 1:2:64;
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
            Temp.DownsampleData(m,:) = downsample(Data(m,:),DownsampleRate);
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

Temp.Data = [];
for l=1:length(ChannelSelection)
    Temp.Data = [Temp.Data; Data(ChannelSelection(l),:)];
end

if ICAEnable == 1
    Temp.Data = fastica(Temp.Data);
end

if EOGEnable == 1
    for l=1:2
        Temp.Data = [Temp.Data; Data(NumChannel+l,:)];
    end
end

Data = Temp.Data;

%% Slicing Epoch Data
fprintf('Epoching Data.....\n');
for l=1:length(TriggerSelect)
   count{l} = 0;
   for m=1:length(Trigger)
      if Trigger(m) == TriggerSelect(l)
          count{l} = count{l}+1;
          Average.Data{l}(:,:,count{l}) = Data(:,m+floor(Range(1)*Fs):m+floor(Range(2)*Fs));
          %fprintf('Slicing Epoch Data No.%.0f of Trigger No.%.0f\n',count{l},TriggerSelect(l));
      end
   end
end
clear count;

%% Base Line
fprintf('Epoching Base Line.....\n');
for l=1:length(TriggerSelect)
    count{l} = 0;
   for m=1:length(Trigger)
      if Trigger(m) == TriggerSelect(l)    
          count{l} = count{l}+1;
          BaseLineEpoch{l}(:,:,count{l}) = Data(:,m+floor(BaseLineRange(1)*Fs):m+floor(BaseLineRange(2)*Fs));
          %fprintf('Slicing BaseLine Data No.%.0f of Trigger No.%.0f\n',count{l},TriggerSelect(l));
      end
   end
end
clear count;

%% Compute BaseLine

fprintf('Computing Base Line.....\n');
for l=1:length(TriggerSelect)
    BaseLine{l} = repmat(mean(BaseLineEpoch{l},2),1,size(Average.Data{l},2));
end

for l=1:length(TriggerSelect)
   Average.Data{l} = Average.Data{l} - BaseLine{l}; 
end

%% Evaluate Each Epoch Data

fprintf('Evaluating.....\n');
for l=1:length(TriggerSelect)
    if sum(abs(EEGThreshold)) ~= 0
       for m=1:size(Average.Data{l},3)
           if EOGEnable == 1
               temp = squeeze(Average.Data{l}(1:end-2,:,m));
           else
               temp = squeeze(Average.Data{l}(1:end,:,m));
           end
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
    end
    
    if sum(abs(EOGThreshold)) ~= 0 && EOGEnable == 1
        temp = squeeze(Average.Data{l}(end-1:end,:,m));
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

save(SaveFileName,'Average','EpochTime','Fs','Label');
