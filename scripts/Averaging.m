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

TriggerSelect = [1 5];
PlotColor = {'b','r'};
FillingColor = [0.7 0.7 0.7]; %gray

Files = [1 3];              %Suffix of Files
PreFileName = '20181001_B35_000';
Range = [-0.1 0.5];         %(s s)
Threshold = [-100 100];       %min max (uV uV)
BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [0.1 40];
AlphaThreshold = 100;        %(%)
EOGEnable = 1;
NumChannel = 64;

TTestAlpha = 0.5;

PlotYRange = [-7 7];         %ylabel Range (uV uV) [0 0] -> Auto
% PlotDivision = [3 3];
% PlotPosition = [1 2 3 5 7 8 9];
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
    if EOGEnable == 1
        EOGData = Data(NumChannel+1:NumChannel+2,:);
    end
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
    %Average.Accepted{i} = Average.Accepted{i}';
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
EpochTime = Range(1):1/Fs:Range(2);
EpochTime = EpochTime';

TTest.h = [];
TTest.p = [];
for l=1:NumChannel
    [h,p,ci,stats] = ttest2(permute(Average.Data{1}(1,:,:),[3 2 1]),permute(Average.Data{2}(1,:,:),[3 2 1]),'Alpha',TTestAlpha);
    TTest.h(l,:) = h;
    TTest.p(l,:) = p;
end

for l=1:length(TriggerSelect)
   for m=1:size(Average.Data{l},3)
       Average.Data{l} = mean(Average.Data{l},3);
   end
end

%% Plot

Figure1 = figure('Name','Result','NumberTitle','off');
flag = 0;
for l=1:length(TriggerSelect)
    for m=1:size(Average.Data{l},1)
        subplot(PlotDivision(1),PlotDivision(2),PlotPosition(m));
        if flag == 0
            for n=1:size(TTest.h,2)
                if sum(abs(PlotYRange)) ~= 0
                    yrange = PlotYRange;
                else
                    yrange(1) = min(Average.Data{l}(m,:));
                    yrange(2) = max(Average.Data{l}(m,:));
                end
                if TTest.h(l,n) == 1
                    rectangle('Position',[(n-1)/Fs+Range(1) yrange(1) 1/Fs yrange(2)-yrange(1)],'FaceColor',FillingColor,'EdgeColor',FillingColor);
                end
                clear yrange
            end
        end
        hold on
        plot(EpochTime,Average.Data{l}(m,:),PlotColor{l});
        if sum(abs(PlotYRange)) ~= 0
            ylim(PlotYRange)
        end
        xlim(Range)
        %ylabel({Label{j},PlotYLabel});
        ylabel(Label{m});
        %xlabel(PlotXLabel);
        xticks(-0.1:0.1:0.5);
        %xticklabels({'-100','0','100','200','300','400','500'});
        axis ij
    end
    flag = 1;
end

for l=1:size(Average.Data{l},1)
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(l));
    plot(xlim, [0 0], 'k');
    plot([0 0], ylim, 'k');
%     for m=1:size(TTest.h,2)
%         yrange = ylim;
%         if TTest.h(l,m) == 1
%             rectangle('Position',[(m-1)/Fs+Range(1) yrange(1) 1/Fs yrange(2)-yrange(1)],'FaceColor',FillingColor,'EdgeColor',FillingColor);
%         end
%         clear yrange
%     end
    %legend('Standard','Deviant');
end
hold off