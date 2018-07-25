function error = mexpfit(x)

%%
%%	MEXPFIT.M
%%
%%
%%	x = [tau1 tau2 mag11 mag12 mag21 mag22];

global DATA1 DATA2 FITS1 FITS2 ERROR1 ERROR2;
global I maxfits Ndata fitlimits T;

% Initialize Error to Zero

ERROR1 =zeros(1,maxfits);
ERROR2 =zeros(1,maxfits);


% Extract Taus and Mags

tau1 = x(1);
tau2 = x(2);

mag11 = x(3+0*Ndata:3+1*Ndata-1);
mag12 = x(3+1*Ndata:3+2*Ndata-1);
mag21 = x(3+2*Ndata:3+3*Ndata-1);
mag22 = x(3+3*Ndata:3+4*Ndata-1);


% Calculate Fits

for k = 1:Ndata

	T= I(k)*[0:32*256-1]*1000;

	FITS1(k,fitlimits(k,1):fitlimits(k,2))= mag11(k)*exp(-T/tau1)+mag12(k)*exp(-T/tau2);	
	FITS2(k,fitlimits(k,3):fitlimits(k,4))= mag21(k)*exp(-T/tau1)+mag22(k)*exp(-T/tau2);	

	ERROR1(k) = mean((DATA1(k,fitlimits(k,1):fitlimits(k,2))-FITS1(k,fitlimits(k,1):fitlimits(k,2))).^2);
	ERROR2(k) = mean((DATA2(k,fitlimits(k,3):fitlimits(k,4))-FITS2(k,fitlimits(k,3):fitlimits(k,4))).^2);

end

error = sum(ERROR1+ERROR2);