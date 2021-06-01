fprintf('processing -');

for m = 1:100
    pause(0.2)
    fprintf(repmat('\b',1,1))
    switch rem(m,3)
        case 1
            fprintf('\\');
        case 2
            fprintf('/');
        otherwise
            fprintf('-');
    end
end

fprintf('\n')