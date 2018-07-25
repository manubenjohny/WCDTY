V = [ -100 -100 -10 -100 ];    % mV
Vstart = [-100 -100 -100 10];
Vstop = [-100 -100 0 -100];
Vdelta = [0 0 10 -20];
cycles = 20;

Vfamily = Vstart;

for i = 1:cycles,
   Vfamily = (Vstop >= Vstart).*((Vfamily < Vstop).*(Vfamily + abs(Vdelta)) + ...
                                (Vfamily >= Vstop).*(Vstart)) + ...
              (Vstop < Vstart).*((Vfamily > Vstop).*(Vfamily - abs(Vdelta)) + ...
                                (Vfamily <= Vstop).*(Vstart))
end

D = [ 10 50 20 10 ];
Dstart = 
Dstop = 
Ddelta = 

Dfamily = 

D = abs(D);




% ---

time=[1:TimeStep:StimLength];

start = 0;
for i = 1:length(V)
   Pulse = Pulse + MakePulse(time, start, start+D(i), V(i));
end

