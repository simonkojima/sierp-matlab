clearvars
%close all

[~,foldername] = fileparts(pwd);
load(foldername)

color = {'k','r','b'};
%style = {'-','--',':','-.'};

ch_eeg = 1:64;

trig = trig_sel;

data{1}{1} = sieeg(epochs.att{1}.get_epoch_data(1,ch_eeg),'time',epochs.att{1}.epochs{1}.time,'type','std','legend','Std','fs',epochs.att{1}.fs);
data{1}{2}= sieeg(epochs.att{1}.get_epoch_data(2,ch_eeg),'time',epochs.att{1}.epochs{2}.time,'type','std','legend','Dev_1','fs',epochs.att{1}.fs);
data{1}{3}= sieeg(epochs.att{1}.get_epoch_data(3,ch_eeg),'time',epochs.att{1}.epochs{3}.time,'type','dev','legend','Dev_2','fs',epochs.att{1}.fs);

%figuretitle = sprintf('Attended to %d',dev);

ch_label = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};
%ch = {'Cz'};

%color = {'r','g','b'};
ch_plot = [10 12 14 30 32 34 50 52 54];
test = siPlot(data,'div',[3 3]);
for m = 1:9
   test.plotdata(1,ch_plot(m),m);
   test.title(m,ch_label{m});
   test.ylim(m,[-13 13]);
end
% %test.plotdata(1,32,1)
% %test.plotdata(2,32,2)
% %test.plotdata(2,32,3)
test.ttest(0.01,[0.7 0.7 0.7]);
test.drawYaxis(1.5);
test.drawXaxis(1.5);
test.replotdata();
test.setnegup();
test.setallcolor(color);
%test.setallstyle(style);
test.setalllinewidth(2);
test.setallfontsize(20);
%test.xlabel('Time (s)');
%test.ylabel('Potential (\muV)');
%test.legend(1,{'std','dev'});
%test.legend(1);
%test.legend(2);
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



