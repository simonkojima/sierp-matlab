clearvars
close all

load 'LowStream.mat'
Stream{1} = Average;

load 'MidStream.mat'
Stream{2} = Average;

load 'HighStream.mat'
Stream{3} = Average;

DeviantSelection = 1;

Range = [-0.1 0.4];

Time = Range(1):0.05:Range(2);
%Time = 0.38;

PlotDivision = [3 11];
PlotPosition = 1:33;
PlotFontSize = 20; %80 %20

TopoPlotRange = [-10 10]; % -> B33,B36 : 10, B35 : 12

TimeLabel = {'-100ms','-50ms','0ms','50ms','100ms','150ms','200ms','250ms','300ms','350ms','400ms'};

Count = 0;
for m = 1:3
    
    for l=1:size(Time,2)
        Count = Count + 1;
        subplot(PlotDivision(1),PlotDivision(2),Count);
        hold on
        %topoplot(Stream{DeviantSelection}.AllAveraged{DeviantSelection},'maplimits',TopoPlotRange)
        [M,I] = min(abs(EpochTime-Time(l)));
        
        if m==1
            topoplot(Stream{m}.AllAveraged{2*DeviantSelection}(:,I)-Stream{m}.AllAveraged{2*DeviantSelection-1}(:,I),'64ch.ced','maplimits',TopoPlotRange,'whitebk','on');
            title(TimeLabel{l},'FontWeight','normal','FontSize',PlotFontSize);
        else
            topoplot(Stream{m}.AllAveraged{2*DeviantSelection}(:,I)-Stream{m}.AllAveraged{2*DeviantSelection-1}(:,I),'64ch.ced','maplimits',TopoPlotRange,'whitebk','on');
        end
    end
    
end

return

for l=1:size(Time,2)
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(l));
    hold on
    %topoplot(Stream{DeviantSelection}.AllAveraged{DeviantSelection},'maplimits',TopoPlotRange)
    [M,I] = min(abs(EpochTime-Time(l)));
    topoplot(Stream{DeviantSelection}.AllAveraged{DeviantSelection}(:,I),'64ch.ced','maplimits',TopoPlotRange,'whitebk','on');
    title(TimeLabel{l},'FontWeight','normal','FontSize',PlotFontSize);
end

subplot(PlotDivision(1),PlotDivision(2),PlotPosition(end));
topoplot(zeros(64,1),'64ch.ced','maplimits',TopoPlotRange,'whitebk','on');
colorbar;
%colorbar('fontsize',15);

set(gca,'FontSize',PlotFontSize)

