clearvars
close all

load 'LowStream.mat'
Stream{1} = Average;

load 'MidStream.mat'
Stream{2} = Average;

load 'HighStream.mat'
Stream{3} = Average;

DeviantSelection = 3;

Range = [-0.1 0.4];

Time = Range(1):0.05:Range(2);
Time = 0.38;

PlotDivision = [6 2];
PlotPosition = 1:12;
%PlotPosition = [4 8 13 15 17 19 21 24 25 26 27 28 29 30 31 32 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 56 57 58 59 60 61 62 63 64 65 66 68 69 70 71 72 73 74 75 76 79 81 83 85 87 92 94 96];

TopoPlotRange = [-7.5 7.5];

TimeLabel = {'-100ms','-50ms','0ms','50ms','100ms','150ms','200ms','250ms','300ms','350ms','400ms'};

for l=1:size(Time,2)
    subplot(PlotDivision(1),PlotDivision(2),PlotPosition(l));
    hold on
    %topoplot(Stream{DeviantSelection}.AllAveraged{DeviantSelection},'maplimits',TopoPlotRange)
    [M,I] = min(abs(EpochTime-Time(l)));
    topoplot(Stream{DeviantSelection}.AllAveraged{DeviantSelection}(:,I),'64ch.ced','maplimits',TopoPlotRange,'whitebk','on');
    title(TimeLabel{l},'FontWeight','normal','FontSize',40);
end

subplot(PlotDivision(1),PlotDivision(2),PlotPosition(end));
topoplot(zeros(64,1),'64ch.ced','maplimits',TopoPlotRange,'whitebk','on');
colorbar;
%colorbar('fontsize',15);

set(gca,'FontSize',40)

