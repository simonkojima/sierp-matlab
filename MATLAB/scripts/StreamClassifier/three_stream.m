clearvars
%% ---------------------------------------------------------------
%Stream Epoch Exporter
%Author : Simon Kojima

%%-------------------------------------------------------------------------

file_idx{1} = [1 4];
file_idx{2} = [2 5];
file_idx{3} = [3 6];


for rep=1:size(file_idx,2)
    
    trig_sel = [2 8 32];
    
    range = [-0.1 0.5];
    range_baseline = [-0.05 0];
    
    filter = [1 40];
    filter_order = 2;
    
    ch_eeg = 1:64;
    ch_eog = 65:66;
    
    th_eeg = [-100 100];       %min max (uV uV)
    th_eog = [-500 500];       %min max (uV uV)
    
    [~,name_folder] = fileparts(pwd);
    for idx = 1:length(file_idx{rep})
        FileNumberString = num2str(idx);
        for m = 1:4-strlength(num2str(idx))
            FileNumberString = strcat(num2str(0),FileNumberString);
        end
        load(strcat(name_folder,'_',FileNumberString,'.mat'));
        sig = siSig();
        sig.append_data(eeg);
    end
    
    sig.filter(filter(1),filter(2),filter_order);
    for m = 1:length(trig_sel)
        sig.epoch(trig_sel(m),range);
        sig.baseline(trig_sel(m),range_baseline);
        sig.rej_th(trig_sel(m),ch_eeg,th_eeg(1),th_eeg(2));
        sig.rej_th(trig_sel(m),ch_eog,th_eog(1),th_eog(2));
    end
    sig.del_raw_eeg();
    epochs.att{rep} = sig;
end
save(name_folder,'epochs');