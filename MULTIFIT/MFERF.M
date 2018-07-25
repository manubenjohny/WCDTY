function error = mferf(x)
%%
%%	MFERF.M		Returns Error to Fits
%%
%%
%%	x = [tau1 tau2 mag11 mag12 mag21 mag22];

global DATA1 DATA2 FITS1 FITS2 ERROR1 ERROR2;
global I maxfits Ndata fitlimits T;

% Initialize Error to Zero

ERROR1 = zeros(1,maxfits);
ERROR2 = zeros(1,maxfits);


% Extract Taus and Mags

T1 = x(1);
T2 = x(2);

M11 = x(3+0*Ndata:3+1*Ndata-1);
M12 = x(3+1*Ndata:3+2*Ndata-1);
M21 = x(3+2*Ndata:3+3*Ndata-1);
M22 = x(3+3*Ndata:3+4*Ndata-1);

% Calculate Fits


for k = 1:Ndata

	T= I(k)*[0:32*256-1]*1000;

	NP = fitlimits(k,2)-fitlimits(k,1)+1;
	FITS1(k,fitlimits(k,1):fitlimits(k,2))= M11(k)*exp(-T(1:NP)/T1)+M12(k)*exp(-T(1:NP)/T2);	
	ERROR1(k) = mean((DATA1(k,fitlimits(k,1):fitlimits(k,2))-FITS1(k,fitlimits(k,1):fitlimits(k,2))).^2);

	NP = fitlimits(k,4)-fitlimits(k,3)+1;
	FITS2(k,fitlimits(k,3):fitlimits(k,4))= M21(k)*exp(-T(1:NP)/T1)+M22(k)*exp(-T(1:NP)/T2);	
	ERROR2(k) = mean((DATA2(k,fitlimits(k,3):fitlimits(k,4))-FITS2(k,fitlimits(k,3):fitlimits(k,4))).^2);
	
end

error = sum(ERROR1/Ndata+ERROR2);