close all

load ./Tone.mat
Tone = Average;

load ./Piano.mat
Piano = Average;

Ch = 32;

figure();

plot(EpochTime,Tone.AllAveraged{2}(Ch,:),'b');
hold on
plot(EpochTime,Piano.AllAveraged{2}(Ch,:),'r');

axis ij

plot(xlim, [0 0], 'k');
plot([0 0], ylim, 'k');

legend('Tone','Piano')

PlotYLabel = 'Potential (\muV)';
PlotXLabel = 'Time (ms)';

ylabel({Label{Ch},PlotYLabel});
%ylabel(Label{Channel(l)});
xlabel(PlotXLabel);
%xticks(range(1):0.1:Range(2));
%xticklabels({'-100','0','100','200','300','400','500'});
xticklabels({'0','100','200','300','400','500','600','700','800','900','1000'});

set(gca,'FontSize',14)