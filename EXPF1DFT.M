function output = expF1DFT(x)

global trace startpoint endpoint I flag fixedparameters;

try
    tau1 = fixedparameters(1);
    tau2 = fixedparameters(2);
catch
    return
end

% be certain function never changes any of these global variables
%%
%	EXPF1DFT	Produces simultaneous bi-exponential constrained fits
%
%		x:  			[mag1 mag2]
%  		data:			data to be fit
%		startpoint: 	datapoint to start fit
%		endpoint:		datapoint to end fit

global fit;

mag1 = x(1);
mag2 = x(2);

if (flag==0)
	delta = ceil((endpoint-startpoint)/1000);
else
	delta = 1;
end

% trace = current in pA, T = time in ms

T = I*[0:delta:(endpoint-startpoint)]/1000;
fit = mag1*exp(-T/tau1)+mag2*exp(-T/tau2);
localtrace=trace(startpoint:delta:endpoint);

if (flag==0 | flag==-1)
	
	output = mean((localtrace-fit).^2);
else
	output = fit;
end
