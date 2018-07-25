function expandx

%%
%%	EXPANDX.M	Expand Region of Trace
%%

%% Determine if Expand is Already On
global HFmain
FInfo = get(HFmain,'UserData');				% Get UserData Matrix (handles for GUI and traces)
HBexpand = FInfo(1,15);					% Get Menu Handle


expON = get(HBexpand,'UserData');

if (expON==0)
		
	disp('Select Region to expand with the Mouse')

	[x1 y button] = ginput(1);	
	[x2 y button] = ginput(1);	
	set(gca,'Xlim',sort([x1 x2]));

	set(HBexpand,'UserData',[1]);	% Turn on Expand Flag

	if ~getFLAG('lock')		% Lock Expanded Axis
		Mtoggle(7);	
	end

else

	disp('Expand Turned Off')
	
	set(HBexpand,'UserData',[0]);	% Turn on Expand Flag

	if getFLAG('lock')
		Mtoggle(7);
	end

end