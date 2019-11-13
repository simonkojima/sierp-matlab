function Sb = covariance(X,prototype)

[~,N] = size(X);

Xb = [prototype; X];
Sb = (1/(N-1))*(Xb*Xb');

end