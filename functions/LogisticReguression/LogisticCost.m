function [J Grad] = LogisticCost(X,Y,Theta,Lambda)
%
%   Compute Cost Function of Logistic Reguression
%   Version : alpha 5
%   Author : Simon Kojima
%

[m,n]= size(X);

Hx = logsig(X*Theta);
J = (-Y.*log(Hx) - (1-Y).*(log(1-Hx)));
J = sum(J)./m;
JReg = (Theta'*Theta).*Lambda./(2*m);
J = J + JReg;

Grad = sum((Hx-Y).*X)./m;
GradReg = (Theta.*Lambda./m)';
Grad = Grad + GradReg;