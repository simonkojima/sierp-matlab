clearvars

[~,name_folder] = fileparts(pwd);
load(name_folder);

num = 1;
ch_eeg = 1:64;
ld_ratio = 0.9;

script_version = 1;
lib_linear_type_solver = 6;

trig_sel = [2 8 32];

%%-------------------------------------------------------------------------
% generate data sets
data{1}.X = [];
data{1}.Y = [];
for m = 1:3

    for n = 1:3
        tmp = []; % init
        
        tmp.data = epochs.att{n}.get_epoch_data(trig_sel(m),ch_eeg);
        data{1}.X = cat(3,data{1}.X,tmp.data);
        
        tmp.size = size(tmp.data);
        if m == n
            data{1}.Y = cat(2,data{1}.Y,ones(1,tmp.size(3)));
        else
            data{1}.Y = cat(2,data{1}.Y,zeros(1,tmp.size(3)));
        end
    end
end

%%-------------------------------------------------------------------------
% divide

if ld_ratio >= 1
    fprintf("ld_ratio must be less than 1\n") ;
    return
end

for m = 1:num
    ld{m}.X = [];
    ld{m}.Y = [];
    td{m}.X = [];
    td{m}.Y = [];
    for n = 1:length(data{m}.Y)
        if randi([1 100],1,1) <= ld_ratio*100
            ld{m}.X(:,:,length(ld{m}.Y)+1) = data{m}.X(:,:,n);
            ld{m}.Y(length(ld{m}.Y)+1) = data{m}.Y(n);
        else
            td{m}.X(:,:,length(td{m}.Y)+1) = data{m}.X(:,:,n);
            td{m}.Y(length(td{m}.Y)+1) = data{m}.Y(n);
        end
    end
end

for m=1:num
    actual_ld_ratio(m) = length(ld{m}.Y)/(length(ld{m}.Y)+length(td{m}.Y));
end
actual_ld_ratio

%%-------------------------------------------------------------------------
% compute cov
t_start = tic; % start time count

for m = 1:num
    [ld{m}.COV,ld{m}.P1] = covariances_p300(ld{m}.X,ld{m}.Y);
    ld{m}.C = riemann_mean(ld{m}.COV);
    
    td{m}.COV = covariances_p300(td{m}.X,ld{m}.P1);
    %td{m}.C = riemann_mean(td{m}.COV);
end

%%-------------------------------------------------------------------------
% project to manifold
for m = 1:num
    ld{m}.vec = Tangent_space(ld{m}.COV,ld{m}.C);
    td{m}.vec = Tangent_space(td{m}.COV,ld{m}.C);
    ld{m}.vec = ld{m}.vec';
    td{m}.vec = td{m}.vec';
end

%%-------------------------------------------------------------------------
% logistic reguression
for m = 1:num
    ld{m}.Y = ld{m}.Y(:);
    td{m}.Y = td{m}.Y(:);
    mdl(m) = train(ld{m}.Y,sparse(ld{m}.vec),strcat("-s ",num2str(lib_linear_type_solver)));
    labels{m} = predict(zeros(size(td{m}.vec,1),1),sparse(td{m}.vec),mdl(m));
end

for m = 1:num
   labels{m} = labels{m}(:);
   td{m}.Y = td{m}.Y(:);
   [mcc(m),f1(m),acc(m),tp(m),tn(m),fp(m),fn(m)] = ClassifierEvaluation(labels{m},td{m}.Y,1);
end
t_end = toc(t_start);

fprintf('time : %dm%ds\n',floor(t_end/60),floor(rem(t_end,60)));

return
%%-------------------------------------------------------------------------
% save log

fprintf(file,'\n---------------------------------------------\n');
fprintf(file,strcat(string(datetime('now','format','y/M/d HH:mm:ss')),'\n'));
fprintf(file,'ld_ratio          : %.1f\n',ld_ratio);
fprintf(file,'lib-linear solver : %d\n',lib_linear_type_solver);
fprintf(file,'time              : %dm%ds\n',floor(t_end/60),floor(rem(t_end,60)));
fprintf(file,'script version    : %.1f\n',script_version);

for m = 1:num
    fprintf(file,'\n');
    fprintf(file,'class %d\n',m);
    fprintf(file,'learning data     : %d\n',length(ld{m}.Y));
    fprintf(file,'test data         : %d\n',length(td{m}.Y));
    fprintf(file,'actual_ld_ratio   : %.3f\n',actual_ld_ratio(m));
    fprintf(file,'True Positive     : %.0f\n',tp(m));
    fprintf(file,'True Negative     : %.0f\n',tn(m));
    fprintf(file,'False Positive    : %.0f\n',fp(m));
    fprintf(file,'False Negative    : %.0f\n',fn(m));
    fprintf(file,'Accurecy          : %.0f%%\n',acc(m)*100);
    fprintf(file,'F1 Score          : %.2f\n',f1(m));
    fprintf(file,'MCC               : %.2f\n',mcc(m));
end
fclose(file);

if exist(strcat(name_folder,'_log',file_suffix,'.mat')) == 0
    log_mat = [];
    log_mat.mcc = mcc;
    log_mat.acc = acc;
    log_mat.f1 = f1;
    log_mat.tp = tp;
    log_mat.tn = tn;
    log_mat.fp = fp;
    log_mat.fn = fn;
    log_mat.t_end = t_end;
    log_mat.actual_ld_ratio = actual_ld_ratio;
else
    load(strcat(name_folder,'_log',file_suffix,'.mat'));
    for m = 1:num
        log_mat.mcc = cat(1,log_mat.mcc,mcc);
        log_mat.acc = cat(1,log_mat.acc,acc);
        log_mat.f1 = cat(1,log_mat.f1,f1);
        log_mat.tp = cat(1,log_mat.tp,tp);
        log_mat.tn = cat(1,log_mat.tn,tn);
        log_mat.fp = cat(1,log_mat.fp,fp);
        log_mat.fn = cat(1,log_mat.fn,fn);
        log_mat.actual_ld_ratio = cat(1,log_mat.actual_ld_ratio,actual_ld_ratio);
    end
    log_mat.t_end = cat(1,log_mat.t_end,t_end);
end

save(strcat(name_folder,'_log',file_suffix,'.mat'),'log_mat');