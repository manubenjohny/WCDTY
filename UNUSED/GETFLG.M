function flagvalue = getFLG(flagstring)

%%
%%	GETFLG.M	Function that returns flag values for different toggle
%%			switches (coded in the UserData of the figure).
%%


FInfo = get(gcf,'UserData');				% Get UserData Matrix (handles for GUI and traces)


% Get Appropriate Menu Handle

if strcmp(flagstring,'zero'),Hmenu = FInfo(1,1);,end
if strcmp(flagstring,'leak'),Hmenu = FInfo(1,2);,end
if strcmp(flagstring,'info'),Hmenu = FInfo(1,3);,end
if strcmp(flagstring,'lock'),Hmenu = FInfo(1,7);,end
if strcmp(flagstring,'isotool'),Hmenu = FInfo(1,8);,end

% Set Flag to Appropriate Value
	
if strcmp(get(Hmenu,'Checked'),'on')
	flagvalue = 1;
else
	flagvalue = 0;		
end




