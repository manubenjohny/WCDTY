function output = expF2DFT(x)

global trace startpoint endpoint I flag fixedparameters;

try
    tau1 = fixedparameters(1);
    tau2 = fixedparameters(2);
catch
    return
end

%%	EXPF2DFT	Produces simultaneous bi-exponential constrained fits
%     			by least squared error to two regions of the data
%
%		x:  			[mag11 mag12 mag21 mag22]
%  		data:			data to be fit
%		startpoint(1:2): 	datapoint to start fit
%		endpoint(1:2):		datapoint to end fit
%
%%
%global fit;

mag11 = x(1);
mag12 = x(2);
mag21 = x(3);
mag22 = x(4);

if (flag==0)
	delta = ceil((endpoint-startpoint)/1000);
else
	delta = [1 1];
end

% trace = current in pA, T = time in ms

T1 = I*[0:delta(1):(endpoint(1)-startpoint(1))]/1000;
fit1 = mag11*exp(-T1/tau1)+mag12*exp(-T1/tau2);
localtrace1=trace(startpoint(1):delta(1):endpoint(1));

T2 = I*[0:delta(2):(endpoint(2)-startpoint(2))]/1000;
fit2 = mag21*exp(-T2/tau1)+mag22*exp(-T2/tau2);
localtrace2=trace(startpoint(2):delta(2):endpoint(2));

if (flag==0 | flag==-1)
	
	output = mean((localtrace1-fit1).^2)+mean((localtrace2-fit2).^2);
else
	fit = zeros(size(trace));
	fit(startpoint(1):endpoint(1))=fit1;
	fit(startpoint(2):endpoint(2))=fit2;
	output = fit;
end
