clearvars
close all

[path,folder] = fileparts(pwd);

bandpass = FILTER('bandpass');
bandpass.setCutoff([1 40]);
bandpass.setOrder(2);

downsample = FILTER('downsample');
downsample.setRate(2);

Data.eeg = DATA();
Data.eog = DATA();

Data.eeg.setName("EEG");
Data.eog.setName("EOG");


for l= [1 4]
    temp.eeg = DATA();
    temp.eeg.setPath(strcat(path,'/',folder));
    temp.eeg.loadMat(strcat(folder,"_000",num2str(l),".mat"));
    
    temp.eog = DATA();
    temp.eog.setPath(strcat(path,'/',folder));
    temp.eog.loadMat(strcat(folder,"_000",num2str(l),".mat"));

    temp.eeg.setCh(1:64);
    temp.eog.setCh(65:66);

    bandpass.apply(temp.eeg);
    downsample.apply(temp.eeg);
    Data.eeg.concatenate(temp.eeg);
    Data.eog.concatenate(temp.eog);
end

Epoch = EPOCH(Data.eeg);
Epoch.setEOGData(Data.eog);
Epoch.setRange([-0.1 0.5]);
Epoch.setTrigger([1,2],{'non-target','target'});
Epoch.start();

Epoch.setBaseLineRange([-0.05 0]);
Epoch.fixBaseLine();


Epoch.setTh('EEG',[-100 100]);
Epoch.setTh('EOG',[-Inf Inf],Data.eog);

Epoch.applyTh();

Epoch.averaging();

plot(Epoch.getTime(),Epoch.getAveraged{Epoch.getTrigIndex('target')}(Epoch.getChIndex('Cz'),:),'r');
hold on
plot(Epoch.getTime(),Epoch.getAveraged{Epoch.getTrigIndex('non-target')}(Epoch.getChIndex('Cz'),:),'b');
axis ij
hold off