function output = EXPwholePulse(x)

global trace startpoint endpoint I flag;
%%
%	EXPwholePulse	Fits activation and inactivation of pulse
%
%		x:              [magtot hill_exp tau0 tau1 tau2 Ffast];
%  		data:			data to be fit
%		startpoint: 	datapoint to start fit
%		endpoint:		datapoint to end fit
%
%%
magtot = x(1);
hill = x(2);
tau0 = x(3);
tau1 = x(4);
tau2 = x(5);
Ffast = x(6);

if (flag==0)
	delta = ceil((endpoint-startpoint)/1000);
else
	delta = 1;
end

% trace = current in pA, T = time in ms

T = I*[0:delta:(endpoint-startpoint)]/1000;


fit = magtot * ((1 - exp(-T/tau0)).^hill) .* (Ffast * exp(-T/tau1) + (1 - Ffast) * exp(-T/tau2));
localtrace=trace(startpoint:delta:endpoint);

if (flag==0 | flag==-1)
	
	output = mean((localtrace-fit).^2);
else
	output = fit;
end
