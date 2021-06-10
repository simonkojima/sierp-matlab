NOCLEAR = 1;

loop_time = 10;

for ld_ratio = 0.1:0.1:0.9
    for m = 1:loop_time
        bci_sim
    end
end