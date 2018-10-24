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

TriggerSelect = [1 5];
PlotColor = {'b','r'};

Files = [1 3];              %Suffix of Files
PreFileName = '20181001_B35_000';
Range = [0 1];         %(s s)
Threshold = [-100 100];       %min max (uV uV)
BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [0.1 15]; %0.1 15
AlphaThreshold = 100;        %(%)

ICAEnable = 1;

%ChannelSelection = [10 12 14 32 50 52 54];
ChannelSelection = 1:64;

DownSamplingRate = 4;
AveragingNum = 5;

Temp.Data = [];
Temp.Trigger = [];
for l=Files(1):Files(2)
    FileName = sprintf(strcat(PreFileName,'%d.mat'),l);
    load(FileName);
    [B, A] = butter(2, FilterRange/(Fs/2), 'bandpass');
    Data = filtfilt(B, A, Data')';
    Temp.Data = [Temp.Data Data];
    Temp.Trigger = [Temp.Trigger Trigger];
end

Data = Temp.Data;
Trigger = Temp.Trigger;

clear Temp;

Temp.Data = [];
for l=1:length(ChannelSelection)
    Temp.Data = [Temp.Data; Data(ChannelSelection(l),:)];
end

if ICAEnable == 1
    Data = fastica(Temp.Data);
else
    Data = Temp.Data;
end

%Data = Normalize(Data);
%Data = Laplacian(Data);

%fprintf('Size : %f\n',size(temp));

%% Slicing Epoch Data
%Average.Data{length(TriggerSelect)} = zeros(length(i+Time2SampleNum(Range(1),Fs):i+Time2SampleNum(Range(2),Fs)),NChannel);
%[NSample, NChannel] = size(Data);
for l=1:length(TriggerSelect)
   count{l} = 0;
   for m=1:length(Trigger)
      if Trigger(m) == TriggerSelect(l)
          count{l} = count{l}+1;
          Average.Data{l}(:,:,count{l}) = Data(:,m+Range(1)*Fs:m+Range(2)*Fs);
          fprintf('Slicing Epoch Data No.%.0f of Trigger No.%.0f\n',count{l},TriggerSelect(l));
      end
      
   end
end
clear count;

%% Base Line
%BaseLineEpoch{length(TriggerSelect)} = zeros(length(i+Time2SampleNum(BaseLineRange(1),Fs):i+Time2SampleNum(BaseLineRange(2),Fs)),NChannel);
for l=1:length(TriggerSelect)
    count{l} = 0;
   for m=1:length(Trigger)
      if Trigger(m) == TriggerSelect(l)
          count{l} = count{l}+1;
          BaseLineEpoch{l}(:,:,count{l}) = Data(:,m+BaseLineRange(1)*Fs:m+BaseLineRange(2)*Fs);
          fprintf('Slicing BaseLine Data No.%.0f of Trigger No.%.0f\n',count{l},TriggerSelect(l));
          %BaseLineEpoch{i}(:,:,count) = Data(j+Time2SampleNum(BaseLineRange(1),Fs):j+Time2SampleNum(BaseLineRange(2),Fs),:);
      end
   end
end
clear count;

%% Compute BaseLine
for l=1:length(TriggerSelect)
    BaseLine{l} = repmat(mean(BaseLineEpoch{l},2),1,size(Average.Data{l},2));
end

for l=1:length(TriggerSelect)
   Average.Data{l} = Average.Data{l} - BaseLine{l}; 
end

%% Evaluate Each Epoch Data
%Average.Accepted{length(TriggerSelect)} = 0;
for l=1:length(TriggerSelect)
    [Row,Column,Dimension] = size(Average.Data{l});
    if Threshold(1) ~= 0 || Threshold(2) ~= 0
       for m=1:Dimension
           temp = mean(squeeze(Average.Data{l}(:,:,m)),1);
           AllRangeBandPower = bandpower(temp',Fs,FilterRange);
           AlphaRangeBandPower = bandpower(temp',Fs,[8 13]);
           PerPower = 100*(AlphaRangeBandPower/AllRangeBandPower);
           if (min(temp(:)) < Threshold(1)) || (max(temp(:)) > Threshold(2))
                    Average.Data{l}(:,:,m) = zeros(Row,Column);
                    Average.Accepted{l}(m) = 0;
           else
               if PerPower > AlphaThreshold
                    Average.Data{l}(:,:,m) = zeros(Row,Column);
                    Average.Accepted{l}(m) = 0;
               else
                    Average.Accepted{l}(m) = 1;
               end
           end
       end
    end
    Average.Accepted{l} = Average.Accepted{l}';
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

temp = 0;
for l=1:size(Average.Accepted,2)
    temp = temp + Average.Accepted{l};
end
if temp ~= 0
    Average.Data = Average.Temporary;
    Average = rmfield(Average,'Temporary');
end
for l=1:length(TriggerSelect)
    fprintf('Trigger No.%.0f, Accepted Epoch Data : %.0f of %.0f\n',TriggerSelect(l),Average.Accepted{l},Average.NumAllEpoch{l});
end

%% Averaging
EpochTime = Range(1):1/Fs:Range(2);
EpochTime = EpochTime';

Epoch.Data = Average.Data;

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
   [Row,Column,Dimension] = size(Average.Data{l});
   for m=1:Dimension
       Average.AllAveraged{l} = mean(Average.Data{l},3);
   end
end

%% Down Sampling

if DownSamplingRate ~= 1
    for l=1:length(TriggerSelect)
        for m=1:size(Average.Data{l},3)
            for n=1:size(Average.Data{l},1)
            Average.DownSampled{l}(n,:,m) = decimate(Average.Data{l}(n,:,m),DownSamplingRate);
            end
        end
    end
end

save('./EpochData.mat','Average','EpochTime','Fs','Label');
