clearvars
%close all


[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

num = 2;

ch_eeg = 1:64;

trig = trig_sel;

for dev = 1:num
    for m = 1:num
        data{dev}{m} = sieeg(epochs.att{dev}.get_epoch_data(trig(m),ch_eeg),'time',epochs.att{dev}.epochs{m}.time);
    end
end

test = siTopo(data,'64ch.ced',[-10 10],'div',[1 2]);

test.play(1,1,30,[0.25 0.35]);

% att, dev
% test.plot(1,1,0.3,1);
% test.plot(1,2,0.3,2);
% 
%test.win_plot(1,1,[0.25 0.35],1);
%test.win_plot(1,2,[0.25 0.35],2);

% test.win_plot(2,1,[0.2 0.4],1);
% test.win_plot(2,2,[0.2 0.4],2);

% plot(attended_to,responses_to,time,subplot)

return
idx_subplot = 0;
time = 0.39;
for m = 1:4
    %for n = 1:5
        idx_subplot = idx_subplot + 1;
        %test.plot(idx,m,time(n));
        test.plot(1,idx_subplot,m,time);
    %end
end
