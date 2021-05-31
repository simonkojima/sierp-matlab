clearvars
close all


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

test = siTopo(data,'64ch.ced',[-5 5],'div',[1 2]);

return

% att, dev
test.plot(2,1,0.22,1);
test.plot(2,2,0.22,2);

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
