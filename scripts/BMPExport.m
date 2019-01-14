
FileSaveName = 'B36_Compare_Diff';

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 80 50];
%fig.PaperPosition = [0 0 50 80];
print(FileSaveName,'-dbmp')