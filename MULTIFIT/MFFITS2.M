%%
%%	MFFITS2.M	Performs Nelder-Mead Simplex Fits (Constrained)
%%
%%


% Initialize Variables

DATA1 = zeros(maxfits, 32*256);
FITS1 = zeros(maxfits, 32*256);
ERROR1 =zeros(1,maxfits);

DATA2 = zeros(maxfits, 32*256);
FITS2 = zeros(maxfits, 32*256);
ERROR2 =zeros(1,maxfits);

T = zeros(maxfits,32*256);



% Load Up with Values

for k = 1:Ndata
	
	trace = get(Hdata(k),'YData');
	
	DATA1(k,fitlimits(k,1):fitlimits(k,2))=trace(fitlimits(k,1):fitlimits(k,2));
	DATA2(k,fitlimits(k,3):fitlimits(k,4))=trace(fitlimits(k,3):fitlimits(k,4));

end


% Define Initial Parameter Values

% Mag is set in MFGRAB

tau1 = 50;
tau2 = 1000;


% Perform Fit

x0 = [tau1 tau2 mag11 mag12 mag21 mag22];

x = fmins('mferf',x0);

disp(x);
		