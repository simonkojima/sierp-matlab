clearvars
%close all

[~,foldername] = fileparts(pwd);
load(foldername)

ch_eeg = 1:64;

trig = trig_sel;

data{1}{1} = sieeg(epochs.att{1}.get_epoch_data(1,ch_eeg),'time',epochs.att{1}.epochs{1}.time);
data{1}{2}= sieeg(epochs.att{1}.get_epoch_data(2,ch_eeg),'time',epochs.att{1}.epochs{2}.time);
data{1}{3}= sieeg(epochs.att{1}.get_epoch_data(3,ch_eeg),'time',epochs.att{1}.epochs{3}.time);

test = siTopo(data,'64ch.ced',[-10 10],'div',[4 7]);

%test.play(1,1,30,[0.27 0.33]);

% att, dev
%test.plot(3,3,0.238,1);
% test.plot(1,2,0.3,2);

%win = [0.263 0.31];

%test.win_plot(2,1,win,1);
%test.win_plot(2,2,win,2);

% test.win_plot(2,1,[0.2 0.4],1);
% test.win_plot(2,2,[0.2 0.4],2);

% plot(attended_to,responses_to,time,subplot)

idx_subplot = 0;
for time = 0.04:0.02:0.58
        idx_subplot = idx_subplot + 1;
        test.plot(1,2,time,idx_subplot);
        title(sprintf('%dms',floor(time*1000)));
        set(gca,'fontsize',20)
end