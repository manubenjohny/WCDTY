function output = expF1SEO(x)
%function output = expF1SEO(x, trace, startpoint, endpoint, I, flag)

global trace startpoint endpoint I flag;
% be certain function never changes any of these global variables

%	EXPF1SEO	Single Exponential Fit with Offset
%		x:  		[tau1 mag1 offset]
%  		trace:		data to be fit
%		startpoint: datapoint to start fit
%		endpoint:	datapoint to end fit


tau1 = x(1);
mag1 = x(2);
offset = x(3);

if (flag==0)
	delta = ceil((endpoint-startpoint)/1000);
else
	delta = 1;
end

localtrace = trace(startpoint:delta:endpoint);	% Current in pA
T = I*[0:delta:(endpoint-startpoint)]/1000;	% Time in ms
fit = mag1*exp(-T/tau1)+offset;

if (flag==0 | flag==-1)
	output = mean((localtrace-fit).^2);
else
	output = fit;
end

	