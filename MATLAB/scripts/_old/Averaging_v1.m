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

TriggerSelect = [1 2];
PlotColor = {'b','r'};

%TriggerSelect = [1 2 4 8];
%PlotColor = {'b','k','r','c'};

FillingColor = [0.7 0.7 0.7]; %gray

Files = [1 4];              %Suffix of Files
PreFileName = '20181121_B35_Stream_';
Range = [-0.1 1];         %(s s)
EEGThreshold = [-300 300];       %min max (uV uV)
EOGThreshold = [-500 500];
BaseLineRange = [-0.05 0];  %(s s)
FilterRange = [0.1 40];
AlphaThreshold = 100;        %(%)

FilterOrder = 2;
TTestAlpha = 0.05;
TTestEnable = 0;
DownsampleRate = 2;

EOGEnable = 1;
NumChannel = 64;
PlotDivision = [9 11];
PlotPosition = [4 8 13 15 17 19 21 24 25 26 27 28 29 30 31 32 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 56 57 58 59 60 61 62 63 64 65 66 68 69 70 71 72 73 74 75 76 79 81 83 85 87 92 94 96];

% EOGEnable = 0;
% NumChannel = 7;
% PlotDivision = [3 3];
% PlotPosition = [1 2 3 5 7 8 9];


PlotYRange = [0 0];         %ylabel Range (uV uV) [0 0] -> Auto


PlotYLabel = 'Potential (\muV)';
PlotXLabel = 'Time (ms)';

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
            temp = squeeze(Average.Data{l}(1:NumChannel,:,m));
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
        temp = squeeze(Average.Data{l}(NumChannel+1:NumChannel+2,:,m));
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


%TTest

TTest.h = [];
TTest.p = [];

if TTestEnable == 1
    for l=1:NumChannel
        [h,p,ci,stats] = ttest2(permute(Average.Data{1}(1,:,:),[3 2 1]),permute(Average.Data{2}(1,:,:),[3 2 1]),'Alpha',TTestAlpha);
        TTest.h(l,:) = h;
        TTest.p(l,:) = p;
    end
else
    TTest.h = zeros(NumChannel,length(EpochTime));
end

for l=1:length(TriggerSelect)
    for m=1:size(Average.Data{l},3)
        Average.Data{l} = mean(Average.Data{l},3);
    end
end

%% Plot

%Get Maximum
AdaptedYRange = [];
if sum(abs(PlotYRange)) == 0
    for l=1:NumChannel
        temp = [];
        for m=1:length(TriggerSelect)
            temp(m,:) = Average.Data{m}(l,:);
        end
        AdaptedYRange(l,1) = min(min(temp));
        AdaptedYRange(l,2) = max(max(temp));
    end
end

fprintf('Plotting.....\n');
Figure1 = figure('Name','Result','NumberTitle','off');
flag = 0;
for l=1:length(TriggerSelect)
    for m=1:NumChannel
        subplot(PlotDivision(1),PlotDivision(2),PlotPosition(m));
        if flag == 0
            for n=1:size(TTest.h,2)
                if sum(abs(PlotYRange)) ~= 0
                    yrange = PlotYRange;
                else
                    yrange(1) = AdaptedYRange(m,1);
                    yrange(2) = AdaptedYRange(m,2);
                end
                if TTest.h(l,n) == 1
                    rectangle('Position',[(n-1)/Fs+Range(1) yrange(1) 1/Fs (yrange(2)-yrange(1))],'FaceColor',FillingColor,'EdgeColor',FillingColor);
                end
            end
        end
        hold on
        plot(EpochTime,Average.Data{l}(m,:),PlotColor{l});
        xlim(Range)
        %ylabel({Label{j},PlotYLabel});
        ylabel(Label{m});
        %xlabel(PlotXLabel);
        %xticks(-0.1:0.1:0.5);
        %xticklabels({'-100','0','100','200','300','400','500'});
        axis ij
    end
    flag = 1;
end

for l=1:NumChannel
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(l));
    if sum(abs(PlotYRange)) ~= 0
        ylim(PlotYRange);
    else
        ylim(AdaptedYRange(l,:));
    end
    plot(xlim, [0 0], 'k');
    plot([0 0], ylim, 'k');
end
hold off