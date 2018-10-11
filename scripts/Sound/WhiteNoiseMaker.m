clearvars
%
%   WhiteNoiseMaker
%   Version : 1
%   Author : Simon Kojima
%

%% Preferences

Fs = 44100; %Hz
Duration = 5; %s

FileName = 'WhiteNoise.wav';

HanningEnable = 0;

%% 

WhiteNoise = wgn(Fs*Duration,1,0);

if HanningEnable == 1
   WhiteNoise = WhiteNoise.*(hann(Fs*Duration./1000));
end

player = audioplayer(WhiteNoise,Fs);
play(player);

audiowrite(FileName,WhiteNoise,Fs);