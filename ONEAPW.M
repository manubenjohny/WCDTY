%%
%%	ONEAPW	Set up auxiliary figure for single-sweep leaks of APWs
%%


%%%%%%%%%%%%%%%%%   User Determined Values   %%%%%%%%%%%%%%%%%%%%%%%%%%

apwPOS  = 20;					% start of APW in ms

leakPOS = 50;					% start of Leaks in ms
leakSPC = 20;
nleaks = 12;
PX = 4;

%%%%%%%%%%%%%%%%%%%%%%%% Make Auxiliary Figure  %%%%%%%%%%%%%%%%%%%%%%%

wcHandle = HFmain;
apwHandle = figure(	'Name',	'Leak Subtracted APW', ...
			'NumberTitle', 'off', ...
			'Units', 'normal',...
			'Position', [.68 .33 .30 .55],...
			'UserData', zeros(4,30));

HMtools= uimenu(	'Label','Tool');

HMfilt=	uimenu(HMtools,'Label','LoPass Filter','Callback','lopass');
HMasc=	uimenu(HMtools,'Label','ASCII Dump','Callback','ascdump');
HMohz=	uimenu(HMtools,'Label','Seq ASCII Dump','Callback','ohzdump');

HMback= uimenu(	'Label','Back',...
		'Callback','figure(wcHandle),newswp(''back''),figure(apwHandle),leakAPW');
HMnext= uimenu(	'Label','Next',...
		'Callback','figure(wcHandle),newswp(''next''),figure(apwHandle),leakAPW');
leakAPW;