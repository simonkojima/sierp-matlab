function G = kernel(U,V)

sigma = 2;

% U = U(:);
% V = V(:);

[m n] = size(U);

% size(U)%3x3
% size(V)%1x3

for i=1:m
    G(i,:) = -norm(U(i,:)-V)^2;
end

G = G/(2*(sigma^2));
G = exp(G);


%return
% 
% G = -norm(U-V)^2;
% G = G/(2*(sigma^2));
% G = exp(G);
% 
