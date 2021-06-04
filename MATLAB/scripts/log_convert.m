clearvars

load('20181206_B33_Stream_log_9.mat')

% mcc = [];
% acc = [];
% for m = 1:3
%    mcc = cat(2,mcc,log_mat.mcc{m});
%    acc = cat(2,acc,log_mat.acc{m});
% end
t_end = mean(log_mat.t_end);

clc

fprintf('ratio    : %.2f %.2f %.2f\n',mean(log_mat.actual_ld_ratio,1));
fprintf('mean mcc : %.2f %.2f %.2f\n',mean(log_mat.mcc,1));
fprintf('mean acc : %.2f %.2f %.2f\n',mean(log_mat.acc,1));
fprintf('mean time: %dm%ds\n',floor(t_end/60),floor(rem(t_end,60)));