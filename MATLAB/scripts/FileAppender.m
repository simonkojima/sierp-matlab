clearvars

Files = [5 8];
PreFileName = '20181022_B35_000';
FilterRange = [0.1 40];
FilterOrder = 2;
NumChannel = 64;

SaveFileName = '20181022_B35_Appended.mat';

Temp.Data = [];
Temp.Trigger = [];
for l=Files(1):Files(2)
    FileName = sprintf(strcat(PreFileName,'%d.mat'),l);
    load(FileName);
    [B, A] = butter(FilterOrder, FilterRange/(Fs/2), 'bandpass');
    EOGData = Data(NumChannel+1:NumChannel+2,:);
    Data = Data(1:NumChannel,:);
    Data = filtfilt(B, A, Data')';
    Temp.Data = [Temp.Data Data];
    Temp.Trigger = [Temp.Trigger Trigger];
end

Data = Temp.Data;
Trigger = Temp.Trigger;

save(SaveFileName,'Data','Trigger','EOGData','Time');

clearvars
fprintf('Completed !!\n');