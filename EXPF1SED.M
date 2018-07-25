function output = expF1SED(x)
%function output = expF1SED(x, trace, startpoint, endpoint, I, flag)

global trace startpoint endpoint I flag;


%	EXPF1SED.M	Single Exponential Decay Fit to Data
%	x:  		[tau1 mag1]
%  	data:		data to be fit
%	startpoint: datapoint to start fit
%	endpoint:	datapoint to end fit
%   flag:  0 = output is mean squared error of fit to data 
%          1 = output is fit function itself

tau1 = x(1);
mag1 = x(2);

if (flag==0)
	delta = ceil((endpoint-startpoint)/1000);
else
	delta = 1;
end

localtrace = trace(startpoint:delta:endpoint);	% Current in pA
T = I*[0:delta:(endpoint-startpoint)]/1000;	% Time in ms
    
fit = mag1*exp(-T/tau1);

if (flag==0 | flag==-1)	
	output = mean((localtrace-fit).^2);
else
	output = fit;
end

	