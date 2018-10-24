clearvars
%
%   SweepMaker
%   Version : 1
%   Author : Simon Kojima
%

%% Preferences

Fs = 48828; %Hz
Duration = 10; %s

FileName = 'C:\Users\Simon\Documents\MATLAB\Sound\Sweep.wav';

StartFrequency = 0; %Hz
EndFrequency = 24414; %Hz

HanningEnable = 0;

%% 

t = 0:1/Fs:Duration;

Sweep = chirp(t,StartFrequency,Duration,EndFrequency);

if HanningEnable == 1
   Sweep = Sweep.*(hann(Fs*Duration./1000));
end

player = audioplayer(Sweep,Fs);
play(player);

audiowrite(FileName,Sweep,Fs);