clearvars

eeg_(1) = siSig("stream_0001");
eeg_(2) = siSig("stream_0002");

eeg = siSig(eeg_);

fs = eeg.props.fs;
[B,A] = butter(2,[1,40]/(fs/2));

eeg.filtfilt(B,A);

range = [-0.1 0.5];
baseline = [-0.05 0];
th = [-100 100];
ch = 1:64;

ep.dev1 = siEpoch(eeg,1,range,baseline);
ep.dev1.rej_th(ch,th);

ep.dev3 = siEpoch(eeg,3,range,baseline);
ep.dev3.rej_th(ch,th);

plt = siPlot([1 1]);
id(1) = plt.plot(1,ep.dev1.data(32,:,:),ep.dev3.time,'color','b');
id(2) = plt.plot(1,ep.dev3.data(32,:,:),ep.dev3.time,'color','r');
plt.ttest(1,id(1),id(2),0.01)
plt.ttest(1,id(1),id(2),0.05,'mode','line')
