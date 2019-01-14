clearvars
close all

load ChannelLabel.mat

load ./Tone.mat
Tone = Average;

load ./Piano.mat
Piano = Average;

DifferenceEnable = 1;

if DifferenceEnable == 1
    
    for l=1:size(Tone.AllAveraged{1},1)
        Tone.AllAveraged{2}(l,:) = Tone.AllAveraged{2}(l,:) - Tone.AllAveraged{1}(l,:);
    end
    
    for l=1:size(Piano.AllAveraged{1},1)
        Piano.AllAveraged{2}(l,:) = Piano.AllAveraged{2}(l,:) - Piano.AllAveraged{1}(l,:);
    end
    
end

figure('Name','Result','NumberTitle','off');

Range = [-0.1 0.5];
Fs = 1000;
EpochTime = Range(1):1/Fs:Range(2);
EpochTime = EpochTime';

Channel = 1:64;

FillingColor = [0.7 0.7 0.7];

PlotYLabel = 'Potential (\muV)';
PlotXLabel = 'Time (ms)';

PlotDivision = [9 11];
PlotPosition = [4 8 13 15 17 19 21 24 25 26 27 28 29 30 31 32 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 56 57 58 59 60 61 62 63 64 65 66 68 69 70 71 72 73 74 75 76 79 81 83 85 87 92 94 96];

TTestEnable = 1;
TTestAlpha = 0.01;

for l=1:length(Channel)
    
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(l));
    
    yrange = [-13 10];
    
    if TTestEnable == 1
        
        TTest.h = [];
        TTest.p = [];
        
        %[h,p,ci,stats] = ttest2(permute(Stream{DeviantSelection}.Data{DeviantSelection}(Channel(l),:,:),[3 2 1]),permute(cat(3,Stream{forcat(DeviantSelection+1)}.Data{DeviantSelection}(Channel(l),:,:),Stream{forcat(DeviantSelection+2)}.Data{DeviantSelection}(Channel(l),:,:)),[3 2 1]),'Alpha',TTestAlpha);
        
        [h,p,ci,stats] = ttest2(permute(Tone.Data{2}(Channel(l),:,:),[3 2 1]),permute(Piano.Data{2}(Channel(l),:,:),[3 2 1]),'Alpha',TTestAlpha);
        
        TTest.h(l,:) = h;
        TTest.p(l,:) = p;
        
    end
    
    for m=1:length(EpochTime)
        if TTest.h(l,m) == 1
            rectangle('Position',[(m-1)/Fs+Range(1) yrange(1) 1/Fs (yrange(2)-yrange(1))],'FaceColor',FillingColor,'EdgeColor',FillingColor);
        end
    end
    
    hold on
    plot(EpochTime,Tone.AllAveraged{2}(l,:),'b','LineWidth',5);
    plot(EpochTime,Piano.AllAveraged{2}(l,:),'r','LineWidth',5);
    
    axis ij
    
    ylim(yrange);
    xlim(Range);
    ylabel(PlotYLabel);
    xlabel({PlotXLabel});
    
    plot(xlim, [0 0], 'k','LineWidth',2);
    plot([0 0], ylim, 'k','LineWidth',2);
    
    title(Label{Channel(l)},'FontWeight','normal');
    
    xticks([-0.1 0.1 0.3 0.5 ]);
    xticklabels({'-0.1','0.1','0.3','0.5'});
    
    axis ij
    
    %legend('Stream 1','Stream 2','Stream 3');
    
    set(gca,'FontSize',40)
    
    
end

% return
% plot(EpochTime,Tone.AllAveraged{2}(Ch,:),'b');
% hold on
% plot(EpochTime,Piano.AllAveraged{2}(Ch,:),'r');

% axis ij
%
% plot(xlim, [0 0], 'k');
% plot([0 0], ylim, 'k');