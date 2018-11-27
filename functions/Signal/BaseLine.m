function BaseLineData = BaseLine(BaseLineEpochData,Range,Fs)
    BaseLineData = repmat(mean(BaseLineEpochData,2),1,(Range(2)-Range(1))*Fs+1);
end
