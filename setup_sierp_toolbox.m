dir= fileparts(which(mfilename));
liblinear = fullfile(dir,"/libs/liblinear/matlab");
run(fullfile(liblinear,"make.m"))
addpath(genpath(dir));
rmpath(genpath(fullfile(dir, '.git')));
