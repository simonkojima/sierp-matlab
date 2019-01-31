
FileSaveName = 'B33_Stream3';

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 80 50];

%fig.PaperPosition = [0 0 80 20];

%fig.PaperPosition = [0 0 50 80];
print(FileSaveName,'-dbmp')

Done();