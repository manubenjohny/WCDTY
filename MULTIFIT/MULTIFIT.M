%
%  	MULTIFIT.M	Simultaneous Bi-Exponential fits to multiple sweeps.
%			Fits Pulse 1 and Pulse 3 (Normalized to peak Pulse 1)
%			Sweeps taken from file in WC-generated window.
%			GRAB -- Grabs sweep from WC window
%

global DATA1 DATA2 FITS1 FITS2 ERROR1 ERROR2;
global I maxfits Ndata fitlimits T x;
global Haxes Hdata Hfits;

% Define Default Parameters

maxfits = 4;			% maximum number of simultaneous fits
starttime = 5;
endtime = 245;


% Initialize Variables

x = [];

mag11 = [];
mag12 = [];
mag21 = [];
mag22 = [];

Ndata = 0;			% number of data traces gathered

fitlimits = zeros(maxfits,4);	 

Haxes = zeros(1,maxfits);
Hdata = zeros(1,maxfits);
Hfits = zeros(1,maxfits);

I = zeros(1,maxfits);


% Define InterFigure Variables

wcHandle = gcf;
wcName = get(wcHandle,'Name');
wcFInfo = get(wcHandle,'UserData');


% Initialize Multifit Figure

HFmfit=figure(	'Name',	[wcName ' --- MultiFIT'], ...
		'NumberTitle', 'off', ...
		'Units', 'normal',...
		'Position', [.30 .20 .70 .60]);		

HMnull = uimenu('Label','-->','Callback','');
HMgrab = uimenu('Label','Grab','Callback','mfgrab');
HMfits = uimenu('Label','Fits');

HMfit1 = uimenu(HMfits,'Label','Unconstrained','Callback','mffits');
HMfit2 = uimenu(HMfits,'Label','Constrained','Callback','mffits2');


% HMzoom = uimenu('Label','Zoom','Callback','mfzoom');


% Initialize Axes

Haxes = zeros(1,maxfits);

for k = 1:maxfits
	Haxes(k)=subplot(2,ceil(maxfits/2),k);
end


