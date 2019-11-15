function Sb = covariance_p300(X,prototype)

[~,N] = size(X);

Xb = [prototype; X];
Sb = (1/(N-1))*(Xb*Xb');

end