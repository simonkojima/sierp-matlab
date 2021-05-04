clearvars
close all


[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

dev = 1;

num = 3;

for m=1:num
    if m == dev
        type{m} = 'dev';
    else
        type{m} = 'std';
    end
    data{1}{m} = EEG(epochs.att{dev}.dev{m});
end

for m=1:num
    if m == dev
        type{m} = 'dev';
    else
        type{m} = 'std';
    end
    data{2}{m} = EEG(epochs.att{m}.dev{dev});
end

test = siTopo(data,EpochTime,'64ch.ced',[-4 4],'div',[2 4]);

idx_subplot = 1;
test.plot(1,1,1,0.25);
test.plot(2,1,5,0.25);

%test.plot(idx_data,idx_subplot,m,time);

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
