function EpochData = Devide(EEGData,SampleNum,TimeRange,Fs)

if length(TimeRange) ~= 2
    fprintf('Error : Range have to be a vector which has length of 2');
    return
end

EpochData = EEGData(:,SampleNum+floor(TimeRange(1)*Fs):SampleNum+floor(TimeRange(2)*Fs));

end