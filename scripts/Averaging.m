close all;
clearvars
%% ------------------------------------------------------------------------
%Averaging
%Author : Simon Kojima
%Version : 10

%All data must have the following format!!
%Data : Number of Sample x Number of Channel
%Time : Number of Sample x 1
%Trigger : Number of Sample x1

%% ------------------------------------------------------------------------

TriggerSelect = [1 5];
PlotColor = {'b','r'};

Files = [1 4];              %Suffix of Files
PreFileName = '20180523_P300_Stream_B33_000';
Range = [-0.1 0.5];         %(s s)
Threshold = [-100 100];       %min max (uV uV)
BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [1 40];
AlphaThreshold = 100;        %(%)

PlotYRange = [-6 11];         %ylabel Range (uV uV)
PlotDivision = [3 3];
PlotPosition = [1 2 3 5 7 8 9];
PlotYLabel = 'Potential (\muV)';
PlotXLabel = 'Time (ms)';

Temp.Data = [];
Temp.Trigger = [];
for i=Files(1):Files(2)
    FileName = sprintf(strcat(PreFileName,'%d.mat'),i);
    load(FileName);
    [B, A] = butter(2, FilterRange/(Fs/2), 'bandpass');
    Data = filtfilt(B, A, Data')';
    Temp.Data = [Temp.Data Data];
    Temp.Trigger = [Temp.Trigger Trigger];
end

Data = Temp.Data;
Trigger = Temp.Trigger;

%fprintf('Size : %f\n',size(temp));

%% Slicing Epoch Data
%Average.Data{length(TriggerSelect)} = zeros(length(i+Time2SampleNum(Range(1),Fs):i+Time2SampleNum(Range(2),Fs)),NChannel);
%[NSample, NChannel] = size(Data);
for i=1:length(TriggerSelect)
   count{i} = 0;
   for j=1:length(Trigger)
      if Trigger(j) == TriggerSelect(i)
          count{i} = count{i}+1;
          Average.Data{i}(:,:,count{i}) = Data(:,j+Range(1)*Fs:j+Range(2)*Fs);
          fprintf('Slicing Epoch Data No.%.0f of Trigger No.%.0f\n',count{i},TriggerSelect(i));
      end
   end
end
clear count;

%% Base Line
%BaseLineEpoch{length(TriggerSelect)} = zeros(length(i+Time2SampleNum(BaseLineRange(1),Fs):i+Time2SampleNum(BaseLineRange(2),Fs)),NChannel);
for i=1:length(TriggerSelect)
    count{i} = 0;
   for j=1:length(Trigger)
      if Trigger(j) == TriggerSelect(i)    
          count{i} = count{i}+1;
          BaseLineEpoch{i}(:,:,count{i}) = Data(:,j+BaseLineRange(1)*Fs:j+BaseLineRange(2)*Fs);
          fprintf('Slicing BaseLine Data No.%.0f of Trigger No.%.0f\n',count{i},TriggerSelect(i));
          %BaseLineEpoch{i}(:,:,count) = Data(j+Time2SampleNum(BaseLineRange(1),Fs):j+Time2SampleNum(BaseLineRange(2),Fs),:);
      end
   end
end
clear count;

%% Compute BaseLine
for i=1:length(TriggerSelect)
    BaseLine{i} = repmat(mean(BaseLineEpoch{i},2),1,size(Average.Data{i},2));
end

for i=1:length(TriggerSelect)
   Average.Data{i} = Average.Data{i} - BaseLine{i}; 
end

%% Evaluate Each Epoch Data
%Average.Accepted{length(TriggerSelect)} = 0;
for i=1:length(TriggerSelect)
    [Row,Column,Dimension] = size(Average.Data{i});
    if Threshold(1) ~= 0 || Threshold(2) ~= 0
       for j=1:Dimension
           temp = mean(squeeze(Average.Data{i}(:,:,j)),1);
           AllRangeBandPower = bandpower(temp',Fs,FilterRange);
           AlphaRangeBandPower = bandpower(temp',Fs,[8 13]);
           PerPower = 100*(AlphaRangeBandPower/AllRangeBandPower);
           if (min(temp(:)) < Threshold(1)) || (max(temp(:)) > Threshold(2))
                    Average.Data{i}(:,:,j) = zeros(Row,Column);
                    Average.Accepted{i}(j) = 0;
           else
               if PerPower > AlphaThreshold
                    Average.Data{i}(:,:,j) = zeros(Row,Column);
                    Average.Accepted{i}(j) = 0;
               else
                    Average.Accepted{i}(j) = 1;
               end
           end
       end
    end
    %Average.Accepted{i} = Average.Accepted{i}';
end
clear temp

for i=1:size(Average.Data,2)
    count = 0;
    Average.NumAllEpoch{i} = size(Average.Data{i},3);
    for j=1:size(Average.Data{i},3)
       if Average.Accepted{i}(j) == 1
           count = count+1;
           Average.Temporary{i}(:,:,count) = Average.Data{i}(:,:,j);
       end
    end
    Average.Accepted{i} = sum(Average.Accepted{i});
end
clear count;

Average.Data = Average.Temporary;
Average = rmfield(Average,'Temporary');

for i=1:length(TriggerSelect)
    fprintf('Trigger No.%.0f, Accepted Epoch Data : %.0f of %.0f\n',TriggerSelect(i),Average.Accepted{i},Average.NumAllEpoch{i});
end

%% Averaging
EpochTime = Range(1):1/Fs:Range(2);
EpochTime = EpochTime';

for i=1:length(TriggerSelect)
   [Row,Column,Dimension] = size(Average.Data{i});
   for j=1:Dimension
       Average.Data{i} = mean(Average.Data{i},3);
   end
end

%% Plot

Figure1 = figure('Name','Result','NumberTitle','off');
for i=1:length(TriggerSelect)
    [Row,Column,Dimension] = size(Average.Data{i});
    for j=1:Row
        subplot(PlotDivision(1),PlotDivision(2),PlotPosition(j));
        plot(EpochTime,Average.Data{i}(j,:),PlotColor{i});
        hold on
        ylim(PlotYRange)
        xlim(Range)
        ylabel({Label{j},PlotYLabel});
        xlabel(PlotXLabel);
        xticks(-0.1:0.1:0.5);
        xticklabels({'-100','0','100','200','300','400','500'});
        axis ij
    end
end

for i=1:Row
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(i));
    plot(xlim, [0 0], 'k');
    plot([0 0], ylim, 'k');
    legend('Standard','Deviant');
end
hold off