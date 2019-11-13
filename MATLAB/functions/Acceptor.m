function Result = Acceptor(EpochData,Threshold)

temp = squeeze(EpochData);

Result = 1;

if min(temp(:)) < Threshold(1) || max(temp(:)) > Threshold(2)
    %max(tmp(:))>Vth(1) || min(tmp(:))<Vth(2)
%     min(temp(:))
%     max(temp(:))
    Result = 0;
else
    
end