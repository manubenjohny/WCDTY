function Mtoggle(number)

%%
%%	MenuTOGGLE.M	Function Toggles Menu Checks and Refresh Sweep
%%
%%


%	FInfo:	Row 1: Handles for GUI
global HFmain

FInfo = get(HFmain,'UserData');				% Get UserData Matrix (handles for GUI and traces)
Hmenu = FInfo(1,number);				% Get Menu Handle


if strcmp(get(Hmenu,'Checked'),'on')
	set(Hmenu,'Checked','off');
else
	set(Hmenu,'Checked','on');
end


%	Refresh the current trace and replot it

HIDline = FInfo(2,2);

TP = get(HIDline,'UserData');

datafile = setstr(nonzeros(TP(1,:))');
rnum = TP(2,1);
swpnum = TP(2,3);

plotswp(datafile,rnum,swpnum);