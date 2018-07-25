function output = expF1SAR(x)
global trace startpoint endpoint I flag fixedparameters;


%%	
% EXPF1SAR.M	Single Exponential Activation Rate
%		
%
%		x:  		[tau1 mag1]
%  		data:		data to be fit
%		startpoint: datapoint to start fit
%		endpoint:	datapoint to end fit

tau1 = x(1);
mag1 = x(2);
hill = fixedparameters(1);

localtrace = trace(startpoint:endpoint);	% Current in pA
T = I*[0:(endpoint-startpoint)]/1000;	% Time in ms

fit = mag1*(1-exp(-T/tau1)).^hill;

if (flag==0 | flag==-1)	
	output = mean((localtrace-fit).^2);
else
	output = fit;
end

	