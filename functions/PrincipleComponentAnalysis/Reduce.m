function Reduced = Reduce(X,U,k)

if fix(sum(mean(X,1),2)) ~= 0
    fprintf('Error in Function "Reduce" : mean value invailed\n');
    Reduced = 0;
    return
end

Reduced = X*U(:,1:k);

end