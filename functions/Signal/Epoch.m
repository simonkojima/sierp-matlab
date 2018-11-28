function EpochData = Epoch(EEGData,TriggerData,Range,SelectedTrigger,Fs)

if length(Range) ~= 2
    fprintf('Error : Range have to be a vector which has length of 2');
    return
end

if length(SelectedTrigger) ~= 1
    fprintf('Error : SelectedTrigger should have length of 2') ;
    return
end

Count = 0;
for l = 1:size(TriggerData,2)
    if TriggerData(l) == SelectedTrigger
        Count = Count + 1;
        EpochData(:,:,Count) = EEGData(:,l+floor(Range(1)*Fs):l+floor(Range(2)*Fs));
    end
end

end