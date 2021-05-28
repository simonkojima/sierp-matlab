clearvars
%% ---------------------------------------------------------------
%Stream Epoch Exporter
%Author : Simon Kojima

%%-------------------------------------------------------------------------

file_idx{1} = [1 3];
file_idx{2} = [2 4];

trig_sel = [3 4];

range = [-0.1 0.5];
range_baseline = [-0.05 0];

filter = [1 40];
filter_order = 2;

ch_eeg = 1:64;
ch_eog = 65:66;

th_eeg = [-200 200];       %min max (uV uV)
th_eog = [-500 500];       %min max (uV uV)

sig = [];
for rep=1:size(file_idx,2)
    
    [~,name_folder] = fileparts(pwd);
    for idx = 1:length(file_idx{rep})
        FileNumberString = num2str(file_idx{rep}(idx));
        for m = 1:4-strlength(num2str(file_idx{rep}(idx)))
            FileNumberString = strcat(num2str(0),FileNumberString);
        end
        strcat(name_folder,'_',FileNumberString,'.mat')
        load(strcat(name_folder,'_',FileNumberString,'.mat'));
        sig{rep} = siSig();
        sig{rep}.append_data(eeg);
    end
    
    sig{rep}.filter(filter(1),filter(2),filter_order);
    for m = 1:length(trig_sel)
        sig{rep}.epoch(trig_sel(m),range);
        sig{rep}.baseline(trig_sel(m),range_baseline);
        sig{rep}.rej_th(trig_sel(m),ch_eeg,th_eeg(1),th_eeg(2));
        sig{rep}.rej_th(trig_sel(m),ch_eog,th_eog(1),th_eog(2));
    end
    sig{rep}.del_raw_eeg();
    epochs.att{rep} = sig{rep};
end
save(name_folder,'epochs','trig_sel');