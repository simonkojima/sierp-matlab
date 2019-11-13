function r = RiemannianDistance(cov1,cov2)
        
    val = eig(cov1,cov2);

    r = sqrt(sum(log(val).^2));    

end