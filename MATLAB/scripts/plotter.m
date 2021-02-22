clearvars
close all


[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

dev = 1;

color = {'k','k','k','k'};
style = {'-','--',':','-.'};

for l=1:4
    if l == dev
        type{l} = 'dev';
    else
        type{l} = 'std';
    end
    data{l} = EEG(epochs.att{dev}.dev{l},'type',type{l},'label',Label,'color',color{l},'legend',strcat('Responces to D',num2str(l)),'fs',Fs);
    %data{l} = EEG(epochs.att{l}.dev{dev});
end

figuretitle = sprintf('Attended to %d',dev);

%ch = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};
ch = {'Cz'};

%color = {'r','g','b'};
test = PLOT(data,EpochTime,'div',[3 3]);
%test = PLOT(data,EpochTime,'test','div',[1 1]);
test.plotdata(32,1)
test.plotdata(3,3)
test.ttest(0.05,[0.7 0.7 0.7]);
test.drawYaxis(1.5);
test.drawXaxis(1.5);
test.replotdata();
test.title();
test.setnegup();
test.setallcolor(color);
test.setallstyle(style);
test.setalllinewidth(2);
test.setallfontsize(18);
test.xlabel('Time (s)');
test.ylabel('Potential (\muV)');
test.legend();
%----------------------------------------------------------


test.deletettest();
test.ttest(0.05,[0.7 0.7 0.7]);
test.drawYaxis(1.5);
test.drawXaxis(1.5);
test.replotdata();
test.setallcolor(color);
test.setallstyle(style);
test.setalllinewidth(2);
test.setallfontsize(18);
