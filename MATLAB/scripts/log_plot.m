clearvars
close all

name = '20190508_B46_Stream';

for m = 1:9
    
    load(strcat(name,'_log_',num2str(m),'.mat'))
    
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
plot(m,t_end,'linewidth',2);
set(gca,'fontsize',18)
xlim([0.1 0.9]);
xlabel('pl')
ylabel('time (s)')

figure('name','mcc')
plot(m,mean(mcc,2),'linewidth',2)
set(gca,'fontsize',18)
ylim([0 1]);
xlim([0.1 0.9]);
xlabel('pl')
ylabel('mcc')

figure('name','acc')
plot(m,mean(acc,2),'linewidth',2)
set(gca,'fontsize',18)
ylim([0 1]);
xlim([0.1 0.9]);
xlabel('pl')
ylabel('acc')