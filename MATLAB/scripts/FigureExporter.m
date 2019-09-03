fig = gcf;
fig.PaperUnits = 'inches';

fig.PaperPosition = [0 0 30 15]; % 64ch EEG
%fig.PaperPosition = [0 0 20 5]; % TopoGraph


%fig.PaperPosition = [0 0 80 50]; % 64ch EEG
%fig.PaperPosition = [0 0 80 20]; % TopoGraph

%fig.PaperPosition = [0 0 50 80];
print(fig.Name,'-dbmp')

%print(fig.Name,'-dmeta','-r300')

%print(FileSaveName,'-dmeta')

%Done();