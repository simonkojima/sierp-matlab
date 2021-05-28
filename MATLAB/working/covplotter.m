clearvars
close all

[~,name_folder] = fileparts(pwd);
load(name_folder);

num = 2;

ch_eeg = 1:64;

%frintf("Trig : %d, %d\n",num2str(trig_sel()))

if exist(strcat(name_folder,'_cov','.mat')) == 0
    
%%-------------------------------------------------------------------------
% generate data sets
    
    for m = 1:num
        data{m}.X = [];
        data{m}.Y = [];
        for n = 1:2
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
        C{m}.t = riemann_mean(COV{m}(:,:,data{m}.Y==1));
        C{m}.nt = riemann_mean(COV{m}(:,:,data{m}.Y==0));
        fprintf("%d : completed\n",m);
    end
    trig = trig_sel;
    save(strcat(name_folder,'_cov'),'C','trig')
else
    load(strcat(name_folder,'_cov'));
end

fontsize = 20;

for m = 1:num
    C_px{m}.t = C{m}.t(ch_eeg,1:end);
    C_px{m}.nt = C{m}.nt(ch_eeg,1:end);
    figure('Name',strcat('Data',num2str(m)),'NumberTitle','off');
    subplot(2,2,1);
    %image(C_px{m}.t,'CDataMapping','scaled')
    %image(10*C_px{m}.t./max(max(C_px{m}.t)),'CDataMapping','scaled')
    %imagesc(C_px{m}.t,[min(min(C_px{m}.t)) max(max(C_px{m}.t))]);
    imagesc(C{m}.t,[min(min(C{m}.t)) max(max(C{m}.t))]);
    title('attended')
    set(gca,'FontSize',fontsize)
    colorbar
    subplot(2,2,2);
    %image(C_px{m}.nt,'CDataMapping','scaled')
    %image(10*C_px{m}.nt./max(max(C_px{m}.nt)),'CDataMapping','scaled')
    %imagesc(C_px{m}.nt,[min(min(C_px{m}.t)) max(max(C_px{m}.t))]);
    imagesc(C{m}.nt,[min(min(C{m}.t)) max(max(C{m}.t))]);
    title('non-attended')
    set(gca,'FontSize',fontsize)
    colorbar
    subplot(2,2,3);
    %image(C_px{m}.nt,'CDataMapping','scaled')
    %image(10*C_px{m}.nt./max(max(C_px{m}.nt)),'CDataMapping','scaled')
    %imagesc(C_px{m}.nt,[min(min(C_px{m}.t)) max(max(C_px{m}.t))]);
    imagesc(C{m}.t,[min(min(C_px{m}.t)) max(max(C_px{m}.t))]);
    title('attended (scaled)')
    set(gca,'FontSize',fontsize)
    colorbar
    subplot(2,2,4);
    imagesc(C{m}.nt,[min(min(C_px{m}.t)) max(max(C_px{m}.t))]);
    title('non-attended (scaled)')
    set(gca,'FontSize',fontsize)
    colorbar
end

