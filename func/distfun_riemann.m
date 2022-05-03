function D2 = distfun_riemann(ZI,ZJ)

    N = sqrt(length(ZI));
    
    ZI_COV = reshape(ZI,[N,N]);
    
    ZJ_COV = [];
    for m = 1:size(ZJ,1)
        ZJ_COV(:,:,m) = reshape(ZJ(m,:),[N,N]);
        D2(m) = distance_riemann(ZI_COV,ZJ_COV(:,:,m));
    end
    
    D2 = D2(:); 

end