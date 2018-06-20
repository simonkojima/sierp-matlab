function ClassifierEvaluation(PredictedLabel,ActualLabel)

FalsePos = 0;
FalseNeg = 0;
TruePos = 0;
TrueNeg = 0;

for i=1:size(PredictedLabel)
    if PredictedLabel(i) == ActualLabel(i)
        if PredictedLabel(i) == 1
            TruePos = TruePos+1;
        elseif PredictedLabel(i) == 0
            TrueNeg = TrueNeg+1;
        end
    else
       if PredictedLabel(i) == 1
            FalsePos = FalsePos+1;
       elseif PredictedLabel(i) == 0
            FalseNeg = FalseNeg +1;
       end
    end
end

fprintf('True Positive : %.0f\n',TruePos);
fprintf('True Negative : %.0f\n',TrueNeg);
fprintf('False Positive : %.0f\n',FalsePos);
fprintf('False Negative : %.0f\n',FalseNeg);
fprintf('Precision : %.2f%%\n',TruePos/(TruePos+FalsePos)*100);
fprintf('Recall : %.2f%%\n',TruePos/(TruePos+FalseNeg)*100);
fprintf('\nAccurecy : %.2f%%\n',(TruePos+TrueNeg)/(TruePos+TrueNeg+FalsePos+FalseNeg)*100);