function time = sec2time(sec)

% Given the time in seconds, this returns a string formatted as HH:MM:SS

hr = floor(sec/3600);
min = floor(rem(sec,3600)/60);
seconds = rem(sec,60);
time = [];

if hr<10, time = '0'; end
time = [time num2str(hr) ':'];
if min<10, time = [time '0']; end
time = [time num2str(min) ':'];% end
if seconds<10, time = [time '0']; end
time = [time num2str(seconds)];



% time = [num2str(hr) ':' num2str(min) ':' num2str(seconds)];

