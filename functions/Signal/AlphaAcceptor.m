function Result = AlphaAcceptor(EpochData,AlphaThreshold,FrequencyRange,Fs)

temp = squeeze(EpochData);

AllRangeBandPower = bandpower(mean(temp,1)',Fs,FrequencyRange);
AlphaRangeBandPower = bandpower(mean(temp,1)',Fs,[8 13]);
PerPower = 100*(AlphaRangeBandPower/AllRangeBandPower);

Result = 1;

if PerPower > AlphaThreshold
    Result = 0;
end
    
end