function car = CAR(Data)

[NumSumple,NumCh] = size(Data);
car = Data -  mean(Data,2);

end