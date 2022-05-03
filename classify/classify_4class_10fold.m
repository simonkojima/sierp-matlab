%clearvars

file = 1:4;
sig = siSig.empty;
%[~,folder] = fileparts(pwd);
for m = 1:length(file)
    %sig(m) = siSig(strcat("20210907_B49_online_",num2str(file(m),"%04d")));
    sig(m) = siSig(strcat(folder,"_",num2str(file(m),"%04d")));
end

ch_eeg = 1:64;
th_eeg = [-100 100];
ch_eog = 65:66;
th_eog = [-500 500];

lib_linear_type_solver = 0;
n_components = 2;

trig = [3 4 5 6];

fs = sig(1).props.fs;
[B,A] = butter(2,[1 40]/(fs/2),'bandpass');

for m = 1:4
    sig(m).filtfilt(B,A);
end

range = [0 1];
baseline = [0 0.05];

class = 1;
k = 10;

%-------------------------------------------------------------------------
% generate data sets

for m = 1:length(file)
    for n = 1:length(trig)
        ep{m}(n) = siEpoch(sig(m),trig(n),range,baseline);
        ep{m}(n).rej_th(ch_eeg,th_eeg);
        ep{m}(n).rej_th(ch_eog,th_eog);
    end
end

for class = 1:4
    
    t.ep = [];
    t.stream = [];
    nt.ep = [];
    nt.stream = [];
    
    for m = 1:length(file)
        if m == class
            t.ep = cat(3,t.ep,ep{m}(class).data);
            t.stream = cat(1,t.stream,repmat(m,size(ep{m}(class).data,3),1)); % stream num subject attended to
        else
            nt.ep = cat(3,nt.ep,ep{m}(class).data);
            nt.stream = cat(1,nt.stream,repmat(m,size(ep{m}(class).data,3),1)); % stream num subject attended to
        end
    end
    
    t.label = ones(size(t.stream));
    nt.label = zeros(size(nt.stream));
    
    X.ep = cat(3,t.ep,nt.ep);
    X.stream = cat(1,t.stream,nt.stream);
    
    Y = cat(1,t.label,nt.label);
    
    labels.actual = Y;
    labels.predict = zeros(length(Y),1);
    
    %--------------------------------------------------------------------------
    % generate classifier
    
    c = cvpartition(Y,'KFold',k); % k-fold cross validation
    
    for m = 1:k
        idx.train = training(c,m);
        idx.test = test(c,m);

        ld.X = X.ep(:,:,idx.train);
        ld.Y = Y(idx.train);
        
        td.X = X.ep(:,:,idx.test);
        %td.Y = Y(idx.test);
        
        %%-------------------------------------------------------------------------
        % compute cov
        [filters, P] = Xdawn(n_components,ld.X,ld.Y);
        ld.COV = covariances_Xdawn(ld.X,filters,P);
        td.COV = covariances_Xdawn(td.X,filters,P);
        
        %%-------------------------------------------------------------------------
        % project to manifold
        ld.C = riemann_mean(ld.COV);
        ld.vec = Tangent_space(ld.COV,ld.C);
        td.vec = Tangent_space(td.COV,ld.C);
        ld.vec = ld.vec';
        td.vec = td.vec';
        
        %%-------------------------------------------------------------------------
        % logistic reguression
        ld.Y = ld.Y(:);
        mdl = train(ld.Y,sparse(ld.vec),strcat("-s ",num2str(lib_linear_type_solver)));
        y = predict(zeros(size(td.vec,1),1),sparse(td.vec),mdl);
        
        labels.predict(idx.test) = y;

    end
    
    result(class) = classification_report(labels.actual,labels.predict);
    
%     fprintf('\n');
%     fprintf(' True Positive : %.0f\n',mean(tp));
%     fprintf(' True Negative : %.0f\n',mean(tn));
%     fprintf('False Positive : %.0f\n',mean(fp));
%     fprintf('False Negative : %.0f\n',mean(fn));
%     fprintf('      Accurecy : %.0f%%\n',mean(acc)*100);
%     fprintf('      F1 Score : %.2f\n',mean(f1));
%     fprintf('           MCC : %.2f\n',mean(mcc));
    
end