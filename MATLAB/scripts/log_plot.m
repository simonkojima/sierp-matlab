clearvars
close all

for m = 1:9
    
    load(strcat('20181206_B33_Stream_log_',num2str(m),'.mat'))
    
    t_end(m,:) = mean(log_mat.t_end);
    mcc(m,:) = mean(log_mat.mcc,1);
    acc(m,:) = mean(log_mat.acc,1);
    
    
%     fprintf('ratio    : %.2f %.2f %.2f\n',mean(log_mat.actual_ld_ratio,1));
%     fprintf('mean mcc : %.2f %.2f %.2f\n',mean(log_mat.mcc,1));
%     fprintf('mean acc : %.2f %.2f %.2f\n',mean(log_mat.acc,1));
%     fprintf('mean time: %dm%ds\n',floor(t_end/60),floor(rem(t_end,60)));
    
end

m = 0.1:0.1:0.9;

figure('name','time')
plot(m,t_end);
figure('name','mcc')
plot(m,mean(mcc,2))
figure('name','acc')
plot(m,mean(acc,2))