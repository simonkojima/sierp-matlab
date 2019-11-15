function r = RiemannianDistance(cov1,cov2)

    r = sqrt(sum(log(eig(cov1,cov2)).^2));    

end