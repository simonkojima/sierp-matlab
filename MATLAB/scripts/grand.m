clearvars
close all

name{1} = '20210514_B35_overlap';
name{2} = '20210520_B41_overlap';
name{3} = '20210525_B68_overlap';
name{4} = '20210604_B47_overlap';

color = {'r','b'};

ch = 1:64;

num = 2;

%epochs = [];

%--------------------------------------------------------------------------
% concatenate data sets

for m = 1:num
   for n = 1:num
      tmp{m}{n} = []; 
   end
end

for m = 1:4
   load(name{m}) ;
    tmp{1}{1} = cat(3,tmp{1}{1},epochs.att{1}.get_epoch_data(3,ch));
    tmp{1}{2} = cat(3,tmp{1}{2},epochs.att{1}.get_epoch_data(4,ch));
   
    tmp{2}{1} = cat(3,tmp{2}{1},epochs.att{2}.get_epoch_data(3,ch));
    tmp{2}{2} = cat(3,tmp{2}{2},epochs.att{2}.get_epoch_data(4,ch));
end

%--------------------------------------------------------------------------
% plot

for dev =1:num
    for m=1:num
        if m == dev %dev
            type{m} = 'dev';
        else
            type{m} = 'std';
        end
        %data{dev}{m} = sieeg(epochs.att{dev}.get_epoch_data(trig(m),ch_eeg),'time',epochs.att{dev}.epochs{m}.time,'type',type{m},'color',color{m},'legend',strcat('Responses to D',num2str(m)),'fs',epochs.att{dev}.fs);
        data{dev}{m} = sieeg(tmp{dev}{m},'time',epochs.att{dev}.epochs{m}.time,'type',type{m},'color',color{m},'legend',strcat('D',num2str(m)),'fs',epochs.att{dev}.fs);
    end
end



figuretitle = sprintf('Attended to %d',dev);

%ch = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};
ch = {'Cz'};

%color = {'r','g','b'};
test = siPlot(data,'div',[1 2]);
test.plotdata(1,32,1)
test.plotdata(2,32,2)
%test.plotdata(2,32,3)
test.ttest(0.05,[0.7 0.7 0.7]);
test.drawYaxis(1.5);
test.drawXaxis(1.5);
test.replotdata();
%test.title();
test.setnegup();
test.setallcolor(color);
%test.setallstyle(style);
test.setalllinewidth(2);
test.setallfontsize(20);
test.xlabel('Time (s)');
test.ylabel('Potential (\muV)');
%test.legend(1,{'std','dev'});
test.legend(1);
test.legend(2);

topo = siTopo(data,'64ch.ced',[-5 5],'div',[1 2]);


% att, dev
topo.plot(1,1,0.15,1);
topo.plot(1,2,0.15,2);
% 
%topo.win_plot(1,1,[0.25 0.35],1);
%topo.win_plot(1,2,[0.25 0.35],2);

% test.win_plot(2,1,[0.2 0.4],1);
% test.win_plot(2,2,[0.2 0.4],2);