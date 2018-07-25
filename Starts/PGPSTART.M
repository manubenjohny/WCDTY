% PGPSTART.M	Stuff that PGP likes to have set up on start

x=0;

disp(' 1) APW:    Arbitrary Potential Waveforms');
disp(' 2) WC:     Whole-Cell Analysis Program');
disp(' 3) SIM:    Simulation Program');
disp(' 4) HISIM:  Hidden Inactivation Simulation Program');
disp(' 5) DTYSIM:  DTY Simulation Program');
disp(' ');


while (x<1|x>5)
	x = input ('Enter program to run: ');
end

if (x==1)
	path(path,'c:\matlab\apw');
end

if (x==2)
	path(path,'c:\matlab\wc');
	path(path,'c:\matlab\wc\utils');
	path(path,'c:\matlab\wc\multifit');	
end

if (x==3)
	path(path,'c:\matlab\simwc');
	path(path,'c:\matlab\simsc');
end

if (x==4)
	path(path,'c:\matlab\hisim');
end

if (x==5)
	path(path,'c:\matlab\dtysim');
end
