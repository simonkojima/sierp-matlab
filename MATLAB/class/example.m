clearvars
close all

fs = 1000;

[B,A] = butter(2,[1 40]/(fs/2),'bandpass');
fname = '20210701_B47_oddball_devs_';

for m = 1:2
	idx = num2str(m,"%04d");
	si(m) = siSig(strcat(fname,idx));
	%si(m).filtfilt(A,B);
end

wh = siSig(si);
wh.filtfilt(A,B);

[~,list] = wh.get_trig_list();
disp(list);

range = [-0.1 0.5];
baseline = [-0.05 0];

trig = [1 2 11];

ch_eeg = 1:64;
th_eeg = [-100 100];
ch_eog = 65:66;
th_eog = [-300 300];


for m = 1:length(trig)
	ep(m) = siEpoch(wh,trig(m),range,baseline);
	ep(m).rej_th(ch_eeg,th_eeg);
	ep(m).rej_th(ch_eog,th_eog);
end

plt = siPlot([2 1],'axis','ij');

id_1(1) = plt.plot(1,ep(1).data(32,:,:),ep(1).time);
id_2(1) = plt.plot(1,ep(2).data(32,:,:),ep(1).time);
plt.ttest(1,id_1,id_2,0.01,'mode','line','facecolor','r');

id_1(1) = plt.plot(2,ep(1).data(32,:,:),ep(1).time,'color','b','linewidth',1.5);
id_2(1) = plt.plot(2,ep(3).data(32,:,:),ep(1).time,'color','r','linewidth',1.5);
plt.ttest(2,id_1,id_2,0.01);

for m = 1:2
	plt.axis_x(m);
	plt.axis_y(m);
end


%ids_1(1) = plt.plot(1,ep.data(10,:,:),ep.time,'color','r','linewidth',1.5);
%ids_1(2) = plt.plot(1,ep.data(1,:,:),ep.time,'color','r','linewidth',1.5);

%ids_2(1) = plt.plot(1,ep.data(32,:,:),ep.time,'color','b','linewidth',1.5);
%ids_2(2) = plt.plot(1,ep.data(63,:,:),ep.time,'color','b','linewidth',1.5);
%plt.axis_x(1);
%plt.axis_y(1);

%plt.ttest(1,ids_1,ids_2,0.01,'mode','line');
%plt.ttest(1,ids_1,ids_2,0.05,'mode','line');
%plt.ttest(1,ids_1,ids_2,0.1,'mode','mesh');

return
load('ch_conf_64ch');

plt_2 = siPlot(ch_conf.div,'axis','ij');
for m = 1:64
	plt_2.plot(ch_conf.locs(m),ep.data(m,:,:),ep.time);
end
