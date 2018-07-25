function output = expfitM(x, trace, startpoint, endpoint,duration,I,flag)
	
%%
%%	EXPFITM		Produces simultaneous bi-exponential constrained fits
%%			by least squared error to two regions of the data according to model
%%
%%		x:  			[mag11 mag12 tauI1 tauI2 tauR1 tauR2]
%%  		data:			data to be fit
%%		startpoint(1:2): 	datapoint to start fit
%%		endpoint(1:2):		datapoint to end fit

global fit;

mag11 = x(1);
mag12 = x(2);
tauI1 = x(3);
tauI2 = x(4);
tauR1 = x(5);
tauR2 = x(6);

% trace = current in pA, T = time in ms

T1 = I*[0:(endpoint(1)-startpoint(1))]*1000;
fit1 = mag11*exp(-T1/tauI1)+mag12*exp(-T1/tauI2);
trace1=trace(startpoint(1):endpoint(1));

D1 = duration(1);
D2 = duration(2);

mag21 = mag11*exp(-D1/tauI1)+mag11*(1-exp(-D1/tauI1))*(1-exp(-D2/tauR1));
mag22 = mag12*exp(-D1/tauI2)+mag12*(1-exp(-D1/tauI2))*(1-exp(-D2/tauR2));

T2 = I*[0:(endpoint(2)-startpoint(2))]*1000;
fit2 = mag21*exp(-T2/tauI1)+mag22*exp(-T2/tauI2);
trace2=trace(startpoint(2):endpoint(2));

if (flag == 0)
	
	output = mean((trace1-fit1).^2)+mean((trace2-fit2).^2);
else
	fit = zeros(size(trace));
	fit(startpoint(1):endpoint(1))=fit1;
	fit(startpoint(2):endpoint(2))=fit2;
	output = fit;
end
