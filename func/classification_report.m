function r = classification_report(labels,preds,varargin)

props = [];

if length(varargin) > 0
    for m=1:length(varargin)
        props.(lower(varargin{m})) = [];
    end
end

tp = 0;
tn = 0;
fp = 0;
fn = 0;

for m = 1:length(preds)
    if preds(m) == labels(m)
        if preds(m) == 1
            tp = tp+1;
        elseif preds(m) == 0
            tn = tn+1;
        end
    else
       if preds(m) == 1
            fp = fp+1;
       elseif preds(m) == 0
            fn = fn +1;
       end
    end
end

precision = tp/(tp+fp);
recall = tp/(tp+fn);

acc = (tp+tn)./(tp+tn+fp+fn);
f1 = 2*(precision*recall)./(precision+recall);
mcc = (tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));

r.acc = acc;
r.mcc = mcc;
r.f1 = f1;
r.precision = precision;
r.recall = recall;
r.tp = tp;
r.tn = tn;
r.fp = fp;
r.fn = fn;

if isfield(props,'printenable')
    %fprintf('\n');
    fprintf('  Accurecy : %.0f\n',acc);
    fprintf('  F1 Score : %.2f\n',f1);
    fprintf('       MCC : %.2f\n',mcc);
    fprintf(' Precision : %.2f\n',precision);
    fprintf('    Recall : %.2f\n',recall);
        fprintf('        TP : %.0f\n',tp);
    fprintf('        TN : %.0f\n',tn);
    fprintf('        FP : %.0f\n',fp);
    fprintf('        FN : %.0f\n',fn);
end