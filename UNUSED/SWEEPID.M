function handle = sweepID(command, numvector, textinfo)

%%
%%	SWEEPID.M	
%%
%%	This is the master storage/retrieval function for keeping track of the data in 
%%	a figure.

if strcmp(command, 'setup')

	sweepID = uicontrol(	HFactive,...
				'Style', 'text',...
				'Units', 'normalized',...
				'Position', [.05 .05 .05 .05],...
				'String', string,...			
				'Visible', 'off',...
				'UserData', numvector);

	set(HFactive,'Name',datafilename);
	set(HFactive,'UserData', [sweepID]);
end