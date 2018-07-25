function output = expF1DED(x)

global trace startpoint endpoint I flag;
% be certain function never changes any of these global variables
%%	EXPF1DED	Double Exponential Decay Fit
%		x:  		[tau1 tau2 mag1 mag2]
%  		data:		data to be fit
%		startpoint: datapoint to start fit
%		endpoint:	datapoint to end fit

%%
tau1 = x(1);
tau2 = x(2);
mag1 = x(3);
mag2 = x(4);

if (flag==0)
	delta = ceil((endpoint-startpoint)/1000);
else
	delta = 1;
end

localtrace = trace(startpoint:delta:endpoint);	% Current in pA
T = I*[0:delta:(endpoint-startpoint)]/1000;	% Time in ms
fit = mag1*exp(-T/tau1)+mag2*exp(-T/tau2);

if (flag==0 | flag==-1)	
	output = mean((localtrace-fit).^2);
else
	output = fit;
end

	