clearvars
close all
%
%   FFT Analyzer for NIDAQ Data
%   Version : 1
%   Author : Simon Kojima
%

%% Preferences

FileName = 'TDT_Sweep.mat';

HammingEnable = 0;

%% 
load(FileName);

Data = daq.data;
Time = daq.time;
Fs = daq.Fs;

fprintf('Sample Rate : %f\n',Fs);

figure();
plot(Time,Data);

player = audioplayer(Data,Fs);

fprintf('Press Any Key to Play...\n');
pause;

play(player);

fprintf('Press Any Key to Stop Playing...\n');
pause;

stop(player);