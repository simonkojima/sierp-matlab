close all
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

TriggerSelect = [2 8 130];
PlotColor = {'b','r','k'};

Files = [5 8];              %Suffix of Files
PreFileName = '20181022_B35_000';
Range = [-0.1 0.5];         %(s s)
Threshold = [-50 50];       %min max (uV uV)
BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [0.1 40];
AlphaThreshold = 100;        %(%)

NumChannel = 64;

PlotYRange = [-7 7];         %ylabel Range (uV uV) [0 0] -> Auto
%PlotDivision = [3 3];
%PlotPosition = [1 2 3 5 7 8 9];
PlotDivision = [9 11];
PlotPosition = [4 8 13 15 17 19 21 24 25 26 27 28 29 30 31 32 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 56 57 58 59 60 61 62 63 64 65 66 68 69 70 71 72 73 74 75 76 79 81 83 85 87 92 94 96];
PlotYLabel = 'Potential (\muV)';
PlotXLabel = 'Time (ms)';

Temp.Data = [];
Temp.Trigger = [];
for l=Files(1):Files(2)
    FileName = sprintf(strcat(PreFileName,'%d.mat'),l);
    load(FileName);
    [B, A] = butter(2, FilterRange/(Fs/2), 'bandpass');
    EOGData = Data(NumChannel+1:NumChannel+2,:);
    Data = Data(1:NumChannel,:);
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
for l=1:length(TriggerSelect)
   count{l} = 0;
   for j=1:length(Trigger)
      if Trigger(j) == TriggerSelect(l)
          count{l} = count{l}+1;
          Average.Data{l}(:,:,count{l}) = Data(:,j+Range(1)*Fs:j+Range(2)*Fs);
          fprintf('Slicing Epoch Data No.%.0f of Trigger No.%.0f\n',count{l},TriggerSelect(l));
      end
   end
end
clear count;

%% Base Line
%BaseLineEpoch{length(TriggerSelect)} = zeros(length(i+Time2SampleNum(BaseLineRange(1),Fs):i+Time2SampleNum(BaseLineRange(2),Fs)),NChannel);
for l=1:length(TriggerSelect)
    count{l} = 0;
   for j=1:length(Trigger)
      if Trigger(j) == TriggerSelect(l)    
          count{l} = count{l}+1;
          BaseLineEpoch{l}(:,:,count{l}) = Data(:,j+BaseLineRange(1)*Fs:j+BaseLineRange(2)*Fs);
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
       for j=1:Dimension
           temp = mean(squeeze(Average.Data{l}(:,:,j)),1);
           AllRangeBandPower = bandpower(temp',Fs,FilterRange);
           AlphaRangeBandPower = bandpower(temp',Fs,[8 13]);
           PerPower = 100*(AlphaRangeBandPower/AllRangeBandPower);
           if (min(temp(:)) < Threshold(1)) || (max(temp(:)) > Threshold(2))
                    Average.Data{l}(:,:,j) = zeros(Row,Column);
                    Average.Accepted{l}(j) = 0;
           else
               if PerPower > AlphaThreshold
                    Average.Data{l}(:,:,j) = zeros(Row,Column);
                    Average.Accepted{l}(j) = 0;
               else
                    Average.Accepted{l}(j) = 1;
               end
           end
       end
    end
    %Average.Accepted{i} = Average.Accepted{i}';
end
clear temp

for l=1:size(Average.Data,2)
    count = 0;
    Average.NumAllEpoch{l} = size(Average.Data{l},3);
    for j=1:size(Average.Data{l},3)
       if Average.Accepted{l}(j) == 1
           count = count+1;
           Average.Temporary{l}(:,:,count) = Average.Data{l}(:,:,j);
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
EpochTime = Range(1):1/Fs:Range(2);
EpochTime = EpochTime';

for l=1:length(TriggerSelect)
   [Row,Column,Dimension] = size(Average.Data{l});
   for j=1:Dimension
       Average.Data{l} = mean(Average.Data{l},3);
   end
end

%% Plot

Figure1 = figure('Name','Result','NumberTitle','off');
for l=1:length(TriggerSelect)
    [Row,Column,Dimension] = size(Average.Data{l});
    for j=1:Row
        subplot(PlotDivision(1),PlotDivision(2),PlotPosition(j));
        plot(EpochTime,Average.Data{l}(j,:),PlotColor{l});
        hold on
        if sum(PlotYRange) ~= 0
            ylim(PlotYRange)
        end
        xlim(Range)
        %ylabel({Label{j},PlotYLabel});
        ylabel(Label{j});
        %xlabel(PlotXLabel);
        xticks(-0.1:0.1:0.5);
        %xticklabels({'-100','0','100','200','300','400','500'});
        axis ij
    end
end

for l=1:Row
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(l));
    plot(xlim, [0 0], 'k');
    plot([0 0], ylim, 'k');
    %legend('Standard','Deviant');
end
hold off