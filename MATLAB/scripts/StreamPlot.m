clearvars
close all


PlotYRange = [-5 5]; % -> B33,B36 : 10, B35 : 12
Channel = 1:64;
Range = [-0.1 0.5];
PlotYLabel = 'Potential (\muV)';
PlotXLabel = 'Time (s)';
FillingColor = [0.7 0.7 0.7];

PlotLineWidth = 1.5; %5 %1.5
PlotFontSize = 8; %40 %8

TTestEnable = 1;
TTestAlpha = 0.01;

load 'LowStream.mat'
Stream{1} = Average;

load 'MidStream.mat'
Stream{2} = Average;

load 'HighStream.mat'
Stream{3} = Average;

DeviantSelection = 3;

% StreamPlotColor{1} = {'r','b','b--'};
% StreamPlotColor{2} = {'b','r','b--'};
% StreamPlotColor{3} = {'b','b--','r'};

for l=1:3
    StreamPlotColor{l}  = {'r','g','b'};
end

figure('Name','Result','NumberTitle','off');

PlotChannelFileName = 'Plot64ch.mat';
load(PlotChannelFileName);


for l=1:length(Channel)
    
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(l));
    
    if TTestEnable == 1
        
        TTest.h = [];
        TTest.p = [];
        
        forcat = [1 2 3 1 2];
        
        %for l=1:length(Channel)
            [h,p,ci,stats] = ttest2(permute(Stream{DeviantSelection}.Data{DeviantSelection}(Channel(l),:,:),[3 2 1]),permute(cat(3,Stream{forcat(DeviantSelection+1)}.Data{DeviantSelection}(Channel(l),:,:),Stream{forcat(DeviantSelection+2)}.Data{DeviantSelection}(Channel(l),:,:)),[3 2 1]),'Alpha',TTestAlpha);
            TTest.h(l,:) = h;
            TTest.p(l,:) = p;
       % end
        
        %else
        %TTest.h = zeros(length(Channel),length(EpochTime));
    end
    
    
    %     AdaptedYRange = [];
    %     if sum(abs(PlotYRange)) == 0
    %         temp = [];
    %         for m=1:length(TriggerSelect)
    %             temp(m,:) = Average.Data{m}(Channel(l),:);
    %         end
    %         AdaptedYRange(1) = min(min(temp));
    %         AdaptedYRange(2) = max(max(temp));
    %     end
    
    %     flag = 0;
    %
    %     if flag == 0
    %         for m=1:size(TTest.h,2)
    %             if sum(abs(PlotYRange)) ~= 0
    %                 yrange = PlotYRange;
    %             else
    %                 yrange(1) = AdaptedYRange(1);
    %                 yrange(2) = AdaptedYRange(2);
    %             end
    
    %     if TTest.h(m,n) == 1
    %         rectangle('Position',[(n-1)/Fs+Range(1) yrange(1) 1/Fs (yrange(2)-yrange(1))],'FaceColor',FillingColor,'EdgeColor',FillingColor);
    %     end
    %             %return
    %             %clear yrange
    %         end
    %     end
    hold on
    
    for m=1:3
        %plot(EpochTime,Average.Data{m}(Channel(l),:),PlotColor{m});
        hold on
        plot(EpochTime,Stream{m}.AllAveraged{DeviantSelection}(Channel(l),:),StreamPlotColor{DeviantSelection}{m},'LineWidth',PlotLineWidth)
    end
    %     flag = 1;
    
    %yrange = [-5 5];
    yrange = PlotYRange;
    
%     for m=1:length(Channel)
        for m=1:length(EpochTime)
            if TTest.h(l,m) == 1
                rectangle('Position',[(m-1)/Fs+Range(1) yrange(1) 1/Fs (yrange(2)-yrange(1))],'FaceColor',FillingColor,'EdgeColor',FillingColor);
            end
        end
%     end
    
    ylim(yrange);
    xlim(Range);
    %ylabel({Label{Channel(l)},PlotYLabel});
    %ylabel(PlotYLabel);
    %ylabel(Label{Channel(l)});
    
    
    %xlabel({PlotXLabel,'Deviant 3'});
    %xlabel({PlotXLabel});
    
    %if l==1
        ylabel(PlotYLabel);
        xlabel({PlotXLabel});
    %end
    
    title(Label{Channel(l)},'FontWeight','normal');
    
    %xticks(Range(1):0.1:Range(2));
    %xticklabels({'-100','0','100','200','300','400','500'});
    %xticklabels({'-0.1','0','0.1','0.2','0.3','0.4','0.5'});
    %xticklabels({'0','100','200','300','400','500','600','700','800','900','1000'});
    
    xticks([-0.1 0.1 0.3 0.5]);
    xticklabels({'-0.1','0.1','0.3','0.5'});
    
    axis ij
    
    %legend('Stream 1','Stream 2','Stream 3');
    
    set(gca,'FontSize',PlotFontSize,'LineWidth',PlotLineWidth)
    
    plot(xlim, [0 0], 'k','LineWidth',PlotLineWidth);
    plot([0 0], ylim, 'k','LineWidth',PlotLineWidth);
    
    % 1: 0.37
%     plot([0.3 0.3],ylim,'k--','LineWidth',1.2);
%     
    for m=1:3
        plot(EpochTime,Stream{m}.AllAveraged{DeviantSelection}(Channel(l),:),StreamPlotColor{DeviantSelection}{m},'LineWidth',PlotLineWidth)
    end
    
end

%Done();

% return
% 
% pause
% DevSel = 3;
% StreamSel = 2;
% for m=1:size(Stream{StreamSel}.Data{DevSel},3)
%     %close all;
%     hold off
%     plot(EpochTime,Stream{StreamSel}.Data{DevSel}(32,:,m));
%     hold on
%     ylim([-50 50])
%     plot(xlim, [0 0], 'k');
%     plot([0 0], ylim, 'k');
%     axis ij
%     fprintf('%d of %d\n',m,size(Stream{StreamSel}.Data{DevSel},3));
%     pause
% end
% 
% close all
% %hold off