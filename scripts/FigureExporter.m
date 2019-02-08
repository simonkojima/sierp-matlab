
%FileSaveName = 'B33_Stream3';
FileSaveName = 'B33_Stream3_Topo';

fig = gcf;
fig.PaperUnits = 'inches';

%fig.PaperPosition = [0 0 20 12.5]; % 64ch EEG
fig.PaperPosition = [0 0 20 5]; % TopoGraph


%fig.PaperPosition = [0 0 80 50]; % 64ch EEG
%fig.PaperPosition = [0 0 80 20]; % TopoGraph

%fig.PaperPosition = [0 0 50 80];
%print(FileSaveName,'-dbmp')

print(FileSaveName,'-dmeta','-r300')

%print(FileSaveName,'-dmeta')

%Done();