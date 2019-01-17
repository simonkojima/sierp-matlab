
FileSaveName = 'B32_Compare_Topo_Standard';

fig = gcf;
fig.PaperUnits = 'inches';
%fig.PaperPosition = [0 0 80 50];
fig.PaperPosition = [0 0 80 20];
%fig.PaperPosition = [0 0 50 80];
print(FileSaveName,'-dbmp')