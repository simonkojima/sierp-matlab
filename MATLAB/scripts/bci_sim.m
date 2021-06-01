clearvars
close all

[~,name_folder] = fileparts(pwd);
load(name_folder);

num = 3;

ch_eeg = 1:64;

%frintf("Trig : %d, %d\n",num2str(trig_sel()))

if exist(strcat(name_folder,'_cov','.mat')) == 0
    
%%-------------------------------------------------------------------------
% generate data sets
    
    for m = 1:num
        data{m}.X = [];
        data{m}.Y = [];
        for n = 1:num
            tmp = [];
            tmp.data = epochs.att{n}.get_epoch_data(trig_sel(m),ch_eeg);
            tmp.size = size(tmp.data);
            data{m}.X = cat(3,data{m}.X,tmp.data);
            if m == n
                data{m}.Y = cat(2,data{m}.Y,ones(1,tmp.size(3)));
            else
                data{m}.Y = cat(2,data{m}.Y,zeros(1,tmp.size(3)));
            end
        end
    end

%%-------------------------------------------------------------------------
% compute cov
    for m = 1:num
        [COV{m} P1{m}] = covariances_p300(data{m}.X,data{m}.Y);
        C{m} = riemann_mean(COV{m});
    end
    save(strcat(name_folder,'_cov'),'C','COV','trig_sel')
else
    load(strcat(name_folder,'_cov'));
end

%%-------------------------------------------------------------------------
% project to manifold
for m = 1:num
    feat{m} = Tangent_space(COV{m},C{m});
end





