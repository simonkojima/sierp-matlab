clearvars
close all


[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

dev = 1;

num = 3;
color = {'r','g','b','c'};
%style = {'-','--',':','-.'};


for m=1:num
    if m == dev
        type{m} = 'dev';
    else
        type{m} = 'std';
    end
    data{1}{m} = sieeg(epochs.att{dev}.dev{m},'type',type{m},'label',Label,'color',color{m},'legend',strcat('Responses to D',num2str(m)),'fs',Fs);
    %data{l} = EEG(epochs.att{l}.dev{dev});
end

for m=1:2
    if m == dev
        type{m} = 'dev';
    else
        type{m} = 'std';
    end
    data{2}{m} = sieeg(epochs.att{m}.dev{dev},'type',type{m},'label',Label,'color',color{m},'legend',strcat('Responses to D',num2str(m)),'fs',Fs);
    %data{l} = EEG(epochs.att{l}.dev{dev});
end


figuretitle = sprintf('Attended to %d',dev);

%ch = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};
ch = {'Cz'};

%color = {'r','g','b'};
test = siPlot(data,EpochTime,'div',[2 2]);
test.plotdata(1,32,1)
test.plotdata(2,32,3)
test.ttest(0.1,[0.7 0.7 0.7]);
test.drawYaxis(1.5);
test.drawXaxis(1.5);
test.replotdata();
%test.title();
test.setnegup();
test.setallcolor(color);
%test.setallstyle(style);
test.setalllinewidth(2);
test.setallfontsize(18);
test.xlabel('Time (s)');
test.ylabel('Potential (\muV)');
%test.legend();
%----------------------------------------------------------

return
test.deletettest();
test.ttest(0.05,[0.7 0.7 0.7]);
test.drawYaxis(1.5);
test.drawXaxis(1.5);
test.replotdata();
test.setallcolor(color);
test.setalllinewidth(5);
test.setallfontsize(30);
%test.setallstyle(style);
%test.setalllinewidth(2);
%test.setallfontsize(18);
%test.legend();



