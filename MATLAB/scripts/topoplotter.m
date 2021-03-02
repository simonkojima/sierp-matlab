clearvars
close all


[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

dev = 3;

num = 3;

for l=1:num
    if l == dev
        type{l} = 'dev';
    else
        type{l} = 'std';
    end
    data{l} = EEG(epochs.att{dev}.dev{l});
end

test = TOPO(data,EpochTime,'64ch.ced',[-10 10],'div',[3 5]);

idx = 0;
time = [0.2 0.25 0.3 0.35 0.4];
for m = 1:3
    for n = 1:5
        idx = idx + 1;
        test.plot(idx,m,time(n));
    end
end
