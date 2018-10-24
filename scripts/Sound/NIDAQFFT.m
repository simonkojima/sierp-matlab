clearvars
close all
%
%   FFT Analyzer for NIDAQ Data
%   Version : 1
%   Author : Simon Kojima
%

%% Preferences

FileName = 'C:\Users\Simon\Documents\MATLAB\Sound\TDT_Sweep.mat';

HammingEnable = 0;

%% 
load(FileName);

Data = daq.data;
Time = daq.time;
Fs = daq.Fs;

fprintf('Sample Rate : %f\n',Fs);

figure();
plot(Time,Data);

if HammingEnable == 1
   Data = Data.*hamming(length(Data));
end

Spectrum = fft(Data);
Spectrum = abs(Spectrum./length(Data));
Spectrum = Spectrum(1:length(Data)/2+1);

Freq = Fs*(0:(length(Data)/2))./length(Data);

figure();
plot(Freq,Spectrum);
xlabel('f (Hz)')
xticks(0:1000:24000)
xticklabels({'0','1k','2k','3k','4k','5k','6k','7k','8k','9k','10k','11k','12k','13k','14k','15k','16k','17k','18k','19k','20k','21k','22k','23k','24k'})
set(gca,'fontsize',15)