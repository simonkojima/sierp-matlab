clearvars

[y,Fs] = audioread('Piano_48828.wav');

fprintf('Sample Rate : %f\n',Fs);

player = audioplayer(y,48828.125);

play(player);

return

fprintf('Press Any Key to Stop Playing...\n');
pause;

stop(player);